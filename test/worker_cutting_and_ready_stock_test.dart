import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopmanager/data/db/app_database.dart';
import 'package:shopmanager/data/repositories/item_repository.dart';
import 'package:shopmanager/data/repositories/stock_repository.dart';
import 'package:shopmanager/data/repositories/worker_repository.dart';
import 'package:shopmanager/data/repositories/worker_cutting_repository.dart';

void main() {
  late AppDatabase database;
  late ItemRepository itemRepo;
  late StockRepository stockRepo;
  late WorkerRepository workerRepo;
  late WorkerCuttingRepository cuttingRepo;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    itemRepo = ItemRepository(database);
    stockRepo = StockRepository(database);
    workerRepo = WorkerRepository(database);
    cuttingRepo = WorkerCuttingRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('Worker Cutting System Tests', () {
    test('4 cutting entries for one worker on one day create 4 entries, 4 stock txs, deduct stock correctly, and aggregate in summary', () async {
      // 1. Setup worker
      final workerId = await workerRepo.addWorker(name: 'Ramesh Kumar', mobile: '9876543210');

      // 2. Setup items
      final blackId = await itemRepo.addItem(
        name: 'Black Thread',
        type: 'raw_material',
        unit: 'nag',
        openingQty: 100.0,
      );
      final redId = await itemRepo.addItem(
        name: 'Red Thread',
        type: 'raw_material',
        unit: 'nag',
        openingQty: 100.0,
      );
      final blueId = await itemRepo.addItem(
        name: 'Blue Thread',
        type: 'raw_material',
        unit: 'nag',
        openingQty: 100.0,
      );

      final date = DateTime(2026, 10, 6);

      // 3. Add 4 cutting entries: Black 50, Red 30, Blue 40, Black 20
      await cuttingRepo.addCuttingEntry(
        workerId: workerId,
        itemId: blackId,
        date: date,
        quantity: 50.0,
        rate: 10.0,
      );
      await cuttingRepo.addCuttingEntry(
        workerId: workerId,
        itemId: redId,
        date: date,
        quantity: 30.0,
        rate: 12.0,
      );
      await cuttingRepo.addCuttingEntry(
        workerId: workerId,
        itemId: blueId,
        date: date,
        quantity: 40.0,
        rate: 15.0,
      );
      await cuttingRepo.addCuttingEntry(
        workerId: workerId,
        itemId: blackId,
        date: date,
        quantity: 20.0,
        rate: 10.0,
      );

      // Verify 4 separate WorkerCuttingEntry rows
      final entries = await cuttingRepo.getCuttingEntriesForWorker(workerId);
      expect(entries.length, equals(4));

      // Verify 4 stock transactions of type 'worker_cutting'
      final allTx = await (database.select(database.stockTransactions)
            ..where((t) => t.type.equals('worker_cutting')))
          .get();
      expect(allTx.length, equals(4));

      // Verify stock deductions: Black 100 - 70 = 30; Red 100 - 30 = 70; Blue 100 - 40 = 60
      final blackItem = await itemRepo.getItemById(blackId);
      final redItem = await itemRepo.getItemById(redId);
      final blueItem = await itemRepo.getItemById(blueId);

      expect(blackItem!.currentQty, equals(30.0));
      expect(redItem!.currentQty, equals(70.0));
      expect(blueItem!.currentQty, equals(60.0));

      // Verify getTodaysCuttingSummary aggregates Black to 70 total nag while entries stay 2 separate rows
      final summary = await cuttingRepo.getTodaysCuttingSummary(workerId, targetDate: date);
      expect(summary.overallTotalQuantity, equals(140.0));
      expect(summary.items.length, equals(3));

      final blackSummary = summary.items.firstWhere((s) => s.itemId == blackId);
      expect(blackSummary.totalQuantity, equals(70.0));
      expect(blackSummary.totalAmount, equals(700.0)); // (50*10 + 20*10)
    });

    test('Cutting quantity > available stock is WARN-ONLY, saves successfully into negative stock', () async {
      final workerId = await workerRepo.addWorker(name: 'Suresh');
      final itemId = await itemRepo.addItem(
        name: 'Green Thread',
        type: 'raw_material',
        unit: 'nag',
        openingQty: 10.0,
      );

      final date = DateTime.now();

      // Add cutting entry of 25 when only 10 available
      final entryId = await cuttingRepo.addCuttingEntry(
        workerId: workerId,
        itemId: itemId,
        date: date,
        quantity: 25.0,
        rate: 8.0,
      );

      expect(entryId, greaterThan(0));

      final item = await itemRepo.getItemById(itemId);
      expect(item!.currentQty, equals(-15.0)); // negative stock allowed for worker cutting
    });
  });

  group('Ready Stock Module Tests', () {
    test('Adding a ready stock colour, Stock In +100, Stock Out -30 leaves 70 available', () async {
      final itemId = await itemRepo.addItem(
        name: 'Ready Stock Black',
        type: 'ready_stock',
        unit: 'nag',
        openingQty: 0.0,
      );

      final item = await itemRepo.getItemById(itemId);
      expect(item!.type, equals('ready_stock'));

      final date = DateTime.now();

      // Stock In +100
      await stockRepo.recordReadyStockMovement(
        itemId: itemId,
        quantity: 100.0,
        isStockIn: true,
        date: date,
        remark: 'Transfer from cutting',
      );

      var updated = await itemRepo.getItemById(itemId);
      expect(updated!.currentQty, equals(100.0));

      // Stock Out -30
      await stockRepo.recordReadyStockMovement(
        itemId: itemId,
        quantity: 30.0,
        isStockIn: false,
        date: date,
        remark: 'Dispatch to customer',
      );

      updated = await itemRepo.getItemById(itemId);
      expect(updated!.currentQty, equals(70.0));
    });

    test('Ready Stock Stock Out exceeding available stock is HARD-BLOCKED', () async {
      final itemId = await itemRepo.addItem(
        name: 'Ready Stock Red',
        type: 'ready_stock',
        unit: 'nag',
        openingQty: 50.0,
      );

      final date = DateTime.now();

      // Attempting Stock Out of 60 when only 50 available must throw ArgumentError
      expect(
        () async => await stockRepo.recordReadyStockMovement(
          itemId: itemId,
          quantity: 60.0,
          isStockIn: false,
          date: date,
        ),
        throwsArgumentError,
      );

      // Stock remains unchanged at 50
      final item = await itemRepo.getItemById(itemId);
      expect(item!.currentQty, equals(50.0));
    });

    test('ready_stock items are EXCLUDED from getAllItems() but INCLUDED in getReadyStockItems()', () async {
      final rawId = await itemRepo.addItem(
        name: 'Raw Material Cotton',
        type: 'raw_material',
        unit: 'kg',
      );

      final readyId = await itemRepo.addItem(
        name: 'Ready Stock Blue',
        type: 'ready_stock',
        unit: 'nag',
      );

      final allItems = await itemRepo.getAllItems();
      final readyItems = await itemRepo.getReadyStockItems();

      expect(allItems.any((i) => i.id == rawId), isTrue);
      expect(allItems.any((i) => i.id == readyId), isFalse);

      expect(readyItems.any((i) => i.id == readyId), isTrue);
      expect(readyItems.any((i) => i.id == rawId), isFalse);
    });
  });
}
