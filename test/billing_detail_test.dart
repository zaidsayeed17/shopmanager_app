import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:shopmanager/data/db/app_database.dart';
import 'package:shopmanager/data/models/bill_model.dart';
import 'package:shopmanager/data/repositories/customer_repository.dart';
import 'package:shopmanager/data/repositories/item_repository.dart';
import 'package:shopmanager/data/repositories/billing_repository.dart';

void main() {
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

  group('Bill Detail (Record Payment & Void Bill) Tests', () {
    test('(a) recordPaymentForBill reduces remainingBalance correctly and adds a payment + ledger credit row', () async {
      final customerId = await customerRepo.addCustomer(
        name: 'Sharma Fabricators',
        mobile: '9820144512',
        openingBalance: 0.0,
      );
      final itemId = await itemRepo.addItem(
        name: 'Hex Bolts',
        type: 'finished_product',
        unit: 'pcs',
        openingQty: 200,
        sellingRate: 15.0,
      );

      await billingRepo.saveBill(
        customerId: customerId,
        billDate: DateTime(2026, 9, 29),
        lines: [BillLine(itemId: itemId, quantity: 100, rate: 15.0)], // 1500
        amountReceived: 0.0,
      );

      final bills = await db.select(db.bills).get();
      final billId = bills.first.id;

      expect(bills.first.remainingBalance, equals(1500.0));
      expect(bills.first.amountPaid, equals(0.0));

      // Record payment of ₹500
      await billingRepo.recordPaymentForBill(
        billId: billId,
        amount: 500.0,
        method: 'UPI',
        notes: 'Partial payment',
      );

      // Re-fetch bill and check balance
      final updatedBill = (await db.select(db.bills).get()).first;
      expect(updatedBill.amountPaid, equals(500.0));
      expect(updatedBill.remainingBalance, equals(1000.0));

      // Check payments table
      final payments = await db.select(db.payments).get();
      expect(payments.length, equals(1));
      expect(payments.first.amount, equals(500.0));
      expect(payments.first.method, equals('UPI'));
      expect(payments.first.billId, equals(billId));

      // Check ledgerEntries table (1 bill debit 1500 + 1 payment credit 500 = running balance 1000)
      final ledger = await db.select(db.ledgerEntries).get();
      expect(ledger.length, equals(2));
      expect(ledger.last.type, equals('payment'));
      expect(ledger.last.credit, equals(500.0));
      expect(ledger.last.debit, equals(0.0));
      expect(ledger.last.runningBalance, equals(1000.0));
    });

    test('(b) recordPaymentForBill rejects an amount greater than the current remaining balance', () async {
      final customerId = await customerRepo.addCustomer(
        name: 'Apex Tools',
        mobile: '9820144513',
      );
      final itemId = await itemRepo.addItem(
        name: 'Angle Grinder',
        type: 'finished_product',
        unit: 'pcs',
        openingQty: 50,
        sellingRate: 1000.0,
      );

      await billingRepo.saveBill(
        customerId: customerId,
        billDate: DateTime(2026, 9, 29),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 1000.0)],
        amountReceived: 0.0,
      );

      final billId = (await db.select(db.bills).get()).first.id;

      // Record payment of ₹1500 against ₹1000 remaining balance (overpayment creates advance deposit)
      await billingRepo.recordPaymentForBill(
        billId: billId,
        amount: 1500.0,
        method: 'Cash',
      );

      final billDetail = await billingRepo.getBillDetail(billId);
      expect(billDetail!.bill.remainingBalance, equals(0.0));
      expect(billDetail.bill.amountPaid, equals(1000.0));

      final advanceBal = await billingRepo.getCustomerAdvanceBalance(customerId);
      expect(advanceBal, equals(500.0));
    });

    test('(c) voidBill on a bill with no payments: item stock is restored to pre-bill level, 1 offsetting ledger credit row is added equal to grandTotal, running balance decreases by grandTotal, status becomes void, original rows unchanged', () async {
      final customerId = await customerRepo.addCustomer(
        name: 'Maruti Works',
        mobile: '9820144514',
      );
      final itemId = await itemRepo.addItem(
        name: 'Cutting Oil',
        type: 'raw_material',
        unit: 'L',
        openingQty: 100,
        sellingRate: 200.0,
      );

      final initialStock = (await itemRepo.getItemById(itemId))!.currentQty; // 100
      expect(initialStock, equals(100.0));

      await billingRepo.saveBill(
        customerId: customerId,
        billDate: DateTime(2026, 9, 29),
        lines: [BillLine(itemId: itemId, quantity: 20, rate: 200.0)], // grandTotal = 4000
        amountReceived: 0.0,
      );

      final stockAfterBill = (await itemRepo.getItemById(itemId))!.currentQty; // 80
      expect(stockAfterBill, equals(80.0));

      final billId = (await db.select(db.bills).get()).first.id;

      // Void the bill
      await billingRepo.voidBill(
        billId: billId,
        reason: 'Wrong item billed',
      );

      // Check item currentQty is restored to 100
      final stockAfterVoid = (await itemRepo.getItemById(itemId))!.currentQty;
      expect(stockAfterVoid, equals(100.0));

      // Check stockTransactions has a reversal entry (+20)
      final stockTxs = await db.select(db.stockTransactions).get();
      final voidStockTx = stockTxs.firstWhere((t) => t.referenceType == 'bill_void');
      expect(voidStockTx.quantity, equals(20.0));
      expect(voidStockTx.type, equals('adjustment_increase'));

      // Check ledgerEntries has offsetting credit row equal to grandTotal (4000)
      final ledgerEntries = await db.select(db.ledgerEntries).get();
      expect(ledgerEntries.length, equals(2)); // original bill debit 4000 + void credit 4000
      final voidLedger = ledgerEntries.last;
      expect(voidLedger.type, equals('bill'));
      expect(voidLedger.credit, equals(4000.0));
      expect(voidLedger.debit, equals(0.0));
      expect(voidLedger.runningBalance, equals(0.0)); // 4000 - 4000 = 0

      // Check bill status, voidReason, and voidedAt
      final bill = (await db.select(db.bills).get()).first;
      expect(bill.status, equals('void'));
      expect(bill.voidReason, equals('Wrong item billed'));
      expect(bill.voidedAt, isNotNull);

      // Original bill line item unchanged
      final billItems = await db.select(db.billItems).get();
      expect(billItems.length, equals(1));
      expect(billItems.first.quantity, equals(20.0));
    });

    test('(d) voidBill on a bill that HAD a partial payment: stock is fully restored, bill debit is reversed, but payment ledger credit is untouched', () async {
      final customerId = await customerRepo.addCustomer(
        name: 'Vanguard Traders',
        mobile: '9820144515',
      );
      final itemId = await itemRepo.addItem(
        name: 'Welding Rods',
        type: 'raw_material',
        unit: 'pkts',
        openingQty: 50,
        sellingRate: 500.0,
      );

      await billingRepo.saveBill(
        customerId: customerId,
        billDate: DateTime(2026, 9, 29),
        lines: [BillLine(itemId: itemId, quantity: 10, rate: 500.0)], // grandTotal = 5000
        amountReceived: 2000.0, // Partial payment ₹2000
      );

      final itemAfterBill = (await itemRepo.getItemById(itemId))!.currentQty;
      expect(itemAfterBill, equals(40.0));

      final billId = (await db.select(db.bills).get()).first.id;

      // Customer ledger after bill + payment: debit 5000, credit 2000 -> running balance = 3000
      final ledgerBeforeVoid = await billingRepo.getCustomerLedgerSummary(customerId);
      expect(ledgerBeforeVoid, equals(3000.0));

      // Void bill
      await billingRepo.voidBill(
        billId: billId,
        reason: 'Customer cancelled order after partial payment',
      );

      // Stock fully restored to 50
      final itemAfterVoid = (await itemRepo.getItemById(itemId))!.currentQty;
      expect(itemAfterVoid, equals(50.0));

      // Customer ledger: original bill debit 5000 + payment credit 2000 + void credit 5000 = net balance -2000 (credit/advance)
      final ledgerAfterVoid = await billingRepo.getCustomerLedgerSummary(customerId);
      expect(ledgerAfterVoid, equals(-2000.0));

      // Payment row & ledger entry remain intact
      final payments = await db.select(db.payments).get();
      expect(payments.length, equals(1));
      expect(payments.first.amount, equals(2000.0));

      // Bill status flagged void
      final bill = (await db.select(db.bills).get()).first;
      expect(bill.status, equals('void'));
    });

    test('(e) voiding an already-void bill is rejected', () async {
      final customerId = await customerRepo.addCustomer(
        name: 'Test Customer E',
        mobile: '9820144516',
      );
      final itemId = await itemRepo.addItem(
        name: 'Test Item E',
        type: 'finished_product',
        unit: 'pcs',
        openingQty: 10,
        sellingRate: 100.0,
      );

      await billingRepo.saveBill(
        customerId: customerId,
        billDate: DateTime(2026, 9, 29),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 100.0)],
      );

      final billId = (await db.select(db.bills).get()).first.id;

      // First void
      await billingRepo.voidBill(billId: billId, reason: 'First void');

      // Second void attempt
      expect(
        () async => await billingRepo.voidBill(billId: billId, reason: 'Second void attempt'),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('This bill is already voided'),
        )),
      );
    });

    test('(f) recording a payment against a voided bill is rejected', () async {
      final customerId = await customerRepo.addCustomer(
        name: 'Test Customer F',
        mobile: '9820144517',
      );
      final itemId = await itemRepo.addItem(
        name: 'Test Item F',
        type: 'finished_product',
        unit: 'pcs',
        openingQty: 10,
        sellingRate: 100.0,
      );

      await billingRepo.saveBill(
        customerId: customerId,
        billDate: DateTime(2026, 9, 29),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 100.0)],
      );

      final billId = (await db.select(db.bills).get()).first.id;

      // Void bill
      await billingRepo.voidBill(billId: billId, reason: 'Voided before payment');

      // Attempt to record payment against voided bill
      expect(
        () async => await billingRepo.recordPaymentForBill(
          billId: billId,
          amount: 50.0,
          method: 'Cash',
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('Cannot record a payment against a voided bill'),
        )),
      );
    });
  });

  group('Bill Payment Status & Filtering Tests', () {
    test('computeBillStatus correctly classifies Paid, Partial, Unpaid, and Voided bills', () {
      expect(
        computeBillStatus(status: 'active', remainingBalance: 0.0, grandTotal: 100.0, amountPaid: 100.0),
        equals(BillPaymentStatus.paid),
      );

      expect(
        computeBillStatus(status: 'active', remainingBalance: 0.0005, grandTotal: 100.0, amountPaid: 99.9995),
        equals(BillPaymentStatus.paid),
      );

      expect(
        computeBillStatus(status: 'active', remainingBalance: 40.0, grandTotal: 100.0, amountPaid: 60.0),
        equals(BillPaymentStatus.partial),
      );

      expect(
        computeBillStatus(status: 'active', remainingBalance: 100.0, grandTotal: 100.0, amountPaid: 0.0),
        equals(BillPaymentStatus.unpaid),
      );

      expect(
        computeBillStatus(status: 'void', remainingBalance: 0.0, grandTotal: 100.0, amountPaid: 100.0),
        equals(BillPaymentStatus.voided),
      );

      expect(
        computeBillStatus(status: 'void', remainingBalance: 100.0, grandTotal: 100.0, amountPaid: 0.0),
        equals(BillPaymentStatus.voided),
      );
    });

    test('getAllBills correctly returns models that bucket into Unpaid, Partial, Paid, and Voided', () async {
      final customerId = await customerRepo.addCustomer(name: 'Bucketing Customer', mobile: '9998887776');
      final itemId = await itemRepo.addItem(
        name: 'Bucketing Item',
        type: 'finished_product',
        unit: 'pcs',
        openingQty: 1000,
        sellingRate: 10.0,
      );

      // 1. Unpaid Bill
      await billingRepo.saveBill(
        customerId: customerId,
        billDate: DateTime(2026, 10, 1),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 10.0)],
        amountReceived: 0.0,
      );

      // 2. Partial Bill
      await billingRepo.saveBill(
        customerId: customerId,
        billDate: DateTime(2026, 10, 1),
        lines: [BillLine(itemId: itemId, quantity: 2, rate: 10.0)],
        amountReceived: 5.0,
      );

      // 3. Fully Paid Bill
      await billingRepo.saveBill(
        customerId: customerId,
        billDate: DateTime(2026, 10, 1),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 14.0)],
        amountReceived: 14.0,
      );

      // 4. Voided Bill
      final voidNum = await billingRepo.saveBill(
        customerId: customerId,
        billDate: DateTime(2026, 10, 1),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 20.0)],
        amountReceived: 0.0,
      );
      final allDbBills = await db.select(db.bills).get();
      final voidId = allDbBills.firstWhere((b) => b.billNumber == voidNum).id;
      await billingRepo.voidBill(billId: voidId, reason: 'Test void bucket');

      final allModels = await billingRepo.getAllBills();
      expect(allModels.length, equals(4));

      final unpaidCount = allModels.where((b) => b.paymentStatus == BillPaymentStatus.unpaid).length;
      final partialCount = allModels.where((b) => b.paymentStatus == BillPaymentStatus.partial).length;
      final paidCount = allModels.where((b) => b.paymentStatus == BillPaymentStatus.paid).length;
      final voidedCount = allModels.where((b) => b.paymentStatus == BillPaymentStatus.voided).length;

      expect(unpaidCount, equals(1));
      expect(partialCount, equals(1));
      expect(paidCount, equals(1));
      expect(voidedCount, equals(1));
    });
  });
}
