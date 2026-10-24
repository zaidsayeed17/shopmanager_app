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

  test('REPRODUCE BUG: Customer with 100 advance buys 10 product, paid from advance', () async {
    final customerId = await customerRepo.addCustomer(
      name: 'Advance Customer',
      mobile: '9876543210',
      openingBalance: 0.0,
    );

    // Record 100 advance deposit
    await billingRepo.recordAdvanceDeposit(
      customerId: customerId,
      amount: 100.0,
      method: 'cash',
    );

    final advanceBefore = await billingRepo.getCustomerAdvanceBalance(customerId);
    final ledgerBefore = await billingRepo.getCustomerLedgerSummary(customerId);
    expect(advanceBefore, equals(100.0));
    expect(ledgerBefore, equals(-100.0));

    final itemId = await itemRepo.addItem(
      name: 'Sample Item',
      type: 'finished_product',
      unit: 'pcs',
      openingQty: 10,
      sellingRate: 10.0,
    );

    // Bill for 10, paid from advance
    final billNum = await billingRepo.saveBill(
      customerId: customerId,
      billDate: DateTime(2026, 10, 20),
      lines: [
        BillLine(itemId: itemId, quantity: 1, rate: 10.0),
      ],
      advanceToApply: 10.0,
      amountReceived: 0.0,
    );

    // Retrieve bill
    final billQuery = db.select(db.bills)..where((t) => t.billNumber.equals(billNum));
    final bill = await billQuery.getSingle();

    // Actual ledger balance after bill
    final ledgerAfter = await billingRepo.getCustomerLedgerSummary(customerId);
    final advanceAfter = await billingRepo.getCustomerAdvanceBalance(customerId);

    // Verify stored snapshot and resolved balances:
    expect(bill.previousOutstandingSnapshot, equals(-100.0));
    expect(bill.currentBalanceSnapshot, equals(-90.0));

    final balances = resolveBillBalancesFromEntity(bill);
    expect(balances.previous, equals(-100.0));
    expect(balances.current, equals(-90.0));
    expect(describeBalance(balances.previous), equals('₹100 Advance'));
    expect(describeBalance(balances.current), equals('₹90 Advance'));
    expect(ledgerAfter, equals(-90.0));
    expect(advanceAfter, equals(90.0));
  });
}
