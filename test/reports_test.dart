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

  group('Reports Data Layer Tests', () {
    test('getDailySalesReport correctly totals bills within range and EXCLUDES voided bills', () async {
      final custId = await customerRepo.addCustomer(name: 'Test Customer', mobile: '9999999999');
      final itemId = await itemRepo.addItem(
        name: 'Sample Item',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 50.0,
        sellingRate: 100.0,
        openingQty: 500.0,
      );

      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      // Bill 1: Today, Active, 1000
      await billingRepo.saveBill(
        customerId: custId,
        billDate: today,
        lines: [BillLine(itemId: itemId, quantity: 10, rate: 100)],
      );

      // Bill 2: Today, Active, 2000
      await billingRepo.saveBill(
        customerId: custId,
        billDate: today,
        lines: [BillLine(itemId: itemId, quantity: 20, rate: 100)],
      );

      // Bill 3: Today, Voided (5000)
      final billNum3 = await billingRepo.saveBill(
        customerId: custId,
        billDate: today,
        lines: [BillLine(itemId: itemId, quantity: 50, rate: 100)],
      );
      final b3 = (await billingRepo.getAllBills()).firstWhere((b) => b.billNumber == billNum3);
      await billingRepo.voidBill(billId: b3.id, reason: 'Test voiding');

      // Bill 4: Yesterday, Active, 1500
      await billingRepo.saveBill(
        customerId: custId,
        billDate: yesterday,
        lines: [BillLine(itemId: itemId, quantity: 15, rate: 100)],
      );

      // Fetch today's sales report
      final reportToday = await billingRepo.getDailySalesReport(from: today, to: today);

      // Sum should be 1000 + 2000 = 3000. Voided 5000 & Yesterday 1500 excluded.
      expect(reportToday.totalSales, equals(3000.0));
      expect(reportToday.totalBills, equals(2));
      expect(reportToday.averageBillValue, equals(1500.0));
    });

    test('getCustomerOutstandingReport includes customer with only opening balance and sorts both ways', () async {
      // Customer A: Opening balance = 5000, no bills
      final custAId = await customerRepo.addCustomer(
        name: 'Alpha Traders',
        mobile: '9876543210',
        openingBalance: 5000.0,
      );

      // Customer B: Opening balance = 0, bill yesterday for 12000, paid 2000 -> 10000 outstanding
      final custBId = await customerRepo.addCustomer(
        name: 'Beta Enterprises',
        mobile: '9123456789',
        openingBalance: 0.0,
      );

      // Customer C: Opening balance = 0, bill today for 8000, paid 0 -> 8000 outstanding
      final custCId = await customerRepo.addCustomer(
        name: 'Gamma Corp',
        mobile: '9000000000',
        openingBalance: 0.0,
      );

      final itemId = await itemRepo.addItem(
        name: 'Test Item',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 50.0,
        sellingRate: 100.0,
        openingQty: 500.0,
      );

      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final today = DateTime.now();

      await billingRepo.saveBill(
        customerId: custBId,
        billDate: yesterday,
        lines: [BillLine(itemId: itemId, quantity: 120, rate: 100)], // 12000
        amountReceived: 2000.0,
      );

      await billingRepo.saveBill(
        customerId: custCId,
        billDate: today,
        lines: [BillLine(itemId: itemId, quantity: 80, rate: 100)], // 8000
      );

      // 1. Highest First sort
      final highestReport = await billingRepo.getCustomerOutstandingReport(highestFirst: true);
      expect(highestReport.customerCount, equals(3));
      expect(highestReport.totalOutstanding, equals(23000.0));
      expect(highestReport.items[0].id, equals(custBId)); // 10000
      expect(highestReport.items[1].id, equals(custCId)); // 8000
      expect(highestReport.items[2].id, equals(custAId)); // 5000

      // 2. Oldest Bill First sort
      final oldestReport = await billingRepo.getCustomerOutstandingReport(highestFirst: false);
      expect(oldestReport.items[0].id, equals(custBId)); // yesterday
      expect(oldestReport.items[1].id, equals(custCId)); // today
      expect(oldestReport.items[2].id, equals(custAId)); // no bills (null date at end)
    });

    test('customer with fully-paid-off balance (net zero) does NOT appear in outstanding report', () async {
      final custId = await customerRepo.addCustomer(
        name: 'Settled Customer',
        mobile: '9777777777',
        openingBalance: 0.0,
      );

      final itemId = await itemRepo.addItem(
        name: 'Item',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 50.0,
        sellingRate: 100.0,
        openingQty: 100.0,
      );

      // Create bill for 4000 and pay 4000 in full
      await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 40, rate: 100)],
        amountReceived: 4000.0,
      );

      final report = await billingRepo.getCustomerOutstandingReport(highestFirst: true);

      // Settled customer should NOT appear
      final found = report.items.where((i) => i.id == custId).toList();
      expect(found, isEmpty);
    });
  });
}
