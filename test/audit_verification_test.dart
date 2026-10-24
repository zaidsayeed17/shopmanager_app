import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shopmanager/data/db/app_database.dart';
import 'package:shopmanager/data/models/bill_model.dart';
import 'package:shopmanager/data/repositories/billing_repository.dart';
import 'package:shopmanager/data/repositories/customer_repository.dart';
import 'package:shopmanager/data/repositories/item_repository.dart';
import 'package:shopmanager/data/repositories/worker_repository.dart';
import 'package:shopmanager/data/repositories/worker_wage_repository.dart';
import 'package:shopmanager/data/repositories/worker_cutting_repository.dart';

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
  late WorkerRepository workerRepo;
  late WorkerWageRepository wageRepo;
  late WorkerCuttingRepository cuttingRepo;
  late BillingRepository billingRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    customerRepo = CustomerRepository(db);
    itemRepo = ItemRepository(db);
    workerRepo = WorkerRepository(db);
    wageRepo = WorkerWageRepository(db);
    cuttingRepo = WorkerCuttingRepository(db);
    billingRepo = BillingRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SECTION 2 Audit Tests — Customer Advance / Credit System', () {
    test('Example 1: Bill ₹5,000, payment ₹3,000 -> remaining ₹2,000, status Partial', () async {
      final custId = await customerRepo.addCustomer(name: 'Cust 1', mobile: '9000000001');
      final itemId = await itemRepo.addItem(name: 'Product A', type: 'finished_product', unit: 'pcs', purchaseRate: 100, sellingRate: 5000, openingQty: 10);

      final billNumber = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 5000)],
        amountReceived: 3000,
      );

      final bills = await billingRepo.getRecentBills(limit: 10);
      final bill = bills.firstWhere((b) => b.billNumber == billNumber);

      expect(bill.grandTotal, equals(5000.0));
      expect(bill.amountPaid, equals(3000.0));
      expect(bill.remainingBalance, equals(2000.0));
      expect(bill.paymentStatus, equals(BillPaymentStatus.partial));

      final advance = await billingRepo.getCustomerAdvanceBalance(custId);
      expect(advance, equals(0.0));
    });

    test('Example 2: Bill ₹5,000, payment ₹5,000 -> status Paid, no advance created', () async {
      final custId = await customerRepo.addCustomer(name: 'Cust 2', mobile: '9000000002');
      final itemId = await itemRepo.addItem(name: 'Product A', type: 'finished_product', unit: 'pcs', purchaseRate: 100, sellingRate: 5000, openingQty: 10);

      final billNumber = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 5000)],
        amountReceived: 5000,
      );

      final bills = await billingRepo.getRecentBills(limit: 10);
      final bill = bills.firstWhere((b) => b.billNumber == billNumber);

      expect(bill.grandTotal, equals(5000.0));
      expect(bill.amountPaid, equals(5000.0));
      expect(bill.remainingBalance, equals(0.0));
      expect(bill.paymentStatus, equals(BillPaymentStatus.paid));

      final advance = await billingRepo.getCustomerAdvanceBalance(custId);
      expect(advance, equals(0.0));
    });

    test('Example 3: Bill ₹5,000, payment ₹6,000 -> status Paid, ₹1,000 becomes Advance Held', () async {
      final custId = await customerRepo.addCustomer(name: 'Cust 3', mobile: '9000000003');
      final itemId = await itemRepo.addItem(name: 'Product A', type: 'finished_product', unit: 'pcs', purchaseRate: 100, sellingRate: 5000, openingQty: 10);

      final billNumber = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 5000)],
        amountReceived: 5000,
      );

      final bills = await billingRepo.getRecentBills(limit: 10);
      final bill = bills.firstWhere((b) => b.billNumber == billNumber);

      await billingRepo.recordPaymentForBill(
        billId: bill.id,
        amount: 1000,
        method: 'cash',
      );

      final advance = await billingRepo.getCustomerAdvanceBalance(custId);
      expect(advance, equals(1000.0));
    });

    test('Example 4: Standalone ₹2,000 advance deposit, no bill -> Advance Held = ₹2,000', () async {
      final custId = await customerRepo.addCustomer(name: 'Cust 4', mobile: '9000000004');

      await billingRepo.recordAdvanceDeposit(
        customerId: custId,
        amount: 2000,
        method: 'Cash',
      );

      final advance = await billingRepo.getCustomerAdvanceBalance(custId);
      expect(advance, equals(2000.0));
    });

    test('Example 5: ₹2,000 advance + new ₹5,000 bill, full advance applied -> bill remaining ₹3,000, advance becomes ₹0', () async {
      final custId = await customerRepo.addCustomer(name: 'Cust 5', mobile: '9000000005');
      final itemId = await itemRepo.addItem(name: 'Product A', type: 'finished_product', unit: 'pcs', purchaseRate: 100, sellingRate: 5000, openingQty: 10);

      await billingRepo.recordAdvanceDeposit(
        customerId: custId,
        amount: 2000,
        method: 'Cash',
      );

      final billNumber = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 5000)],
        advanceToApply: 2000,
      );

      final bills = await billingRepo.getRecentBills(limit: 10);
      final bill = bills.firstWhere((b) => b.billNumber == billNumber);

      expect(bill.grandTotal, equals(5000.0));
      expect(bill.amountPaid, equals(2000.0));
      expect(bill.remainingBalance, equals(3000.0));
      expect(bill.paymentStatus, equals(BillPaymentStatus.partial));

      final advance = await billingRepo.getCustomerAdvanceBalance(custId);
      expect(advance, equals(0.0));
    });

    test('Example 6: ₹2,000 advance + new ₹1,500 bill, full advance applied -> bill fully paid, advance correctly becomes ₹500', () async {
      final custId = await customerRepo.addCustomer(name: 'Cust 6', mobile: '9000000006');
      final itemId = await itemRepo.addItem(name: 'Product B', type: 'finished_product', unit: 'pcs', purchaseRate: 100, sellingRate: 1500, openingQty: 10);

      await billingRepo.recordAdvanceDeposit(
        customerId: custId,
        amount: 2000,
        method: 'Cash',
      );

      final billNumber = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 1500)],
        advanceToApply: 1500,
      );

      final bills = await billingRepo.getRecentBills(limit: 10);
      final bill = bills.firstWhere((b) => b.billNumber == billNumber);

      expect(bill.grandTotal, equals(1500.0));
      expect(bill.amountPaid, equals(1500.0));
      expect(bill.remainingBalance, equals(0.0));
      expect(bill.paymentStatus, equals(BillPaymentStatus.paid));

      final advance = await billingRepo.getCustomerAdvanceBalance(custId);
      expect(advance, equals(500.0));
    });

    test('Example 7: Void a bill that had advance applied -> advance becomes available again', () async {
      final custId = await customerRepo.addCustomer(name: 'Cust 7', mobile: '9000000007');
      final itemId = await itemRepo.addItem(name: 'Product A', type: 'finished_product', unit: 'pcs', purchaseRate: 100, sellingRate: 5000, openingQty: 10);

      await billingRepo.recordAdvanceDeposit(
        customerId: custId,
        amount: 2000,
        method: 'Cash',
      );

      final billNumber = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 5000)],
        advanceToApply: 2000,
      );

      final bills = await billingRepo.getRecentBills(limit: 10);
      final bill = bills.firstWhere((b) => b.billNumber == billNumber);

      expect(await billingRepo.getCustomerAdvanceBalance(custId), equals(0.0));

      await billingRepo.voidBill(billId: bill.id, reason: 'Customer cancelled');

      final advanceAfterVoid = await billingRepo.getCustomerAdvanceBalance(custId);
      expect(advanceAfterVoid, equals(2000.0));
    });

    test('Example 8: Void a bill that had real cash payment -> payment NOT reversed, cash becomes advance credit held', () async {
      final custId = await customerRepo.addCustomer(name: 'Cust 8', mobile: '9000000008');
      final itemId = await itemRepo.addItem(name: 'Product A', type: 'finished_product', unit: 'pcs', purchaseRate: 100, sellingRate: 5000, openingQty: 10);

      final billNumber = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 5000)],
        amountReceived: 3000,
      );

      final bills = await billingRepo.getRecentBills(limit: 10);
      final bill = bills.firstWhere((b) => b.billNumber == billNumber);

      await billingRepo.voidBill(billId: bill.id, reason: 'Wrong bill');

      // Cash payment recorded is retained, and void credits grandTotal -> customer now holds ₹3,000 advance balance!
      final advance = await billingRepo.getCustomerAdvanceBalance(custId);
      expect(advance, equals(3000.0));
    });
  });

  group('SECTION 3 Audit Tests — Stock & Worker Cutting', () {
    test('Worked example: opening Black=500, Red=300, Blue=200 (nag); after cutting 50 Black, 30 Red, 40 Blue, 20 Black -> Black=430, Red=270, Blue=160', () async {
      final blackId = await itemRepo.addItem(name: 'Black Cloth', type: 'raw_material', unit: 'nag', purchaseRate: 10, sellingRate: 15, openingQty: 500);
      final redId = await itemRepo.addItem(name: 'Red Cloth', type: 'raw_material', unit: 'nag', purchaseRate: 10, sellingRate: 15, openingQty: 300);
      final blueId = await itemRepo.addItem(name: 'Blue Cloth', type: 'raw_material', unit: 'nag', purchaseRate: 10, sellingRate: 15, openingQty: 200);

      final workerId = await workerRepo.addWorker(name: 'Worker 1');

      await cuttingRepo.addCuttingEntry(workerId: workerId, itemId: blackId, date: DateTime.now(), quantity: 50, rate: 10);
      await cuttingRepo.addCuttingEntry(workerId: workerId, itemId: redId, date: DateTime.now(), quantity: 30, rate: 10);
      await cuttingRepo.addCuttingEntry(workerId: workerId, itemId: blueId, date: DateTime.now(), quantity: 40, rate: 10);
      await cuttingRepo.addCuttingEntry(workerId: workerId, itemId: blackId, date: DateTime.now(), quantity: 20, rate: 10);

      final blackItem = await itemRepo.getItemById(blackId);
      final redItem = await itemRepo.getItemById(redId);
      final blueItem = await itemRepo.getItemById(blueId);

      expect(blackItem!.currentQty, equals(430.0));
      expect(redItem!.currentQty, equals(270.0));
      expect(blueItem!.currentQty, equals(160.0));

      final entries = await cuttingRepo.getCuttingEntriesForWorker(workerId);
      final blackEntries = entries.where((e) => e.entry.itemId == blackId).toList();
      expect(blackEntries.length, equals(2));
      expect(blackEntries[0].entry.quantity, equals(20.0));
      expect(blackEntries[1].entry.quantity, equals(50.0));
    });
  });

  group('SECTION 4 Audit Tests — Worker Payment / Wages', () {
    test('Worked examples: Hour-only, Piece-only, Both, Rate override, Advance cap', () async {
      // Hour-only worker
      final hourWorkerId = await workerRepo.addWorker(
        name: 'Hour Worker',
        paymentType: 'hour',
        defaultHourRate: 100.0,
      );
      // Piece-only worker
      final pieceWorkerId = await workerRepo.addWorker(
        name: 'Piece Worker',
        paymentType: 'piece',
        defaultNagRate: 10.0,
      );
      // Both worker
      final bothWorkerId = await workerRepo.addWorker(
        name: 'Both Worker',
        paymentType: 'both',
        defaultHourRate: 100.0,
        defaultNagRate: 10.0,
      );

      // 1. Hour-only: 8 hours * 100 = 800
      await wageRepo.addWorkEntry(
        workerId: hourWorkerId,
        date: DateTime.now(),
        hours: 8.0,
        hourRate: 100.0,
      );
      final hourSummary = await wageRepo.getWorkerWageSummary(hourWorkerId);
      expect(hourSummary.totalEarnings, equals(800.0));

      // 2. Piece-only: 50 * 10 = 500
      await wageRepo.addWorkEntry(
        workerId: pieceWorkerId,
        date: DateTime.now(),
        nagQty: 50,
        nagRate: 10.0,
      );
      final pieceSummary = await wageRepo.getWorkerWageSummary(pieceWorkerId);
      expect(pieceSummary.totalEarnings, equals(500.0));

      // 3. Both: 5h*100 + 30pc*10 = 800
      await wageRepo.addWorkEntry(
        workerId: bothWorkerId,
        date: DateTime.now(),
        hours: 5.0,
        hourRate: 100.0,
        nagQty: 30,
        nagRate: 10.0,
      );
      final bothSummary = await wageRepo.getWorkerWageSummary(bothWorkerId);
      expect(bothSummary.totalEarnings, equals(800.0));

      // 4. Rate override: 2h * 150 (override) = 300 on hour worker
      await wageRepo.addWorkEntry(
        workerId: hourWorkerId,
        date: DateTime.now(),
        hours: 2.0,
        hourRate: 150.0,
      );

      final worker = await workerRepo.getWorkerById(hourWorkerId);
      expect(worker!.defaultHourRate, equals(100.0)); // Default rate unchanged!

      // 5. Advance 300 on an 800 entry -> Final Payable 500, status Partial
      await wageRepo.addWorkEntry(
        workerId: hourWorkerId,
        date: DateTime.now(),
        hours: 8.0,
        hourRate: 100.0,
        advance: 300.0,
      );

      final summary = await wageRepo.getWorkerWageSummary(hourWorkerId);
      expect(summary.totalEarnings, equals(800 + 300 + 800)); // 1900
      expect(summary.totalAdvance, equals(300.0));
      expect(summary.remainingAmount, equals(1600.0));

      // 6. Test advance > totalAmount rejection
      expect(
        () => wageRepo.addWorkEntry(
          workerId: hourWorkerId,
          date: DateTime.now(),
          hours: 2.0, // Earns 200
          hourRate: 100.0,
          advance: 500.0, // Advance > Earned!
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test("'Both' payment type worker allows hours-only, piece-only, or both, but rejects empty entries", () async {
      final workerId = await workerRepo.addWorker(
        name: 'Flexible Worker',
        paymentType: 'both',
        defaultHourRate: 150.0,
        defaultNagRate: 12.0,
      );

      // Hours-only entry (4h * 150 = 600)
      await wageRepo.addWorkEntry(
        workerId: workerId,
        date: DateTime.now(),
        hours: 4.0,
        hourRate: 150.0,
      );

      // Piece-only entry (20pc * 12 = 240)
      await wageRepo.addWorkEntry(
        workerId: workerId,
        date: DateTime.now(),
        nagQty: 20.0,
        nagRate: 12.0,
      );

      final summary = await wageRepo.getWorkerWageSummary(workerId);
      expect(summary.totalHours, equals(4.0));
      expect(summary.totalNag, equals(20.0));
      expect(summary.totalEarnings, equals(840.0)); // 600 + 240

      // Rejects entry with neither hours nor nagQty
      expect(
        () => wageRepo.addWorkEntry(
          workerId: workerId,
          date: DateTime.now(),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('SECTION 5 Audit Tests — Billing & GST', () {
    test('GST Example 1: Subtotal ₹1000, GST 18% -> Taxable ₹1000, GST ₹180, Grand Total ₹1180', () async {
      final custId = await customerRepo.addCustomer(name: 'GST Cust 1', mobile: '9111111111');
      final itemId = await itemRepo.addItem(name: 'Item GST 1', type: 'finished_product', unit: 'pcs', purchaseRate: 500, sellingRate: 1000, openingQty: 10);

      final billNumber = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 1000)],
        gstEnabled: true,
        gstPercent: 18.0,
      );

      final bills = await billingRepo.getRecentBills(limit: 10);
      final bill = bills.firstWhere((b) => b.billNumber == billNumber);

      expect(bill.taxableAmount, equals(1000.0));
      expect(bill.gstAmount, equals(180.0));
      expect(bill.grandTotal, equals(1180.0));
    });

    test('GST Example 2: Subtotal ₹1000, Discount ₹100, Other ₹50, GST 12% -> Taxable ₹950, GST ₹114, Grand Total ₹1064', () async {
      final custId = await customerRepo.addCustomer(name: 'GST Cust 2', mobile: '9222222222');
      final itemId = await itemRepo.addItem(name: 'Item GST 2', type: 'finished_product', unit: 'pcs', purchaseRate: 500, sellingRate: 1000, openingQty: 10);

      final billNumber = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 1000)],
        discount: 100,
        otherCharges: 50,
        gstEnabled: true,
        gstPercent: 12.0,
      );

      final bills = await billingRepo.getRecentBills(limit: 10);
      final bill = bills.firstWhere((b) => b.billNumber == billNumber);

      expect(bill.taxableAmount, equals(950.0));
      expect(bill.gstAmount, equals(114.0));
      expect(bill.grandTotal, equals(1064.0));
    });

    test('GST + Advance applied caps against GST-INCLUSIVE grand total (₹1180)', () async {
      final custId = await customerRepo.addCustomer(name: 'GST Advance Cust', mobile: '9333333333');
      final itemId = await itemRepo.addItem(name: 'Item GST 3', type: 'finished_product', unit: 'pcs', purchaseRate: 500, sellingRate: 1000, openingQty: 10);

      await billingRepo.recordAdvanceDeposit(
        customerId: custId,
        amount: 2000,
        method: 'Cash',
      );

      final billNumber = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 1000)],
        gstEnabled: true,
        gstPercent: 18.0,
        advanceToApply: 1180,
      );

      final bills = await billingRepo.getRecentBills(limit: 10);
      final bill = bills.firstWhere((b) => b.billNumber == billNumber);

      expect(bill.grandTotal, equals(1180.0));
      expect(bill.amountPaid, equals(1180.0));
      expect(bill.paymentStatus, equals(BillPaymentStatus.paid));

      final advanceRemaining = await billingRepo.getCustomerAdvanceBalance(custId);
      expect(advanceRemaining, equals(820.0));
    });

    test('3-Way Bill Status Consistency Check on GST-Enabled Bill', () async {
      final custId = await customerRepo.addCustomer(name: 'Status Check Cust', mobile: '9444444444');
      final itemId = await itemRepo.addItem(name: 'Item Status', type: 'finished_product', unit: 'pcs', purchaseRate: 500, sellingRate: 1000, openingQty: 10);

      final billNumber = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 1000)],
        gstEnabled: true,
        gstPercent: 18.0,
        amountReceived: 1180.0,
      );

      final bills = await billingRepo.watchAllBills().first;
      final bill = bills.firstWhere((b) => b.billNumber == billNumber);

      final billDetail = await billingRepo.getBillDetail(bill.id);

      expect(bill.paymentStatus, equals(BillPaymentStatus.paid));
      expect(billDetail!.bill.paymentStatus, equals(BillPaymentStatus.paid));
      expect(billDetail.bill.remainingBalance, equals(0.0));
    });
  });
}
