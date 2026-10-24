import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:shopmanager/data/db/app_database.dart';
import 'package:shopmanager/data/repositories/item_repository.dart';
import 'package:shopmanager/data/repositories/worker_repository.dart';
import 'package:shopmanager/data/repositories/worker_issue_repository.dart';
import 'package:shopmanager/data/repositories/production_repository.dart';

void main() {
  late AppDatabase db;
  late ItemRepository itemRepo;
  late WorkerRepository workerRepo;
  late WorkerIssueRepository issueRepo;
  late ProductionRepository productionRepo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    itemRepo = ItemRepository(db);
    workerRepo = WorkerRepository(db);
    issueRepo = WorkerIssueRepository(db);
    productionRepo = ProductionRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('ProductionRepository & Schema v3 Tests', () {
    test('(a) full-use production creates 1 header, 2 inputs, 1 completion stock tx, 0 returned rows, and sets worker txs to completed', () async {
      final workerId = await workerRepo.addWorker(name: 'Rajesh Kumar');
      final ribId = await itemRepo.addItem(
        name: 'Cotton Rib 1x1',
        type: 'raw_material',
        unit: 'kg',
        openingQty: 100,
      );
      final polyId = await itemRepo.addItem(
        name: 'Spun Polyester Thread',
        type: 'raw_material',
        unit: 'cone',
        openingQty: 200,
      );
      final poloId = await itemRepo.addItem(
        name: 'Polo Shirt Navy',
        type: 'finished_product',
        unit: 'pcs',
        openingQty: 0,
      );

      // Issue 50kg Rib and 100 cones Polyester to worker
      await issueRepo.issueMaterials(
        workerId: workerId,
        date: DateTime(2026, 9, 20),
        lines: [
          IssueLine(itemId: ribId, quantity: 50),
          IssueLine(itemId: polyId, quantity: 100),
        ],
      );

      final pending = await productionRepo.getPendingMaterialsForWorker(workerId);
      expect(pending.length, equals(2));

      // Record full production: 50kg Rib used, 100 cones Polyester used, producing 45 pcs Polo
      final prodId = await productionRepo.recordProduction(
        workerId: workerId,
        date: DateTime(2026, 9, 29),
        batchRef: 'Batch #24-B',
        outputItemId: poloId,
        outputQty: 45,
        inputs: [
          ProductionInputLine(itemId: ribId, quantityUsed: 50, quantityReturned: 0),
          ProductionInputLine(itemId: polyId, quantityUsed: 100, quantityReturned: 0),
        ],
      );

      expect(prodId, greaterThan(0));

      // Verify productionRecord header
      final prodRecords = await db.select(db.productionRecords).get();
      expect(prodRecords.length, equals(1));
      expect(prodRecords.first.outputItemId, equals(poloId));
      expect(prodRecords.first.outputQty, equals(45.0));

      // Verify productionInputs
      final prodInputs = await db.select(db.productionInputs).get();
      expect(prodInputs.length, equals(2));
      expect(prodInputs.every((i) => i.quantityReturned == 0.0), isTrue);

      // Verify stockTransactions (only 1 production_completed row, no returned_from_worker)
      final stockTxs = await db.select(db.stockTransactions).get();
      final returnedTxs = stockTxs.where((t) => t.type == 'returned_from_worker').toList();
      final completedTxs = stockTxs.where((t) => t.type == 'production_completed').toList();
      expect(returnedTxs, isEmpty);
      expect(completedTxs.length, equals(1));
      expect(completedTxs.first.itemId, equals(poloId));
      expect(completedTxs.first.quantity, equals(45.0));

      // Verify output item currentQty increased to 45
      final poloItem = await itemRepo.getItemById(poloId);
      expect(poloItem?.currentQty, equals(45.0));

      // Verify workerTransactions statuses moved to completed
      final workerTxs = await db.select(db.workerTransactions).get();
      expect(workerTxs.every((w) => w.status == 'completed'), isTrue);

      // Verify getPendingMaterialsForWorker returns empty
      final pendingAfter = await productionRepo.getPendingMaterialsForWorker(workerId);
      expect(pendingAfter, isEmpty);
    });

    test('(b) partial-use production (40 of 50kg used, 10kg returned) creates returned stock tx, increases raw stock, and leaves worker tx partial', () async {
      final workerId = await workerRepo.addWorker(name: 'Suresh');
      final ribId = await itemRepo.addItem(
        name: 'Cotton Rib 1x1',
        type: 'raw_material',
        unit: 'kg',
        openingQty: 100,
      );
      final poloId = await itemRepo.addItem(
        name: 'Polo Shirt Black',
        type: 'finished_product',
        unit: 'pcs',
        openingQty: 0,
      );

      await issueRepo.issueMaterials(
        workerId: workerId,
        date: DateTime(2026, 9, 20),
        lines: [IssueLine(itemId: ribId, quantity: 50)],
      );

      // After issue, raw stock for rib is 50kg (100 - 50)
      final ribBefore = await itemRepo.getItemById(ribId);
      expect(ribBefore?.currentQty, equals(50.0));

      // Record partial production: 40kg used, 10kg returned to stock
      await productionRepo.recordProduction(
        workerId: workerId,
        date: DateTime(2026, 9, 29),
        outputItemId: poloId,
        outputQty: 36,
        inputs: [
          ProductionInputLine(itemId: ribId, quantityUsed: 40, quantityReturned: 10),
        ],
      );

      // Verify raw item currentQty increased by +10 (from 50 to 60)
      final ribAfter = await itemRepo.getItemById(ribId);
      expect(ribAfter?.currentQty, equals(60.0));

      // Verify returned_from_worker stock transaction row
      final stockTxs = await db.select(db.stockTransactions).get();
      final returnedTx = stockTxs.firstWhere((t) => t.type == 'returned_from_worker');
      expect(returnedTx.quantity, equals(10.0));
      expect(returnedTx.itemId, equals(ribId));

      // Verify workerTransaction status is completed (since 40 used + 10 returned = 50 total accounted for)
      final workerTxs = await db.select(db.workerTransactions).get();
      expect(workerTxs.first.status, equals('completed'));

      // Pending for worker is now 0
      final pendingAfter = await productionRepo.getPendingMaterialsForWorker(workerId);
      expect(pendingAfter, isEmpty);
    });

    test('(c) attempting quantityUsed > remaining pending throws validation failure and saves nothing', () async {
      final workerId = await workerRepo.addWorker(name: 'Mahesh');
      final ribId = await itemRepo.addItem(
        name: 'Cotton Rib 1x1',
        type: 'raw_material',
        unit: 'kg',
        openingQty: 100,
      );
      final poloId = await itemRepo.addItem(
        name: 'Polo Shirt Red',
        type: 'finished_product',
        unit: 'pcs',
        openingQty: 0,
      );

      await issueRepo.issueMaterials(
        workerId: workerId,
        date: DateTime(2026, 9, 20),
        lines: [IssueLine(itemId: ribId, quantity: 50)],
      );

      // Attempt to use 65kg (over-limit)
      expect(
        () async => await productionRepo.recordProduction(
          workerId: workerId,
          date: DateTime(2026, 9, 29),
          outputItemId: poloId,
          outputQty: 40,
          inputs: [
            ProductionInputLine(itemId: ribId, quantityUsed: 65),
          ],
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Verify nothing saved
      final prodRecords = await db.select(db.productionRecords).get();
      expect(prodRecords, isEmpty);

      final poloItem = await itemRepo.getItemById(poloId);
      expect(poloItem?.currentQty, equals(0.0));
    });

    test('(d) a second, later production against the same worker/item correctly sees only the REMAINING pending amount', () async {
      final workerId = await workerRepo.addWorker(name: 'Anita');
      final ribId = await itemRepo.addItem(
        name: 'Cotton Rib 1x1',
        type: 'raw_material',
        unit: 'kg',
        openingQty: 100,
      );
      final poloId = await itemRepo.addItem(
        name: 'Polo Shirt Green',
        type: 'finished_product',
        unit: 'pcs',
        openingQty: 0,
      );

      await issueRepo.issueMaterials(
        workerId: workerId,
        date: DateTime(2026, 9, 20),
        lines: [IssueLine(itemId: ribId, quantity: 50)],
      );

      // Production 1: Use 30kg, 0 returned -> 20kg remains pending (status partial)
      await productionRepo.recordProduction(
        workerId: workerId,
        date: DateTime(2026, 9, 25),
        outputItemId: poloId,
        outputQty: 20,
        inputs: [
          ProductionInputLine(itemId: ribId, quantityUsed: 30),
        ],
      );

      // Check remaining pending via getPendingMaterialsForWorker
      final pending1 = await productionRepo.getPendingMaterialsForWorker(workerId);
      expect(pending1.length, equals(1));
      expect(pending1.first.remainingPendingQuantity, equals(20.0));

      // Attempting to use 25kg in second production fails because only 20kg is pending
      expect(
        () async => await productionRepo.recordProduction(
          workerId: workerId,
          date: DateTime(2026, 9, 29),
          outputItemId: poloId,
          outputQty: 15,
          inputs: [
            ProductionInputLine(itemId: ribId, quantityUsed: 25),
          ],
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Production 2: Use 20kg -> fully completed
      await productionRepo.recordProduction(
        workerId: workerId,
        date: DateTime(2026, 9, 29),
        outputItemId: poloId,
        outputQty: 15,
        inputs: [
          ProductionInputLine(itemId: ribId, quantityUsed: 20),
        ],
      );

      final pending2 = await productionRepo.getPendingMaterialsForWorker(workerId);
      expect(pending2, isEmpty);

      // Total Polo produced: 20 + 15 = 35 pcs
      final poloItem = await itemRepo.getItemById(poloId);
      expect(poloItem?.currentQty, equals(35.0));
    });
  });
}
