import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shopmanager/core/utils/pricing_utils.dart';
import 'package:shopmanager/data/db/app_database.dart';
import 'package:shopmanager/data/models/bill_model.dart';
import 'package:shopmanager/data/models/billable_product_model.dart';
import 'package:shopmanager/data/repositories/billing_repository.dart';
import 'package:shopmanager/data/repositories/item_repository.dart';
import 'package:shopmanager/data/repositories/selling_product_repository.dart';
import 'package:shopmanager/services/excel_export_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return Directory.systemTemp.path;
      },
    );
  });
  group('Core Pricing Engine (resolveUnitPrice)', () {
    test('Returns retail price when customer is not wholesale', () {
      expect(
        resolveUnitPrice(retail: 150.0, wholesale: 120.0, isWholesaleCustomer: false),
        equals(150.0),
      );
    });

    test('Returns wholesale price when customer is wholesale and wholesale price exists', () {
      expect(
        resolveUnitPrice(retail: 150.0, wholesale: 120.0, isWholesaleCustomer: true),
        equals(120.0),
      );
    });

    test('Falls back to retail price when wholesale is null', () {
      expect(
        resolveUnitPrice(retail: 150.0, wholesale: null, isWholesaleCustomer: true),
        equals(150.0),
      );
    });

    test('Falls back to retail price when wholesale is 0 or negative', () {
      expect(
        resolveUnitPrice(retail: 150.0, wholesale: 0.0, isWholesaleCustomer: true),
        equals(150.0),
      );
      expect(
        resolveUnitPrice(retail: 150.0, wholesale: -10.0, isWholesaleCustomer: true),
        equals(150.0),
      );
    });
  });

  group('Two-Source Billing & Product Management Invariants', () {
    late AppDatabase db;
    late BillingRepository billingRepo;
    late ItemRepository itemRepo;
    late SellingProductRepository sellingProductRepo;
    late ExcelExportService excelService;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      billingRepo = BillingRepository(db);
      itemRepo = ItemRepository(db);
      sellingProductRepo = SellingProductRepository(db);
      excelService = ExcelExportService(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('Full lifecycle: Stock item, Own Product, Mixed Bill, Voiding, and Exports', () async {
      // 1. Create a retail customer and a wholesale customer
      final retailCustId = await db.into(db.customers).insert(
            CustomersCompanion.insert(
              name: 'Retail Customer',
              mobile: '9876543210',
              isWholesale: const drift.Value(false),
            ),
          );

      final wholesaleCustId = await db.into(db.customers).insert(
            CustomersCompanion.insert(
              name: 'Wholesale Customer',
              mobile: '9876543211',
              isWholesale: const drift.Value(true),
            ),
          );

      // 2. Create Stock item (with retail sellingRate 100, wholesaleRate 80, stock 20)
      final stockItemId = await itemRepo.addItem(
        name: 'Cotton Fabric',
        type: 'raw_material',
        unit: 'm',
        purchaseRate: 50.0,
        sellingRate: 100.0,
        wholesaleRate: 80.0,
        openingQty: 20.0,
      );

      // 3. Create Selling Product (own manufactured: price 250, wholesalePrice 200)
      final ownProdId = await sellingProductRepo.addProduct(
        name: 'Handcrafted Kurta',
        price: 250.0,
        wholesalePrice: 200.0,
        description: 'Pure cotton kurta',
      );

      // Verify master data
      final fetchedItem = await itemRepo.getItemById(stockItemId);
      expect(fetchedItem, isNotNull);
      expect(fetchedItem!.sellingRate, equals(100.0));
      expect(fetchedItem.wholesaleRate, equals(80.0));
      expect(fetchedItem.currentQty, equals(20.0));

      final fetchedProduct = await sellingProductRepo.getProductById(ownProdId);
      expect(fetchedProduct, isNotNull);
      expect(fetchedProduct!.price, equals(250.0));
      expect(fetchedProduct.wholesalePrice, equals(200.0));

      // BillableProduct adapters
      final billableStock = BillableProduct.fromStockItem(fetchedItem);
      final billableOwn = BillableProduct.fromSellingProduct(fetchedProduct);

      expect(billableStock.isStock, isTrue);
      expect(billableStock.priceForCustomer(false), equals(100.0));
      expect(billableStock.priceForCustomer(true), equals(80.0));

      expect(billableOwn.isOwn, isTrue);
      expect(billableOwn.priceForCustomer(false), equals(250.0));
      expect(billableOwn.priceForCustomer(true), equals(200.0));
      expect(billableOwn.currentQty, equals(double.infinity));

      // -------------------------------------------------------------
      // 4. TEST CASE 1: Own-product only bill (Unlimited quantity)
      // -------------------------------------------------------------
      final ownOnlyLines = [
        BillLine(
          sellingProductId: ownProdId,
          productName: billableOwn.name,
          unit: billableOwn.unit,
          quantity: 100.0, // large quantity
          rate: 250.0,
          mrpRateAtSale: 250.0,
        ),
      ];

      final ownBillNum = await billingRepo.saveBill(
        customerId: retailCustId,
        billDate: DateTime.now(),
        lines: ownOnlyLines,
        amountReceived: 25000.0,
        paymentMethod: 'cash',
      );

      expect(ownBillNum, startsWith('INV-'));

      // Invariant: Own products must NOT deduct stock or create stock transactions
      final itemAfterOwnBill = await itemRepo.getItemById(stockItemId);
      expect(itemAfterOwnBill!.currentQty, equals(20.0)); // unchanged!

      final soldStockTxs = (await db.select(db.stockTransactions).get()).where((t) => t.type == 'sold').toList();
      expect(soldStockTxs, isEmpty); // Zero sold stock transactions!

      // -------------------------------------------------------------
      // 5. TEST CASE 2: Mixed Bill (1 stock item + 1 own product)
      // -------------------------------------------------------------
      final mixedLines = [
        BillLine(
          itemId: stockItemId,
          productName: billableStock.name,
          unit: billableStock.unit,
          quantity: 5.0,
          rate: 80.0, // wholesale rate applied
          mrpRateAtSale: 100.0,
        ),
        BillLine(
          sellingProductId: ownProdId,
          productName: billableOwn.name,
          unit: billableOwn.unit,
          quantity: 2.0,
          rate: 200.0, // wholesale rate applied
          mrpRateAtSale: 250.0,
        ),
      ];

      final mixedBillNum = await billingRepo.saveBill(
        customerId: wholesaleCustId,
        billDate: DateTime.now(),
        lines: mixedLines,
        amountReceived: 800.0, // (5*80 + 2*200) = 400 + 400 = 800
        paymentMethod: 'upi',
      );

      // Invariant: Stock item deducted by 5 (20 -> 15), own product unaffected
      final itemAfterMixed = await itemRepo.getItemById(stockItemId);
      expect(itemAfterMixed!.currentQty, equals(15.0));

      final soldTxsAfterMixed = (await db.select(db.stockTransactions).get()).where((t) => t.type == 'sold').toList();
      expect(soldTxsAfterMixed.length, equals(1));
      expect(soldTxsAfterMixed.first.itemId, equals(stockItemId));
      expect(soldTxsAfterMixed.first.quantity, equals(-5.0));

      // Verify Bill Details snapshot
      final mixedBills = await db.select(db.bills).get();
      final mixedBillEntity = mixedBills.firstWhere((b) => b.billNumber == mixedBillNum);
      final detail = await billingRepo.getBillDetail(mixedBillEntity.id);
      expect(detail, isNotNull);
      expect(detail!.items.length, equals(2));

      final stockLineDetail = detail.items.firstWhere((i) => i.isStock);
      expect(stockLineDetail.itemName, equals('Cotton Fabric'));
      expect(stockLineDetail.rate, equals(80.0));
      expect(stockLineDetail.mrpRateAtSale, equals(100.0));
      expect(stockLineDetail.amount, equals(400.0));

      final ownLineDetail = detail.items.firstWhere((i) => i.isOwn);
      expect(ownLineDetail.itemName, equals('Handcrafted Kurta'));
      expect(ownLineDetail.rate, equals(200.0));
      expect(ownLineDetail.mrpRateAtSale, equals(250.0));
      expect(ownLineDetail.amount, equals(400.0));

      // -------------------------------------------------------------
      // 6. TEST CASE 3: Manual Rate Override persistence without master corruption
      // -------------------------------------------------------------
      final overrideLines = [
        BillLine(
          sellingProductId: ownProdId,
          productName: billableOwn.name,
          unit: billableOwn.unit,
          quantity: 1.0,
          rate: 185.0, // Special negotiated rate
          mrpRateAtSale: 250.0,
        ),
      ];

      final overrideBillNum = await billingRepo.saveBill(
        customerId: retailCustId,
        billDate: DateTime.now(),
        lines: overrideLines,
        amountReceived: 185.0,
      );

      final overrideBills = await db.select(db.bills).get();
      final overrideBill = overrideBills.firstWhere((b) => b.billNumber == overrideBillNum);
      final overrideDetail = await billingRepo.getBillDetail(overrideBill.id);
      expect(overrideDetail!.items.first.rate, equals(185.0));

      // Invariant: Master product price MUST remain untouched
      final productAfterOverride = await sellingProductRepo.getProductById(ownProdId);
      expect(productAfterOverride!.price, equals(250.0));
      expect(productAfterOverride.wholesalePrice, equals(200.0));

      // -------------------------------------------------------------
      // 7. TEST CASE 4: Bill Voiding on mixed bill
      // -------------------------------------------------------------
      await billingRepo.voidBill(
        billId: mixedBillEntity.id,
        reason: 'Customer cancelled wholesale order',
      );

      // Invariant: Only stock item stock is restored (15 -> 20), own product has no reversals
      final itemAfterVoid = await itemRepo.getItemById(stockItemId);
      expect(itemAfterVoid!.currentQty, equals(20.0));

      final voidTxsAfterVoid = (await db.select(db.stockTransactions).get())
          .where((t) => t.referenceType == 'bill_void')
          .toList();
      expect(voidTxsAfterVoid.length, equals(1));
      expect(voidTxsAfterVoid.first.quantity, equals(5.0));

      // -------------------------------------------------------------
      // 8. TEST CASE 5: Quick Sale channel with Walk-in & Both products
      // -------------------------------------------------------------
      final qsLines = [
        BillLine(
          itemId: stockItemId,
          productName: billableStock.name,
          unit: billableStock.unit,
          quantity: 3.0,
          rate: 100.0,
          mrpRateAtSale: 100.0,
        ),
        BillLine(
          sellingProductId: ownProdId,
          productName: billableOwn.name,
          unit: billableOwn.unit,
          quantity: 2.0,
          rate: 250.0,
          mrpRateAtSale: 250.0,
        ),
      ];

      final qsBillNum = await billingRepo.saveBill(
        saleChannel: 'quick_sale',
        customerId: null, // Walk-in customer
        billDate: DateTime.now(),
        lines: qsLines,
        amountReceived: 800.0, // (3*100 + 2*250) = 300 + 500 = 800
        paymentMethod: 'cash',
      );

      expect(qsBillNum, startsWith('QS-'));

      // Check stock deduction for stock item (20 -> 17)
      final itemAfterQs = await itemRepo.getItemById(stockItemId);
      expect(itemAfterQs!.currentQty, equals(17.0));

      // -------------------------------------------------------------
      // 9. TEST CASE 6: Excel Export Service coverage
      // -------------------------------------------------------------
      final itemsFile = await excelService.exportItems();
      expect(await itemsFile.exists(), isTrue);

      final billItemsFile = await excelService.exportBillItems();
      expect(await billItemsFile.exists(), isTrue);

      final sellingProductsFile = await excelService.exportSellingProducts();
      expect(await sellingProductsFile.exists(), isTrue);

      final billsFile = await excelService.exportBills();
      expect(await billsFile.exists(), isTrue);

      final allExportFiles = await excelService.exportAll();
      expect(allExportFiles.length, equals(11));

      // Clean up temporary excel files
      for (final f in allExportFiles) {
        if (await f.exists()) {
          await f.delete();
        }
      }
    });
  });
}
