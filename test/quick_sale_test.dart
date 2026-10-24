import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopmanager/data/db/app_database.dart';
import 'package:shopmanager/data/models/bill_model.dart';
import 'package:shopmanager/data/repositories/billing_repository.dart';
import 'package:shopmanager/data/repositories/customer_repository.dart';
import 'package:shopmanager/data/repositories/item_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return Directory.systemTemp.path;
      },
    );
  });

  late AppDatabase db;
  late CustomerRepository customerRepo;
  late ItemRepository itemRepo;
  late BillingRepository billingRepo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    customerRepo = CustomerRepository(db);
    itemRepo = ItemRepository(db);
    billingRepo = BillingRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Quick Sale / Direct Selling Module Tests', () {
    test('1. Walk-in Quick Sale (null customer, forced full payment, no ledger/payment rows)', () async {
      final itemId = await itemRepo.addItem(
        name: 'Walkin Item',
        sku: 'SKU-WALKIN-1',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 100.0,
        sellingRate: 250.0,
        openingQty: 20.0,
      );

      final billNumber = await billingRepo.saveBill(
        customerId: null,
        saleChannel: 'quick_sale',
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 2, rate: 250.0)],
        discount: 0.0,
        otherCharges: 0.0,
        gstEnabled: false,
      );

      expect(billNumber, equals('QS-0001'));

      final quickSales = await billingRepo.getQuickSales();
      expect(quickSales.length, equals(1));
      final qs = quickSales.first;
      expect(qs.billNumber, equals('QS-0001'));
      expect(qs.isWalkIn, isTrue);
      expect(qs.customerName, equals('Walk-in Customer'));
      expect(qs.grandTotal, equals(500.0));
      expect(qs.amountPaid, equals(500.0));
      expect(qs.remainingBalance, equals(0.0));
      expect(qs.paymentStatus, equals(BillPaymentStatus.paid));

      // Stock reduced from 20 to 18
      final item = await itemRepo.getItemById(itemId);
      expect(item?.currentQty, equals(18.0));

      // Zero ledger entries and zero payment entries for walk-in
      final ledgerRows = await db.select(db.ledgerEntries).get();
      expect(ledgerRows, isEmpty);

      final paymentRows = await db.select(db.payments).get();
      expect(paymentRows, isEmpty);

      // Stock transaction recorded with referenceType 'quick_sale'
      final stockTxns = await db.select(db.stockTransactions).get();
      final qsTxns = stockTxns.where((t) => t.referenceType == 'quick_sale').toList();
      expect(qsTxns.length, equals(1));
      expect(qsTxns.first.quantity, equals(-2.0));
    });

    test('2. Quick Sale with Existing Customer & Partial Payment', () async {
      final custId = await customerRepo.addCustomer(name: 'Jane Counter', mobile: '9988776655');
      final itemId = await itemRepo.addItem(
        name: 'Fabric Roll',
        sku: 'FAB-001',
        type: 'finished_product',
        unit: 'm',
        purchaseRate: 50.0,
        sellingRate: 100.0,
        openingQty: 100.0,
      );

      final billNumber = await billingRepo.saveBill(
        customerId: custId,
        saleChannel: 'quick_sale',
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 10, rate: 100.0)], // grandTotal = 1000
        discount: 0.0,
        otherCharges: 0.0,
        gstEnabled: false,
        amountReceived: 400.0,
        paymentMethod: 'upi',
      );

      expect(billNumber, equals('QS-0001'));

      final detail = await billingRepo.getBillDetail(1);
      expect(detail, isNotNull);
      expect(detail!.bill.customerName, equals('Jane Counter'));
      expect(detail.bill.grandTotal, equals(1000.0));
      expect(detail.bill.amountPaid, equals(400.0));
      expect(detail.bill.remainingBalance, equals(600.0));
      expect(detail.bill.paymentStatus, equals(BillPaymentStatus.partial));

      // Customer ledger entries: 1 debit (1000) and 1 credit payment (400)
      final ledgerEntries = await billingRepo.getLedgerEntriesForCustomer(custId);
      expect(ledgerEntries.length, equals(2));
      final billEntry = ledgerEntries.firstWhere((e) => e.isDebit);
      final paymentEntry = ledgerEntries.firstWhere((e) => !e.isDebit);
      expect(billEntry.amount, equals(1000.0));
      expect(paymentEntry.amount, equals(400.0));

      // Payment row created with method 'upi'
      final payments = await billingRepo.getPaymentsForCustomer(custId);
      expect(payments.length, equals(1));
      expect(payments.first.amount, equals(400.0));
      expect(payments.first.method.name, equals('upi'));
    });

    test('3. Quick Sale with GST Enabled', () async {
      final itemId = await itemRepo.addItem(
        name: 'GST Item',
        sku: 'GST-SKU-1',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 200.0,
        sellingRate: 1000.0,
        openingQty: 50.0,
      );

      final billNumber = await billingRepo.saveBill(
        customerId: null,
        saleChannel: 'quick_sale',
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 1000.0)],
        discount: 0.0,
        otherCharges: 0.0,
        gstEnabled: true,
        gstPercent: 18.0,
      );

      expect(billNumber, equals('QS-0001'));

      final quickSales = await billingRepo.getQuickSales();
      final qs = quickSales.first;
      expect(qs.gstEnabled, isTrue);
      expect(qs.gstPercent, equals(18.0));
      expect(qs.taxableAmount, equals(1000.0));
      expect(qs.gstAmount, equals(180.0));
      expect(qs.grandTotal, equals(1180.0));
      expect(qs.amountPaid, equals(1180.0)); // forced fully paid for walk-in
    });

    test('4. Independent Sequential Numbering (INV- vs QS-)', () async {
      final custId = await customerRepo.addCustomer(name: 'Test Cust', mobile: '9111111111');
      final itemId = await itemRepo.addItem(
        name: 'Test Item',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 10.0,
        sellingRate: 50.0,
        openingQty: 500.0,
      );

      final now = DateTime.now();

      // Create Standard Invoice 1
      final inv1 = await billingRepo.saveBill(
        customerId: custId,
        saleChannel: 'invoice',
        billDate: now,
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 50.0)],
      );
      expect(inv1, equals('INV-0001'));

      // Create Quick Sale 1
      final qs1 = await billingRepo.saveBill(
        customerId: null,
        saleChannel: 'quick_sale',
        billDate: now,
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 50.0)],
      );
      expect(qs1, equals('QS-0001'));

      // Create Standard Invoice 2
      final inv2 = await billingRepo.saveBill(
        customerId: custId,
        saleChannel: 'invoice',
        billDate: now,
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 50.0)],
      );
      expect(inv2, equals('INV-0002'));

      // Create Quick Sale 2
      final qs2 = await billingRepo.saveBill(
        customerId: null,
        saleChannel: 'quick_sale',
        billDate: now,
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 50.0)],
      );
      expect(qs2, equals('QS-0002'));
    });

    test('5. Item SKU Search in ItemRepository', () async {
      await itemRepo.addItem(
        name: 'Cotton Shirt',
        sku: 'SKU-SHIRT-BLUE',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 300.0,
        sellingRate: 700.0,
        openingQty: 10.0,
      );
      await itemRepo.addItem(
        name: 'Denim Pants',
        sku: 'SKU-PANTS-BLACK',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 400.0,
        sellingRate: 900.0,
        openingQty: 10.0,
      );

      final searchResults = await itemRepo.searchItems('SHIRT-BLUE');
      expect(searchResults.length, equals(1));
      expect(searchResults.first.name, equals('Cotton Shirt'));
      expect(searchResults.first.sku, equals('SKU-SHIRT-BLUE'));
    });

    test('6. Sales Report includes both Invoice and Quick Sale channels', () async {
      final custId = await customerRepo.addCustomer(name: 'Report Cust', mobile: '9222222222');
      final itemId = await itemRepo.addItem(
        name: 'Report Item',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 10.0,
        sellingRate: 100.0,
        openingQty: 100.0,
      );

      final now = DateTime.now();

      // Invoice bill = ₹200
      await billingRepo.saveBill(
        customerId: custId,
        saleChannel: 'invoice',
        billDate: now,
        lines: [BillLine(itemId: itemId, quantity: 2, rate: 100.0)],
      );

      // Quick Sale = ₹300
      await billingRepo.saveBill(
        customerId: null,
        saleChannel: 'quick_sale',
        billDate: now,
        lines: [BillLine(itemId: itemId, quantity: 3, rate: 100.0)],
      );

      final report = await billingRepo.getDailySalesReport(from: now, to: now);
      expect(report.totalBills, equals(2));
      expect(report.totalSales, equals(500.0));
    });

    test('7. Quick Sale Calculation Accuracy — Bermuda Qty 1 @ ₹13, no GST, no discount -> Subtotal = ₹13.00 and Grand Total = ₹13.00', () async {
      final itemId = await itemRepo.addItem(
        name: 'Bermuda',
        sku: 'BERMUDA-13',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 8.0,
        sellingRate: 14.0,
        openingQty: 10.0,
      );

      // Save bill via quick_sale channel with rate 13.0
      final billNum = await billingRepo.saveBill(
        saleChannel: 'quick_sale',
        customerId: null,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 13.0)],
        discount: 0.0,
        gstEnabled: false,
      );

      final quickSales = await billingRepo.getQuickSales();
      final qs = quickSales.firstWhere((b) => b.billNumber == billNum);
      final detail = await billingRepo.getBillDetail(qs.id);
      expect(detail, isNotNull);
      expect(detail!.bill.subtotal, equals(13.0));
      expect(detail.bill.taxableAmount, equals(13.0));
      expect(detail.bill.gstAmount, equals(0.0));
      expect(detail.bill.grandTotal, equals(13.0)); // Must be 13.00, NOT 0.13
      expect(detail.bill.amountPaid, equals(13.0));
    });

    test('8. Quick Sale Calculation Accuracy — Item Qty 1 @ ₹1000, GST 18% -> Subtotal = ₹1000, GST = ₹180, Grand Total = ₹1180', () async {
      final itemId = await itemRepo.addItem(
        name: 'Jacket',
        sku: 'JACKET-1000',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 600.0,
        sellingRate: 1000.0,
        openingQty: 10.0,
      );

      final billNum = await billingRepo.saveBill(
        saleChannel: 'quick_sale',
        customerId: null,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 1000.0)],
        discount: 0.0,
        gstEnabled: true,
        gstPercent: 18.0,
      );

      final quickSales = await billingRepo.getQuickSales();
      final qs = quickSales.firstWhere((b) => b.billNumber == billNum);
      final detail = await billingRepo.getBillDetail(qs.id);
      expect(detail, isNotNull);
      expect(detail!.bill.subtotal, equals(1000.0));
      expect(detail.bill.taxableAmount, equals(1000.0));
      expect(detail.bill.gstAmount, equals(180.0));
      expect(detail.bill.grandTotal, equals(1180.0));
      expect(detail.bill.amountPaid, equals(1180.0));
    });
  });
}
