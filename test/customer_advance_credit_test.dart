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

  group('Customer Advance & Credit Accounting Tests', () {
    test('1. Record payment with overpayment splits into bill payment + advance deposit', () async {
      final custId = await customerRepo.addCustomer(name: 'John Doe', mobile: '9999999999');
      final itemId = await itemRepo.addItem(
        name: 'Item A',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 50.0,
        sellingRate: 100.0,
        openingQty: 100.0,
      );

      // Create bill for ₹100, no initial payment
      await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 100.0)],
        amountReceived: 0.0,
        paymentMethod: 'cash',
      );

      final bills = await billingRepo.getBillsForCustomer(custId);
      final billId = bills.first.id!;

      // Overpay ₹150 for ₹100 bill
      await billingRepo.recordPaymentForBill(
        billId: billId,
        date: DateTime.now(),
        amount: 150.0,
        method: 'upi',
      );

      // Verify customer financial summary
      final summary = await billingRepo.getCustomerFinancialSummary(custId);
      expect(summary.totalBilled, equals(100.0));
      expect(summary.totalPaid, equals(150.0));
      expect(summary.outstandingBalance, equals(0.0));
      expect(summary.advanceBalance, equals(50.0));

      // Verify payments table records
      final payments = await billingRepo.getPaymentsForCustomer(custId);
      expect(payments.length, equals(2));
      expect(payments.any((p) => p.amount == 100.0), isTrue);
      expect(payments.any((p) => p.amount == 50.0), isTrue);

      // Verify ledger entries (most recent first)
      final ledger = await billingRepo.getLedgerEntriesForCustomer(custId);
      expect(ledger.first.runningBalance, equals(-50.0)); // Credit balance of ₹50 on most recent entry
    });

    test('2. Standalone advance deposit increases advance balance and credit ledger', () async {
      final custId = await customerRepo.addCustomer(name: 'Jane Smith', mobile: '8888888888');

      await billingRepo.recordAdvanceDeposit(
        customerId: custId,
        date: DateTime.now(),
        amount: 200.0,
        method: 'cash',
        notes: 'Deposit for next order',
      );

      final advanceBal = await billingRepo.getCustomerAdvanceBalance(custId);
      expect(advanceBal, equals(200.0));

      final summary = await billingRepo.getCustomerFinancialSummary(custId);
      expect(summary.advanceBalance, equals(200.0));
      expect(summary.outstandingBalance, equals(0.0));

      final ledger = await billingRepo.getLedgerEntriesForCustomer(custId);
      expect(ledger.length, equals(1));
      expect(ledger.first.runningBalance, equals(-200.0));
    });

    test('3. Save bill applying advance sets advanceApplied and records advance_applied payment without double-crediting ledger', () async {
      final custId = await customerRepo.addCustomer(name: 'Alice Brown', mobile: '7777777777');
      final itemId = await itemRepo.addItem(
        name: 'Item B',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 20.0,
        sellingRate: 50.0,
        openingQty: 100.0,
      );

      // Record ₹100 deposit
      await billingRepo.recordAdvanceDeposit(
        customerId: custId,
        date: DateTime.now(),
        amount: 100.0,
        method: 'upi',
      );

      // Create bill for ₹100, applying ₹80 advance and receiving ₹20 cash
      await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 2, rate: 50.0)], // Subtotal = 100
        amountReceived: 20.0,
        advanceToApply: 80.0,
        paymentMethod: 'cash',
      );

      final advanceBal = await billingRepo.getCustomerAdvanceBalance(custId);
      expect(advanceBal, equals(20.0)); // 100 - 80 = 20 remaining advance

      final summary = await billingRepo.getCustomerFinancialSummary(custId);
      expect(summary.totalBilled, equals(100.0));
      expect(summary.totalPaid, equals(200.0)); // 100 deposit + 20 cash + 80 advance applied
      expect(summary.outstandingBalance, equals(0.0));
      expect(summary.advanceBalance, equals(20.0));
    });

    test('4. Voiding bill with advance applied restores correct ledger balance', () async {
      final custId = await customerRepo.addCustomer(name: 'Bob Wilson', mobile: '6666666666');
      final itemId = await itemRepo.addItem(
        name: 'Item C',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 30.0,
        sellingRate: 60.0,
        openingQty: 100.0,
      );

      // Deposit ₹100
      await billingRepo.recordAdvanceDeposit(
        customerId: custId,
        date: DateTime.now(),
        amount: 100.0,
        method: 'cash',
      );

      // Save bill ₹60 applying ₹60 advance
      await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 60.0)],
        amountReceived: 0.0,
        advanceToApply: 60.0,
        paymentMethod: 'cash',
      );

      final bills = await billingRepo.getBillsForCustomer(custId);
      final billId = bills.first.id!;

      expect(await billingRepo.getCustomerAdvanceBalance(custId), equals(40.0));

      // Void the bill
      await billingRepo.voidBill(billId: billId, reason: 'Customer cancelled order');

      // Advance balance should be restored back to ₹100
      expect(await billingRepo.getCustomerAdvanceBalance(custId), equals(100.0));

      final summary = await billingRepo.getCustomerFinancialSummary(custId);
      expect(summary.advanceBalance, equals(100.0));
      expect(summary.outstandingBalance, equals(0.0));
    });
  });
}
