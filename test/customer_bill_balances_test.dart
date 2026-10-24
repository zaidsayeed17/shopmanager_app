import 'dart:io';
import 'package:drift/native.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopmanager/data/db/app_database.dart';
import 'package:shopmanager/data/models/bill_model.dart';
import 'package:shopmanager/data/repositories/billing_repository.dart';
import 'package:shopmanager/data/repositories/customer_repository.dart';
import 'package:shopmanager/data/repositories/item_repository.dart';
import 'package:shopmanager/services/excel_export_service.dart';
import 'package:shopmanager/services/pdf_service.dart';

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
  late ExcelExportService exportService;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    customerRepo = CustomerRepository(db);
    itemRepo = ItemRepository(db);
    billingRepo = BillingRepository(db);
    exportService = ExcelExportService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Part 5: Customer Bill Balances Regression & Verification Tests', () {
    // 1. Reported case: advance 100, bill 10, advance fully applied, no cash
    test('1. Reported case: advance 100, bill 10, advance applied 10, cash 0 -> previous -100, current -90, advance 90, 1 bill debit ledger row', () async {
      final custId = await customerRepo.addCustomer(name: 'Cust 1', mobile: '9000000001');
      await billingRepo.recordAdvanceDeposit(customerId: custId, amount: 100.0, method: 'cash');

      final itemId = await itemRepo.addItem(name: 'Item 1', type: 'finished_product', unit: 'pcs', openingQty: 10, sellingRate: 10.0);

      final billNum = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime(2026, 10, 21),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 10.0)],
        advanceToApply: 10.0,
        amountReceived: 0.0,
      );

      final bill = await (db.select(db.bills)..where((t) => t.billNumber.equals(billNum))).getSingle();
      expect(bill.previousOutstandingSnapshot, equals(-100.0));
      expect(bill.currentBalanceSnapshot, equals(-90.0));

      final balances = resolveBillBalancesFromEntity(bill);
      expect(balances.previous, equals(-100.0));
      expect(balances.current, equals(-90.0));
      expect(describeBalance(balances.previous), equals('₹100 Advance'));
      expect(describeBalance(balances.current), equals('₹90 Advance'));

      final advanceAfter = await billingRepo.getCustomerAdvanceBalance(custId);
      expect(advanceAfter, equals(90.0));

      final allLedger = await (db.select(db.ledgerEntries)..where((t) => t.customerId.equals(custId))).get();
      // 1 advance deposit + 1 bill debit = 2 entries total. For this save, only 1 bill debit row was written.
      final billRows = allLedger.where((e) => e.type == 'bill').toList();
      expect(billRows.length, equals(1));
      expect(allLedger.where((e) => e.type == 'payment' && e.referenceId == bill.id).length, equals(0));
    });

    // 2. Advance 100, bill 150, advance applied 100, cash 0 -> remaining 50; previous -100; current +50 (Due 50)
    test('2. Advance 100, bill 150, advance applied 100, cash 0 -> remaining 50; previous -100; current +50 (Due 50)', () async {
      final custId = await customerRepo.addCustomer(name: 'Cust 2', mobile: '9000000002');
      await billingRepo.recordAdvanceDeposit(customerId: custId, amount: 100.0, method: 'upi');

      final itemId = await itemRepo.addItem(name: 'Item 2', type: 'finished_product', unit: 'pcs', openingQty: 10, sellingRate: 150.0);

      final billNum = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime(2026, 10, 21),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 150.0)],
        advanceToApply: 100.0,
        amountReceived: 0.0,
      );

      final bill = await (db.select(db.bills)..where((t) => t.billNumber.equals(billNum))).getSingle();
      expect(bill.remainingBalance, equals(50.0));
      expect(bill.previousOutstandingSnapshot, equals(-100.0));
      expect(bill.currentBalanceSnapshot, equals(50.0));

      final balances = resolveBillBalancesFromEntity(bill);
      expect(describeBalance(balances.previous), equals('₹100 Advance'));
      expect(describeBalance(balances.current), equals('₹50 Due'));
    });

    // 3. Advance 100, bill 150, advance applied 100, cash 50 -> remaining 0; current 0 (no label)
    test('3. Advance 100, bill 150, advance applied 100, cash 50 -> remaining 0; current 0 (no label)', () async {
      final custId = await customerRepo.addCustomer(name: 'Cust 3', mobile: '9000000003');
      await billingRepo.recordAdvanceDeposit(customerId: custId, amount: 100.0, method: 'upi');

      final itemId = await itemRepo.addItem(name: 'Item 3', type: 'finished_product', unit: 'pcs', openingQty: 10, sellingRate: 150.0);

      final billNum = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime(2026, 10, 21),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 150.0)],
        advanceToApply: 100.0,
        amountReceived: 50.0,
      );

      final bill = await (db.select(db.bills)..where((t) => t.billNumber.equals(billNum))).getSingle();
      expect(bill.remainingBalance, equals(0.0));
      expect(bill.currentBalanceSnapshot, equals(0.0));

      final balances = resolveBillBalancesFromEntity(bill);
      expect(describeBalance(balances.current), equals('₹0.00'));
    });

    // 4. Advance 100 but NOT applied: bill 10, cash 10 -> current -100 (advance unchanged)
    test('4. Advance 100 not applied: bill 10, cash 10 -> current -100 (advance unchanged)', () async {
      final custId = await customerRepo.addCustomer(name: 'Cust 4', mobile: '9000000004');
      await billingRepo.recordAdvanceDeposit(customerId: custId, amount: 100.0, method: 'cash');

      final itemId = await itemRepo.addItem(name: 'Item 4', type: 'finished_product', unit: 'pcs', openingQty: 10, sellingRate: 10.0);

      final billNum = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime(2026, 10, 21),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 10.0)],
        advanceToApply: 0.0,
        amountReceived: 10.0,
      );

      final bill = await (db.select(db.bills)..where((t) => t.billNumber.equals(billNum))).getSingle();
      expect(bill.previousOutstandingSnapshot, equals(-100.0));
      expect(bill.currentBalanceSnapshot, equals(-100.0));
      expect(await billingRepo.getCustomerAdvanceBalance(custId), equals(100.0));
    });

    // 5. No advance: previous due 200, bill 500, cash 300 -> previous +200, current +400
    test('5. No advance: previous due 200, bill 500, cash 300 -> previous +200, current +400', () async {
      final custId = await customerRepo.addCustomer(name: 'Cust 5', mobile: '9000000005', openingBalance: 200.0);

      final itemId = await itemRepo.addItem(name: 'Item 5', type: 'finished_product', unit: 'pcs', openingQty: 10, sellingRate: 500.0);

      final billNum = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime(2026, 10, 21),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 500.0)],
        amountReceived: 300.0,
      );

      final bill = await (db.select(db.bills)..where((t) => t.billNumber.equals(billNum))).getSingle();
      expect(bill.previousOutstandingSnapshot, equals(200.0));
      expect(bill.currentBalanceSnapshot, equals(400.0));

      final balances = resolveBillBalancesFromEntity(bill);
      expect(describeBalance(balances.previous), equals('₹200 Due'));
      expect(describeBalance(balances.current), equals('₹400 Due'));
    });

    // 6. Fresh customer, bill 500, nothing paid -> previous 0, current +500
    test('6. Fresh customer, bill 500, nothing paid -> previous 0, current +500', () async {
      final custId = await customerRepo.addCustomer(name: 'Cust 6', mobile: '9000000006', openingBalance: 0.0);
      final itemId = await itemRepo.addItem(name: 'Item 6', type: 'finished_product', unit: 'pcs', openingQty: 10, sellingRate: 500.0);

      final billNum = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime(2026, 10, 21),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 500.0)],
        amountReceived: 0.0,
      );

      final bill = await (db.select(db.bills)..where((t) => t.billNumber.equals(billNum))).getSingle();
      expect(bill.previousOutstandingSnapshot, equals(0.0));
      expect(bill.currentBalanceSnapshot, equals(500.0));

      final balances = resolveBillBalancesFromEntity(bill);
      expect(describeBalance(balances.previous), equals('₹0.00'));
      expect(describeBalance(balances.current), equals('₹500 Due'));
    });

    // 7. GST-enabled bill with advance applied -> uses GST-inclusive grandTotal; current correct
    test('7. GST-enabled bill with advance applied -> uses GST-inclusive grandTotal; current correct', () async {
      final custId = await customerRepo.addCustomer(name: 'Cust 7', mobile: '9000000007');
      await billingRepo.recordAdvanceDeposit(customerId: custId, amount: 200.0, method: 'bank');

      final itemId = await itemRepo.addItem(name: 'Item 7', type: 'finished_product', unit: 'pcs', openingQty: 10, sellingRate: 100.0);

      // Subtotal 100, GST 18% -> grandTotal 118. Advance applied 100, cash 18
      final billNum = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime(2026, 10, 21),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 100.0)],
        gstEnabled: true,
        gstPercent: 18.0,
        advanceToApply: 100.0,
        amountReceived: 18.0,
      );

      final bill = await (db.select(db.bills)..where((t) => t.billNumber.equals(billNum))).getSingle();
      expect(bill.grandTotal, equals(118.0));
      expect(bill.previousOutstandingSnapshot, equals(-200.0));
      expect(bill.currentBalanceSnapshot, equals(-100.0));
      expect(describeBalance(bill.currentBalanceSnapshot), equals('₹100 Advance'));
    });

    // 8. Two consecutive bills for the same customer: bill 2's previous == bill 1's current
    test('8. Two consecutive bills for the same customer: bill 2 previous == bill 1 current', () async {
      final custId = await customerRepo.addCustomer(name: 'Cust 8', mobile: '9000000008');
      await billingRepo.recordAdvanceDeposit(customerId: custId, amount: 100.0, method: 'cash');

      final itemId = await itemRepo.addItem(name: 'Item 8', type: 'finished_product', unit: 'pcs', openingQty: 10, sellingRate: 30.0);

      // Bill 1: 30, paid from advance 30 -> current should be -70
      final bill1Num = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime(2026, 10, 21),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 30.0)],
        advanceToApply: 30.0,
        amountReceived: 0.0,
      );
      final bill1 = await (db.select(db.bills)..where((t) => t.billNumber.equals(bill1Num))).getSingle();

      // Bill 2: 20, paid from advance 20 -> previous should be -70, current -50
      final bill2Num = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime(2026, 10, 21),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 20.0)],
        advanceToApply: 20.0,
        amountReceived: 0.0,
      );
      final bill2 = await (db.select(db.bills)..where((t) => t.billNumber.equals(bill2Num))).getSingle();

      expect(bill2.previousOutstandingSnapshot, equals(bill1.currentBalanceSnapshot));
      expect(bill2.previousOutstandingSnapshot, equals(-70.0));
      expect(bill2.currentBalanceSnapshot, equals(-50.0));
    });

    // 9. Consistency: for the customer's most recent bill, currentBalanceSnapshot == customer's signed balance from ledger
    test('9. Consistency: most recent bill currentBalanceSnapshot == customer signed ledger balance', () async {
      final custId = await customerRepo.addCustomer(name: 'Cust 9', mobile: '9000000009', openingBalance: 50.0);
      final itemId = await itemRepo.addItem(name: 'Item 9', type: 'finished_product', unit: 'pcs', openingQty: 10, sellingRate: 120.0);

      final billNum = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime(2026, 10, 21),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 120.0)],
        amountReceived: 70.0,
      );

      final bill = await (db.select(db.bills)..where((t) => t.billNumber.equals(billNum))).getSingle();
      final ledgerBal = await billingRepo.getCustomerLedgerSummary(custId);

      expect(bill.currentBalanceSnapshot, equals(ledgerBal));
      expect(bill.currentBalanceSnapshot, equals(100.0)); // 50 + 120 - 70 = 100
    });

    // 10. Historical bill handling: NULL currentBalanceSnapshot with advanceApplied 0 vs > 0
    test('10. Historical bill: NULL currentBalanceSnapshot fallback matches old formula when advanceApplied 0, and corrected when > 0', () {
      // Historical normal bill: prev = 200, grandTotal = 500, amountPaid = 300, advanceApplied = 0
      final histNormal = resolveBillBalances(
        previousOutstandingSnapshot: 200.0,
        currentBalanceSnapshot: null,
        grandTotal: 500.0,
        amountPaid: 300.0,
        advanceApplied: 0.0,
      );
      // Old formula: 200 + (500 - 300) = 400
      expect(histNormal.current, equals(400.0));

      // Historical advance-era bill: prev = -100, grandTotal = 10, amountPaid = 10 (all advance), advanceApplied = 10
      // Old buggy formula gave: -100 + 0 = -100
      // Corrected fallback gives: -100 + 10 - (10 - 10) = -90
      final histAdvance = resolveBillBalances(
        previousOutstandingSnapshot: -100.0,
        currentBalanceSnapshot: null,
        grandTotal: 10.0,
        amountPaid: 10.0,
        advanceApplied: 10.0,
      );
      expect(histAdvance.current, equals(-90.0));
    });

    // 11. Void a bill after creation -> stored previous/current snapshots remain unchanged
    test('11. Void a bill -> stored previous/current snapshots are immutable', () async {
      final custId = await customerRepo.addCustomer(name: 'Cust 11', mobile: '9000000011');
      await billingRepo.recordAdvanceDeposit(customerId: custId, amount: 100.0, method: 'cash');
      final itemId = await itemRepo.addItem(name: 'Item 11', type: 'finished_product', unit: 'pcs', openingQty: 10, sellingRate: 25.0);

      final billNum = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime(2026, 10, 21),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 25.0)],
        advanceToApply: 25.0,
        amountReceived: 0.0,
      );

      final billBefore = await (db.select(db.bills)..where((t) => t.billNumber.equals(billNum))).getSingle();
      expect(billBefore.previousOutstandingSnapshot, equals(-100.0));
      expect(billBefore.currentBalanceSnapshot, equals(-75.0));

      await billingRepo.voidBill(billId: billBefore.id, reason: 'Void test');

      final billAfter = await (db.select(db.bills)..where((t) => t.billNumber.equals(billNum))).getSingle();
      expect(billAfter.status, equals('void'));
      expect(billAfter.previousOutstandingSnapshot, equals(-100.0));
      expect(billAfter.currentBalanceSnapshot, equals(-75.0));
    });

    // 12. Quick Sale with an existing customer behaves identically; walk-in shows no balance lines
    test('12. Quick Sale with existing customer stores snapshots; walk-in leaves currentBalanceSnapshot null', () async {
      final custId = await customerRepo.addCustomer(name: 'Cust 12', mobile: '9000000012');
      await billingRepo.recordAdvanceDeposit(customerId: custId, amount: 50.0, method: 'upi');
      final itemId = await itemRepo.addItem(name: 'Item 12', type: 'finished_product', unit: 'pcs', openingQty: 10, sellingRate: 15.0);

      // Customer Quick Sale
      final qsCustomerNum = await billingRepo.saveBill(
        customerId: custId,
        saleChannel: 'quick_sale',
        billDate: DateTime(2026, 10, 21),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 15.0)],
        advanceToApply: 15.0,
        amountReceived: 0.0,
      );
      final qsBill = await (db.select(db.bills)..where((t) => t.billNumber.equals(qsCustomerNum))).getSingle();
      expect(qsBill.previousOutstandingSnapshot, equals(-50.0));
      expect(qsBill.currentBalanceSnapshot, equals(-35.0));

      // Walk-in Quick Sale
      final qsWalkInNum = await billingRepo.saveBill(
        customerId: null,
        saleChannel: 'quick_sale',
        billDate: DateTime(2026, 10, 21),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 15.0)],
        amountReceived: 15.0,
      );
      final walkInBill = await (db.select(db.bills)..where((t) => t.billNumber.equals(qsWalkInNum))).getSingle();
      expect(walkInBill.customerId, isNull);
      expect(walkInBill.currentBalanceSnapshot, isNull);

      // Generate PDF for walk-in and customer
      final customerEntity = await (db.select(db.customers)..where((t) => t.id.equals(custId))).getSingle();
      final itemDetails = [BillItemDetail(id: 1, billId: qsBill.id, itemId: itemId, itemName: 'Item 12', quantity: 1, unit: 'pcs', rate: 15.0, amount: 15.0)];

      final customerPdf = await PdfService.generateBillPdf(BillDetailData(
        bill: BillModel.fromEntity(qsBill),
        customer: customerEntity,
        items: itemDetails,
        payments: [],
      ));
      expect(customerPdf, isNotEmpty);

      final walkInPdf = await PdfService.generateBillPdf(BillDetailData(
        bill: BillModel.fromEntity(walkInBill),
        customer: CustomerEntity(
          id: 0,
          name: 'Walk-in Customer',
          mobile: '',
          openingBalance: 0.0,
          isWholesale: false,
          isActive: true,
          createdAt: DateTime.now(),
        ),
        items: itemDetails,
        payments: [],
      ));
      expect(walkInPdf, isNotEmpty);
    });

    // 13. Unit tests for describeBalance (positive, negative, near-zero) and Excel export new columns
    test('13. describeBalance formatting and Excel export balance columns verification', () async {
      // describeBalance unit tests
      expect(describeBalance(0.0), equals('₹0.00'));
      expect(describeBalance(0.002), equals('₹0.00'));
      expect(describeBalance(-0.003), equals('₹0.00'));
      expect(describeBalance(150.0), equals('₹150 Due'));
      expect(describeBalance(150.75), equals('₹150.75 Due'));
      expect(describeBalance(-90.0), equals('₹90 Advance'));
      expect(describeBalance(-90.5), equals('₹90.50 Advance'));

      // Excel export verification
      final custId = await customerRepo.addCustomer(name: 'Cust Excel', mobile: '9000000013');
      await billingRepo.recordAdvanceDeposit(customerId: custId, amount: 100.0, method: 'cash');
      final itemId = await itemRepo.addItem(name: 'Item Excel', type: 'finished_product', unit: 'pcs', openingQty: 10, sellingRate: 10.0);

      await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime(2026, 10, 21),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 10.0)],
        advanceToApply: 10.0,
        amountReceived: 0.0,
      );

      final file = await exportService.exportBills();
      expect(file.existsSync(), isTrue);
      final bytes = file.readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel['Bills'];
      final headerRow = sheet.row(0).map((c) => c?.value?.toString()).toList();

      expect(headerRow, contains('Previous Balance (+Due / −Advance)'));
      expect(headerRow, contains('Current Balance (+Due / −Advance)'));

      final prevIdx = headerRow.indexOf('Previous Balance (+Due / −Advance)');
      final currIdx = headerRow.indexOf('Current Balance (+Due / −Advance)');

      final dataRow1 = sheet.row(1);
      final prevVal = (dataRow1[prevIdx]?.value as dynamic)?.value;
      final currVal = (dataRow1[currIdx]?.value as dynamic)?.value;

      expect((prevVal as num).toDouble(), equals(-100.0));
      expect((currVal as num).toDouble(), equals(-90.0));
    });
  });
}
