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

  group('GST Billing Tests', () {
    test('1. Bill with subtotal 1000, discount 0, other charges 0, GST 18%', () async {
      final custId = await customerRepo.addCustomer(name: 'GST Customer 1', mobile: '9876543210');
      final itemId = await itemRepo.addItem(
        name: 'GST Product 1',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 500.0,
        sellingRate: 1000.0,
        openingQty: 50.0,
      );

      final billNumber = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 1000.0)],
        discount: 0.0,
        otherCharges: 0.0,
        gstEnabled: true,
        gstPercent: 18.0,
        amountReceived: 0.0,
        paymentMethod: 'cash',
      );

      final bills = await billingRepo.getAllBills();
      final bill = bills.firstWhere((b) => b.billNumber == billNumber);

      expect(bill.gstEnabled, isTrue);
      expect(bill.gstPercent, equals(18.0));
      expect(bill.subtotal, equals(1000.0));
      expect(bill.taxableAmount, equals(1000.0));
      expect(bill.gstAmount, equals(180.0));
      expect(bill.grandTotal, equals(1180.0));
      expect(bill.remainingBalance, equals(1180.0));
    });

    test('2. Bill with GST disabled has gstAmount = 0 and grandTotal = subtotal', () async {
      final custId = await customerRepo.addCustomer(name: 'GST Customer 2', mobile: '9876543211');
      final itemId = await itemRepo.addItem(
        name: 'GST Product 2',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 500.0,
        sellingRate: 1000.0,
        openingQty: 50.0,
      );

      final billNumber = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 1000.0)],
        discount: 0.0,
        otherCharges: 0.0,
        gstEnabled: false,
        amountReceived: 0.0,
        paymentMethod: 'cash',
      );

      final bills = await billingRepo.getAllBills();
      final bill = bills.firstWhere((b) => b.billNumber == billNumber);

      expect(bill.gstEnabled, isFalse);
      expect(bill.gstPercent, isNull);
      expect(bill.subtotal, equals(1000.0));
      expect(bill.taxableAmount, equals(1000.0));
      expect(bill.gstAmount, equals(0.0));
      expect(bill.grandTotal, equals(1000.0));
    });

    test('3. Bill with discount 100, other charges 50, GST 12%', () async {
      final custId = await customerRepo.addCustomer(name: 'GST Customer 3', mobile: '9876543212');
      final itemId = await itemRepo.addItem(
        name: 'GST Product 3',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 500.0,
        sellingRate: 1000.0,
        openingQty: 50.0,
      );

      final billNumber = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 1000.0)],
        discount: 100.0,
        otherCharges: 50.0,
        gstEnabled: true,
        gstPercent: 12.0,
        amountReceived: 0.0,
        paymentMethod: 'cash',
      );

      final bills = await billingRepo.getAllBills();
      final bill = bills.firstWhere((b) => b.billNumber == billNumber);

      // subtotal = 1000, discount = 100, otherCharges = 50 -> taxable = 950
      // gstAmount = 950 * 0.12 = 114
      // grandTotal = 950 + 114 = 1064
      expect(bill.gstEnabled, isTrue);
      expect(bill.gstPercent, equals(12.0));
      expect(bill.subtotal, equals(1000.0));
      expect(bill.discount, equals(100.0));
      expect(bill.otherCharges, equals(50.0));
      expect(bill.taxableAmount, equals(950.0));
      expect(bill.gstAmount, equals(114.0));
      expect(bill.grandTotal, equals(1064.0));
    });

    test('4. Advance applied to bill with GST caps advance at GST-inclusive grandTotal', () async {
      final custId = await customerRepo.addCustomer(name: 'GST Customer 4', mobile: '9876543213');
      final itemId = await itemRepo.addItem(
        name: 'GST Product 4',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 500.0,
        sellingRate: 1000.0,
        openingQty: 50.0,
      );

      // Deposit ₹2000 advance
      await billingRepo.recordAdvanceDeposit(
        customerId: custId,
        amount: 2000.0,
        method: 'cash',
        date: DateTime.now(),
      );

      // Calculate advance to apply (capped at GST-inclusive bill total 1180.0)
      final availableAdvance = await billingRepo.getCustomerAdvanceBalance(custId);
      final grandTotal = 1180.0;
      final advanceToApply = availableAdvance > grandTotal ? grandTotal : availableAdvance;

      final billNumber = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 1000.0)],
        gstEnabled: true,
        gstPercent: 18.0,
        advanceToApply: advanceToApply,
        paymentMethod: 'advance',
      );

      final bills = await billingRepo.getAllBills();
      final bill = bills.firstWhere((b) => b.billNumber == billNumber);

      expect(bill.grandTotal, equals(1180.0));
      expect(bill.amountPaid, equals(1180.0));
      expect(bill.remainingBalance, equals(0.0));

      // Remaining advance should be 2000 - 1180 = 820
      final advanceBalance = await billingRepo.getCustomerAdvanceBalance(custId);
      expect(advanceBalance, equals(820.0));
    });

    test('5. Pre-migration bill backfill backfills taxable_amount = grand_total when gst_enabled = 0', () async {
      final custId = await customerRepo.addCustomer(name: 'GST Customer 5', mobile: '9876543214');

      // Insert a bill directly into DB simulating an old schema row where taxable_amount might be 0
      await db.customStatement('''
        INSERT INTO bills (
          bill_number, customer_id, bill_date, subtotal, discount, other_charges,
          grand_total, amount_paid, remaining_balance, status,
          gst_enabled, gst_percent, taxable_amount, gst_amount
        ) VALUES (
          'INV-OLD-001', $custId, ${DateTime.now().millisecondsSinceEpoch}, 500.0, 0.0, 0.0,
          500.0, 0.0, 500.0, 'active',
          0, 0.0, 0.0, 0.0
        );
      ''');

      // Execute migration backfill SQL statement directly
      await db.customStatement(
        'UPDATE bills SET taxable_amount = grand_total WHERE taxable_amount = 0 AND gst_enabled = 0;',
      );

      final bills = await billingRepo.getAllBills();
      final oldBill = bills.firstWhere((b) => b.billNumber == 'INV-OLD-001');

      expect(oldBill.gstEnabled, isFalse);
      expect(oldBill.taxableAmount, equals(500.0));
      expect(oldBill.gstAmount, equals(0.0));
      expect(oldBill.grandTotal, equals(500.0));
    });
  });
}
