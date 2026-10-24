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

  group('BillingRepository Tests', () {
    test('(a) saveBill with 2 valid lines creates 1 bills row (INV-0001), 2 billItems, 2 sold stock txs (negative qty), and 1 bill ledger entry', () async {
      final customerId = await customerRepo.addCustomer(
        name: 'Rajesh Kumar',
        mobile: '9820144521',
        openingBalance: 0.0,
      );
      final item1Id = await itemRepo.addItem(
        name: 'Cotton Polo Navy',
        type: 'finished_product',
        unit: 'pcs',
        openingQty: 100,
        sellingRate: 450.0,
      );
      final item2Id = await itemRepo.addItem(
        name: 'Cotton Rib Navy',
        type: 'raw_material',
        unit: 'kg',
        openingQty: 50,
        sellingRate: 200.0,
      );

      final billDate = DateTime(2026, 9, 29);
      final billNum = await billingRepo.saveBill(
        customerId: customerId,
        billDate: billDate,
        lines: [
          BillLine(itemId: item1Id, quantity: 10, rate: 450.0), // 4500
          BillLine(itemId: item2Id, quantity: 5, rate: 200.0),  // 1000
        ],
        discount: 100.0,
        otherCharges: 50.0,
        amountReceived: 0.0, // Unpaid
        notes: 'First test bill',
      );

      expect(billNum, equals('INV-0001'));

      // Check bills table
      final bills = await db.select(db.bills).get();
      expect(bills.length, equals(1));
      final bill = bills.first;
      expect(bill.billNumber, equals('INV-0001'));
      expect(bill.customerId, equals(customerId));
      expect(bill.subtotal, equals(5500.0));
      expect(bill.discount, equals(100.0));
      expect(bill.otherCharges, equals(50.0));
      expect(bill.grandTotal, equals(5450.0));
      expect(bill.remainingBalance, equals(5450.0));
      expect(bill.amountPaid, equals(0.0));
      expect(bill.previousOutstandingSnapshot, equals(0.0));

      // Check billItems table
      final billItems = await db.select(db.billItems).get();
      expect(billItems.length, equals(2));
      expect(billItems[0].itemId, equals(item1Id));
      expect(billItems[0].quantity, equals(10.0));
      expect(billItems[0].amount, equals(4500.0));

      // Check stockTransactions table
      final stockTxs = await db.select(db.stockTransactions).get();
      final soldTxs = stockTxs.where((t) => t.type == 'sold').toList();
      expect(soldTxs.length, equals(2));
      expect(soldTxs[0].quantity, equals(-10.0));
      expect(soldTxs[1].quantity, equals(-5.0));

      // Check items currentQty reduced
      final item1 = await itemRepo.getItemById(item1Id);
      expect(item1?.currentQty, equals(90.0));
      final item2 = await itemRepo.getItemById(item2Id);
      expect(item2?.currentQty, equals(45.0));

      // Check ledgerEntries table (1 bill entry)
      final ledgerEntries = await db.select(db.ledgerEntries).get();
      expect(ledgerEntries.length, equals(1));
      expect(ledgerEntries.first.type, equals('bill'));
      expect(ledgerEntries.first.debit, equals(5450.0));
      expect(ledgerEntries.first.runningBalance, equals(5450.0));
    });

    test('(b) a second saveBill call gets the NEXT sequential bill number (INV-0002)', () async {
      final cust1 = await customerRepo.addCustomer(name: 'Cust 1', mobile: '9000000001');
      final cust2 = await customerRepo.addCustomer(name: 'Cust 2', mobile: '9000000002');
      final itemId = await itemRepo.addItem(name: 'Item A', type: 'finished_product', unit: 'pcs', openingQty: 10);

      final bill1 = await billingRepo.saveBill(
        customerId: cust1,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 100)],
      );
      expect(bill1, equals('INV-0001'));

      final bill2 = await billingRepo.saveBill(
        customerId: cust2,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 100)],
      );
      expect(bill2, equals('INV-0002'));

      final nextPreview = await billingRepo.getNextBillNumber();
      expect(nextPreview, equals('INV-0003'));
    });

    test('(c) when amountReceived > 0, a payments row and a payment ledgerEntries row are created and runningBalance reflects both', () async {
      final customerId = await customerRepo.addCustomer(name: 'Anil Sharma', mobile: '9821033219');
      final itemId = await itemRepo.addItem(name: 'Item B', type: 'finished_product', unit: 'pcs', openingQty: 50);

      final billNum = await billingRepo.saveBill(
        customerId: customerId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 2, rate: 500)], // 1000 total
        amountReceived: 400.0,
        paymentMethod: 'upi',
      );

      expect(billNum, equals('INV-0001'));

      // Check payments table
      final payments = await db.select(db.payments).get();
      expect(payments.length, equals(1));
      expect(payments.first.amount, equals(400.0));
      expect(payments.first.method, equals('upi'));

      // Check ledger entries (1 bill entry + 1 payment entry)
      final ledgerEntries = await db.select(db.ledgerEntries).get();
      expect(ledgerEntries.length, equals(2));
      expect(ledgerEntries[0].type, equals('bill'));
      expect(ledgerEntries[0].debit, equals(1000.0));
      expect(ledgerEntries[0].runningBalance, equals(1000.0));

      expect(ledgerEntries[1].type, equals('payment'));
      expect(ledgerEntries[1].credit, equals(400.0));
      expect(ledgerEntries[1].runningBalance, equals(600.0));
    });

    test('(d) customer with non-zero openingBalance and NO prior ledger entries gets auto-seeded opening_balance ledger row on first bill', () async {
      final customerId = await customerRepo.addCustomer(
        name: 'Vikas Engg',
        mobile: '9422055670',
        openingBalance: 34800.0,
      );
      final itemId = await itemRepo.addItem(name: 'Item C', type: 'finished_product', unit: 'pcs', openingQty: 20);

      // Check getCustomerLedgerSummary before bill returns openingBalance
      final prevBalBefore = await billingRepo.getCustomerLedgerSummary(customerId);
      expect(prevBalBefore, equals(34800.0));

      final billNum = await billingRepo.saveBill(
        customerId: customerId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 1200)], // 1200
        amountReceived: 0,
      );

      expect(billNum, equals('INV-0001'));

      // Ledger entries should contain:
      // 1. opening_balance (debit: 34800, runningBalance: 34800)
      // 2. bill (debit: 1200, runningBalance: 36000)
      final ledgerEntries = await db.select(db.ledgerEntries).get();
      expect(ledgerEntries.length, equals(2));

      expect(ledgerEntries[0].type, equals('opening_balance'));
      expect(ledgerEntries[0].debit, equals(34800.0));
      expect(ledgerEntries[0].runningBalance, equals(34800.0));

      expect(ledgerEntries[1].type, equals('bill'));
      expect(ledgerEntries[1].debit, equals(1200.0));
      expect(ledgerEntries[1].runningBalance, equals(36000.0));

      // Bill snapshot of previous outstanding should be 34800
      final bills = await db.select(db.bills).get();
      expect(bills.first.previousOutstandingSnapshot, equals(34800.0));
      expect(bills.first.grandTotal, equals(1200.0));
    });

    test('(e) validation failure (amountReceived > grandTotal) saves nothing at all', () async {
      final customerId = await customerRepo.addCustomer(name: 'Test Cust', mobile: '9999999999');
      final itemId = await itemRepo.addItem(name: 'Item D', type: 'finished_product', unit: 'pcs', openingQty: 10);

      expect(
        () async => await billingRepo.saveBill(
          customerId: customerId,
          billDate: DateTime.now(),
          lines: [BillLine(itemId: itemId, quantity: 1, rate: 500)],
          amountReceived: 600.0, // > 500 grand total
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Verify database tables remain empty
      final bills = await db.select(db.bills).get();
      expect(bills, isEmpty);
      final billItems = await db.select(db.billItems).get();
      expect(billItems, isEmpty);
      final stockTxs = await db.select(db.stockTransactions).get();
      final soldTxs = stockTxs.where((t) => t.type == 'sold').toList();
      expect(soldTxs, isEmpty);
      final ledgerEntries = await db.select(db.ledgerEntries).get();
      expect(ledgerEntries, isEmpty);
      final payments = await db.select(db.payments).get();
      expect(payments, isEmpty);

      // Item stock remains 10
      final item = await itemRepo.getItemById(itemId);
      expect(item?.currentQty, equals(10.0));
    });
  });
}
