import 'dart:io';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopmanager/data/db/app_database.dart';
import 'package:shopmanager/data/models/bill_model.dart';
import 'package:shopmanager/data/repositories/billing_repository.dart';
import 'package:shopmanager/data/repositories/customer_repository.dart';
import 'package:shopmanager/data/repositories/item_repository.dart';
import 'package:shopmanager/data/repositories/production_repository.dart';
import 'package:shopmanager/data/repositories/stock_repository.dart';
import 'package:shopmanager/data/repositories/worker_issue_repository.dart';
import 'package:shopmanager/data/repositories/worker_repository.dart';

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
  late StockRepository stockRepo;
  late WorkerRepository workerRepo;
  late WorkerIssueRepository workerIssueRepo;
  late ProductionRepository productionRepo;
  late BillingRepository billingRepo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    customerRepo = CustomerRepository(db);
    itemRepo = ItemRepository(db);
    stockRepo = StockRepository(db);
    workerRepo = WorkerRepository(db);
    workerIssueRepo = WorkerIssueRepository(db);
    productionRepo = ProductionRepository(db);
    billingRepo = BillingRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Phase 13b Reports Repository Tests', () {
    test('1. Stock Report - correctly computes values for raw materials & finished products', () async {
      await itemRepo.addItem(
        name: 'Cotton Thread',
        type: 'raw_material',
        unit: 'kg',
        purchaseRate: 100.0,
        sellingRate: 0.0,
        openingQty: 10.0,
      );

      await itemRepo.addItem(
        name: 'Cotton Shirt',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 200.0,
        sellingRate: 500.0,
        openingQty: 5.0,
      );

      final report = await itemRepo.getStockReport();

      expect(report.totalItems, equals(2));
      expect(report.totalRawMaterialValue, equals(1000.0)); // 10 * 100
      expect(report.totalFinishedProductValue, equals(1000.0)); // 5 * 200
      expect(report.grandTotalValue, equals(2000.0));
    });

    test('2. Stock Movement Report - counts stock in & stock out events', () async {
      final itemId = await itemRepo.addItem(
        name: 'Fabric',
        type: 'raw_material',
        unit: 'meters',
        purchaseRate: 50.0,
        sellingRate: 0.0,
        openingQty: 0.0,
      );

      final now = DateTime.now();

      // Purchase stock (+50)
      await stockRepo.recordPurchase(
        itemId: itemId,
        quantity: 50.0,
        unitRate: 50.0,
        date: now,
        notes: 'Vendor A',
      );

      // Adjust stock down (-10)
      await stockRepo.recordAdjustment(
        itemId: itemId,
        isIncrease: false,
        quantity: 10.0,
        reason: 'Damaged',
        date: now,
      );

      final report = await stockRepo.getStockMovementReport(from: now.subtract(const Duration(days: 1)), to: now);

      expect(report.totalEvents, equals(2));
      expect(report.stockInCount, equals(1));
      expect(report.stockOutCount, equals(1));
    });

    test('3. Low Stock Report - separates out of stock and low stock items', () async {
      // Out of stock
      await itemRepo.addItem(
        name: 'Zero Item',
        type: 'raw_material',
        unit: 'kg',
        purchaseRate: 10.0,
        sellingRate: 0.0,
        openingQty: 0.0,
        minStockLevel: 5.0,
      );

      // Low stock
      await itemRepo.addItem(
        name: 'Low Item',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 20.0,
        sellingRate: 50.0,
        openingQty: 2.0,
        minStockLevel: 10.0,
      );

      // Healthy stock
      await itemRepo.addItem(
        name: 'Healthy Item',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 20.0,
        sellingRate: 50.0,
        openingQty: 50.0,
        minStockLevel: 10.0,
      );

      final report = await itemRepo.getLowStockReport();

      expect(report.outOfStock.length, equals(1));
      expect(report.outOfStock.first.name, equals('Zero Item'));
      expect(report.lowStock.length, equals(1));
      expect(report.lowStock.first.name, equals('Low Item'));
      expect(report.totalLowCount, equals(2));
    });

    test('4. Worker Material Report - identifies workers with pending issued materials', () async {
      final workerId = await workerRepo.addWorker(name: 'John Weaver');
      final itemId = await itemRepo.addItem(
        name: 'Yarn',
        type: 'raw_material',
        unit: 'kg',
        purchaseRate: 40.0,
        sellingRate: 0.0,
        openingQty: 100.0,
      );

      // Issue material to worker
      await workerIssueRepo.issueMaterials(
        workerId: workerId,
        date: DateTime.now(),
        lines: [IssueLine(itemId: itemId, quantity: 20.0)],
      );

      final report = await productionRepo.getWorkerMaterialReport();

      expect(report.distinctWorkersCount, equals(1));
      expect(report.pendingLineItemsCount, equals(1));
      expect(report.items.first.workerName, equals('John Weaver'));
      expect(report.items.first.remainingPendingQty, equals(20.0));
    });

    test('5. Worker Production Report - tracks production output batches', () async {
      final workerId = await workerRepo.addWorker(name: 'Alice Tailor');
      final rawId = await itemRepo.addItem(
        name: 'Silk Cloth',
        type: 'raw_material',
        unit: 'meters',
        purchaseRate: 100.0,
        sellingRate: 0.0,
        openingQty: 50.0,
      );
      final finishedId = await itemRepo.addItem(
        name: 'Silk Dress',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 300.0,
        sellingRate: 1000.0,
        openingQty: 0.0,
      );

      // Issue material first
      await workerIssueRepo.issueMaterials(
        workerId: workerId,
        date: DateTime.now(),
        lines: [IssueLine(itemId: rawId, quantity: 10.0)],
      );

      // Record production
      await productionRepo.recordProduction(
        workerId: workerId,
        outputItemId: finishedId,
        outputQty: 5.0,
        date: DateTime.now(),
        inputs: [ProductionInputLine(itemId: rawId, quantityUsed: 10.0)],
        batchRef: 'BATCH-001',
      );

      final now = DateTime.now();
      final report = await productionRepo.getWorkerProductionReport(
        from: now.subtract(const Duration(days: 1)),
        to: now,
      );

      expect(report.totalEvents, equals(1));
      expect(report.activeWorkersCount, equals(1));
      expect(report.items.first.outputQty, equals(5.0));
      expect(report.items.first.outputItemName, equals('Silk Dress'));
    });

    test('6. Payment Report - breaks down cash, UPI and total collections', () async {
      final custId = await customerRepo.addCustomer(name: 'Buyer Bob', mobile: '9876543210');
      final itemId = await itemRepo.addItem(
        name: 'Gadget',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 50.0,
        sellingRate: 100.0,
        openingQty: 10.0,
      );

      final now = DateTime.now();

      // Bill with Cash payment 100
      await billingRepo.saveBill(
        customerId: custId,
        billDate: now,
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 100.0)],
        amountReceived: 100.0,
        paymentMethod: 'cash',
      );

      // Direct payment UPI 200
      await db.into(db.payments).insert(
        PaymentsCompanion.insert(
          customerId: custId,
          billId: const Value(null),
          amount: 200.0,
          method: 'upi',
          date: now,
          notes: const Value('Advance payment'),
          createdAt: Value(now),
        ),
      );

      final report = await billingRepo.getPaymentReport(
        from: now.subtract(const Duration(days: 1)),
        to: now,
      );

      expect(report.paymentCount, equals(2));
      expect(report.cashTotal, equals(100.0));
      expect(report.upiTotal, equals(200.0));
      expect(report.totalCollected, equals(300.0));
    });
  });
}
