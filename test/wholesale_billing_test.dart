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

  group('Per-Customer Wholesale Pricing Module Tests', () {
    test('1. Normal Customer Bill — isWholesaleBill is false, mrpRateAtSale recorded', () async {
      final custId = await customerRepo.addCustomer(
        name: 'Retail Buyer',
        mobile: '9876543210',
        isWholesale: false,
      );

      final itemId = await itemRepo.addItem(
        name: 'Cotton Shirt',
        sku: 'SHIRT-01',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 300.0,
        sellingRate: 500.0,
        openingQty: 50.0,
      );

      final billNum = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 2, rate: 500.0)],
        discount: 0.0,
      );

      final bills = await billingRepo.getAllBills();
      final bill = bills.firstWhere((b) => b.billNumber == billNum);
      expect(bill.isWholesaleBill, isFalse);

      final detail = await billingRepo.getBillDetail(bill.id);
      expect(detail, isNotNull);
      expect(detail!.bill.isWholesaleBill, isFalse);
      expect(detail.items.length, equals(1));
      expect(detail.items.first.rate, equals(500.0));
      expect(detail.items.first.mrpRateAtSale, equals(500.0));
      expect(detail.bill.grandTotal, equals(1000.0));
    });

    test('2. Wholesale Customer Bill — isWholesaleBill is true, edited wholesale rate used for math, mrpRateAtSale preserved', () async {
      final custId = await customerRepo.addCustomer(
        name: 'Wholesale Depot',
        mobile: '9123456789',
        isWholesale: true,
      );

      final itemId = await itemRepo.addItem(
        name: 'Denim Jeans',
        sku: 'JEANS-01',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 600.0,
        sellingRate: 1000.0, // Standard MRP
        openingQty: 100.0,
      );

      // Owner enters a discounted wholesale rate of 800.0
      final billNum = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 5, rate: 800.0)],
        discount: 50.0,
        gstEnabled: true,
        gstPercent: 18.0,
      );

      final bills = await billingRepo.getAllBills();
      final bill = bills.firstWhere((b) => b.billNumber == billNum);
      final detail = await billingRepo.getBillDetail(bill.id);

      expect(detail, isNotNull);
      expect(detail!.bill.isWholesaleBill, isTrue);
      expect(detail.items.length, equals(1));

      final line = detail.items.first;
      expect(line.rate, equals(800.0)); // Wholesale rate applied
      expect(line.mrpRateAtSale, equals(1000.0)); // Captured original selling rate / MRP
      expect(line.amount, equals(4000.0)); // 5 * 800

      // Math verification: Subtotal = 4000, Taxable = 4000 - 50 = 3950, GST (18%) = 711, Grand Total = 4661
      expect(detail.bill.subtotal, equals(4000.0));
      expect(detail.bill.taxableAmount, equals(3950.0));
      expect(detail.bill.gstAmount, equals(711.0));
      expect(detail.bill.grandTotal, equals(4661.0));
    });

    test('3. Math Engine Equality — Wholesale and Normal bill calculations use identical formula for given rate', () async {
      final retailCustId = await customerRepo.addCustomer(name: 'Retail Customer', mobile: '9000000001');
      final wholesaleCustId = await customerRepo.addCustomer(name: 'Wholesale Customer', mobile: '9000000002', isWholesale: true);

      final itemId = await itemRepo.addItem(
        name: 'Test Item',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 10.0,
        sellingRate: 20.0,
        openingQty: 100.0,
      );

      // Bill 1: Retail customer with explicit rate = 15.0
      final num1 = await billingRepo.saveBill(
        customerId: retailCustId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 10, rate: 15.0)],
        discount: 10.0,
        gstEnabled: true,
        gstPercent: 12.0,
      );

      // Bill 2: Wholesale customer with same rate = 15.0
      final num2 = await billingRepo.saveBill(
        customerId: wholesaleCustId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 10, rate: 15.0)],
        discount: 10.0,
        gstEnabled: true,
        gstPercent: 12.0,
      );

      final bills = await billingRepo.getAllBills();
      final bill1 = bills.firstWhere((b) => b.billNumber == num1);
      final bill2 = bills.firstWhere((b) => b.billNumber == num2);

      final detail1 = await billingRepo.getBillDetail(bill1.id);
      final detail2 = await billingRepo.getBillDetail(bill2.id);

      expect(detail1!.bill.isWholesaleBill, isFalse);
      expect(detail2!.bill.isWholesaleBill, isTrue);

      expect(detail1.bill.subtotal, equals(detail2.bill.subtotal));
      expect(detail1.bill.taxableAmount, equals(detail2.bill.taxableAmount));
      expect(detail1.bill.gstAmount, equals(detail2.bill.gstAmount));
      expect(detail1.bill.grandTotal, equals(detail2.bill.grandTotal));
    });

    test('4. Historical Immutability — Toggling customer isWholesale after creation does not alter past bill status', () async {
      final custId = await customerRepo.addCustomer(name: 'Flexible Trader', mobile: '9888877777', isWholesale: true);

      final itemId = await itemRepo.addItem(
        name: 'Item A',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 50.0,
        sellingRate: 100.0,
        openingQty: 50.0,
      );

      final billNum = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 2, rate: 80.0)],
      );

      final bills = await billingRepo.getAllBills();
      final billBefore = bills.firstWhere((b) => b.billNumber == billNum);
      final detailBefore = await billingRepo.getBillDetail(billBefore.id);
      expect(detailBefore!.bill.isWholesaleBill, isTrue);

      // Change customer classification from wholesale to retail
      final customer = await customerRepo.getCustomerById(custId);
      expect(customer, isNotNull);
      await customerRepo.updateCustomer(
        id: custId,
        name: customer!.name,
        mobile: customer.mobile,
        isWholesale: false,
      );

      final updatedCustomer = await customerRepo.getCustomerById(custId);
      expect(updatedCustomer!.isWholesale, isFalse);

      // Past bill must still report isWholesaleBill = true
      final detailAfter = await billingRepo.getBillDetail(billBefore.id);
      expect(detailAfter!.bill.isWholesaleBill, isTrue);
      expect(detailAfter.items.first.mrpRateAtSale, equals(100.0));
    });

    test('5. Quick Sale for Wholesale Customer — captures isWholesaleBill = true and mrpRateAtSale', () async {
      final custId = await customerRepo.addCustomer(name: 'Bulk Mart', mobile: '9777766666', isWholesale: true);

      final itemId = await itemRepo.addItem(
        name: 'Bulk Item',
        type: 'finished_product',
        unit: 'kg',
        purchaseRate: 40.0,
        sellingRate: 70.0,
        openingQty: 200.0,
      );

      final billNum = await billingRepo.saveBill(
        saleChannel: 'quick_sale',
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 10, rate: 55.0)],
      );

      final bills = await billingRepo.getAllBills();
      final bill = bills.firstWhere((b) => b.billNumber == billNum);
      final detail = await billingRepo.getBillDetail(bill.id);

      expect(detail, isNotNull);
      expect(detail!.bill.saleChannel, equals('quick_sale'));
      expect(detail.bill.isWholesaleBill, isTrue);
      expect(detail.items.first.rate, equals(55.0));
      expect(detail.items.first.mrpRateAtSale, equals(70.0));
      expect(detail.bill.grandTotal, equals(550.0));
    });
  });
}
