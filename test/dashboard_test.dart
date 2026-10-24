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

  group('Dashboard Summary & Query Tests', () {
    test('(a) getTodaysSalesSummary only counts today\'s bill, not past date bills', () async {
      final customerId = await customerRepo.addCustomer(
        name: 'Customer A',
        mobile: '9820111111',
      );
      final itemId = await itemRepo.addItem(
        name: 'Item A',
        type: 'finished_product',
        unit: 'pcs',
        openingQty: 100,
        sellingRate: 500.0,
      );

      final today = DateTime.now();
      final pastDate = DateTime(2025, 1, 15);

      // Bill created today
      await billingRepo.saveBill(
        customerId: customerId,
        billDate: today,
        lines: [BillLine(itemId: itemId, quantity: 2, rate: 500.0)], // 1000
      );

      // Bill created on past date
      await billingRepo.saveBill(
        customerId: customerId,
        billDate: pastDate,
        lines: [BillLine(itemId: itemId, quantity: 5, rate: 500.0)], // 2500
      );

      final summary = await billingRepo.getTodaysSalesSummary();
      expect(summary.billCount, equals(1));
      expect(summary.totalAmount, equals(1000.0));
    });

    test('(b) getTotalOutstanding correctly sums a customer with only an opening balance plus a customer with real ledger entries', () async {
      // Customer 1: opening balance only (₹1200)
      final cust1Id = await customerRepo.addCustomer(
        name: 'Customer 1 (Opening Bal Only)',
        mobile: '9820111112',
        openingBalance: 1200.0,
      );

      // Customer 2: 0 opening balance, has a bill of ₹3000 with ₹1000 paid = ₹2000 outstanding
      final cust2Id = await customerRepo.addCustomer(
        name: 'Customer 2 (Bill & Ledger)',
        mobile: '9820111113',
        openingBalance: 0.0,
      );
      final itemId = await itemRepo.addItem(
        name: 'Item B',
        type: 'finished_product',
        unit: 'pcs',
        openingQty: 50,
        sellingRate: 3000.0,
      );

      await billingRepo.saveBill(
        customerId: cust2Id,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 3000.0)],
        amountReceived: 1000.0, // Outstanding = 2000
      );

      // Cust 1 has ₹1200, Cust 2 has ₹2000 -> Total = 3200
      final bal1 = await billingRepo.getCustomerLedgerSummary(cust1Id);
      expect(bal1, equals(1200.0));

      final bal2 = await billingRepo.getCustomerLedgerSummary(cust2Id);
      expect(bal2, equals(2000.0));

      final outSummary = await billingRepo.getTotalOutstanding();
      expect(outSummary.totalOutstanding, equals(3200.0));
      expect(outSummary.customersWithBalanceCount, equals(2));
    });

    test('(c) getStockOverview\'s lowStockCount matches the same definition used by the Stock screen (currentQty <= minStockLevel and minStockLevel > 0)', () async {
      // Item 1: openingQty 5, minStockLevel 10 (LOW STOCK)
      await itemRepo.addItem(
        name: 'Low Stock Item',
        type: 'raw_material',
        unit: 'kg',
        openingQty: 5,
        minStockLevel: 10,
        purchaseRate: 100.0,
      );

      // Item 2: openingQty 20, minStockLevel 10 (NORMAL STOCK)
      await itemRepo.addItem(
        name: 'Normal Stock Item',
        type: 'finished_product',
        unit: 'pcs',
        openingQty: 20,
        minStockLevel: 10,
        purchaseRate: 200.0,
      );

      // Item 3: openingQty 0, minStockLevel 0 (NO MIN STOCK DEFINED -> NOT LOW STOCK)
      await itemRepo.addItem(
        name: 'Unmonitored Item',
        type: 'raw_material',
        unit: 'L',
        openingQty: 0,
        minStockLevel: 0,
        purchaseRate: 50.0,
      );

      final stockSummary = await itemRepo.getStockOverview();
      expect(stockSummary.rawMaterialCount, equals(2));
      expect(stockSummary.finishedProductCount, equals(1));
      expect(stockSummary.lowStockCount, equals(1));
      expect(stockSummary.totalStockValue, equals(5 * 100 + 20 * 200)); // 500 + 4000 = 4500
    });

    test('(d) isFreshInstall is true only on a truly empty database and false as soon as any one table has a row', () async {
      // 1. Truly empty database
      final fresh1 = await billingRepo.isFreshInstall();
      expect(fresh1, isTrue);

      // 2. Add a customer
      await customerRepo.addCustomer(
        name: 'Initial Customer',
        mobile: '9820111119',
      );

      final fresh2 = await billingRepo.isFreshInstall();
      expect(fresh2, isFalse);
    });
  });
}
