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
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
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

  group('Customer Detail Real Data Repository Tests', () {
    test('Customer with bills/payments returns exact real DB numbers, not fake mock data', () async {
      // 1. Create Customer 1
      final cust1Id = await customerRepo.addCustomer(name: 'Alpha Traders', mobile: '9876543210');
      final itemId = await itemRepo.addItem(
        name: 'Steel Rod',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 100.0,
        sellingRate: 250.0,
        openingQty: 50.0,
      );

      // Create a real bill for Customer 1: grandTotal = 500.0, amountReceived = 200.0 (Cash)
      final billNum = await billingRepo.saveBill(
        customerId: cust1Id,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 2, rate: 250.0)],
        amountReceived: 200.0,
        paymentMethod: 'cash',
      );

      // 2. Fetch Customer 1 Financial Summary
      final summary = await billingRepo.getCustomerFinancialSummary(cust1Id);

      expect(summary.totalBilled, equals(500.0));
      expect(summary.totalPaid, equals(200.0));
      expect(summary.outstandingBalance, equals(300.0));

      // 3. Fetch Customer 1 Bills
      final bills = await billingRepo.getBillsForCustomer(cust1Id);
      expect(bills.length, equals(1));
      expect(bills.first.billNumber, equals(billNum));
      expect(bills.first.billNumber, isNot(equals('INV-2024-089')));
      expect(bills.first.totalAmount, equals(500.0));

      // 4. Fetch Customer 1 Payments
      final payments = await billingRepo.getPaymentsForCustomer(cust1Id);
      expect(payments.length, equals(1));
      expect(payments.first.amount, equals(200.0));
      expect(payments.first.referenceNote, contains(billNum));

      // 5. Fetch Customer 1 Ledger Entries
      final ledger = await billingRepo.getLedgerEntriesForCustomer(cust1Id);
      expect(ledger.isNotEmpty, isTrue);
      expect(ledger.first.runningBalance, equals(300.0));
    });

    test('Customer with zero transactions returns clean empty state data', () async {
      // Create Customer 2 with no bills or payments
      final cust2Id = await customerRepo.addCustomer(name: 'Beta Enterprises', mobile: '9123456789');

      final summary = await billingRepo.getCustomerFinancialSummary(cust2Id);
      expect(summary.totalBilled, equals(0.0));
      expect(summary.totalPaid, equals(0.0));
      expect(summary.outstandingBalance, equals(0.0));

      final bills = await billingRepo.getBillsForCustomer(cust2Id);
      expect(bills.isEmpty, isTrue);

      final payments = await billingRepo.getPaymentsForCustomer(cust2Id);
      expect(payments.isEmpty, isTrue);

      final ledger = await billingRepo.getLedgerEntriesForCustomer(cust2Id);
      expect(ledger.isEmpty, isTrue);
    });
  });
}
