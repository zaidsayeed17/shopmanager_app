import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:shopmanager/data/db/app_database.dart';
import 'package:shopmanager/data/repositories/item_repository.dart';
import 'package:shopmanager/data/repositories/worker_repository.dart';
import 'package:shopmanager/data/repositories/worker_issue_repository.dart';

void main() {
  late AppDatabase db;
  late ItemRepository itemRepo;
  late WorkerRepository workerRepo;
  late WorkerIssueRepository issueRepo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    itemRepo = ItemRepository(db);
    workerRepo = WorkerRepository(db);
    issueRepo = WorkerIssueRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('WorkerIssueRepository Tests', () {
    test('(a) issueMaterials creates negative issued_to_worker stockTransactions rows and pending workerTransactions rows', () async {
      final workerId = await workerRepo.addWorker(name: 'Ramesh Kumar');
      final itemId = await itemRepo.addItem(
        name: 'Cotton Rib',
        type: 'raw_material',
        unit: 'kg',
        openingQty: 100,
      );

      final date = DateTime(2026, 9, 29);
      final batchTag = await issueRepo.issueMaterials(
        workerId: workerId,
        date: date,
        lines: [IssueLine(itemId: itemId, quantity: 30)],
        notes: 'Tracksuit batch',
      );

      // Verify item currentQty updated
      final updatedItem = await itemRepo.getItemById(itemId);
      expect(updatedItem?.currentQty, equals(70.0));

      // Verify stock transaction
      final stockTxs = await db.select(db.stockTransactions).get();
      expect(stockTxs.length, equals(2)); // opening_stock + issued_to_worker
      final issueTx = stockTxs.firstWhere((t) => t.type == 'issued_to_worker');
      expect(issueTx.itemId, equals(itemId));
      expect(issueTx.quantity, equals(-30.0));
      expect(issueTx.referenceType, equals('worker'));
      expect(issueTx.referenceId, equals(workerId));
      expect(issueTx.notes, contains(batchTag));
      expect(issueTx.notes, contains('Tracksuit batch'));

      // Verify worker transaction
      final workerTxs = await db.select(db.workerTransactions).get();
      expect(workerTxs.length, equals(1));
      final wTx = workerTxs.first;
      expect(wTx.workerId, equals(workerId));
      expect(wTx.itemId, equals(itemId));
      expect(wTx.quantityIssued, equals(30.0));
      expect(wTx.status, equals('pending'));
      expect(wTx.notes, contains(batchTag));

      // Verify pending count on worker
      final worker = await workerRepo.getWorkerById(workerId);
      expect(worker?.pendingItemCount, equals(1));
    });

    test('(b) Issuing > available stock succeeds and drives currentQty negative', () async {
      final workerId = await workerRepo.addWorker(name: 'Suresh');
      final itemId = await itemRepo.addItem(
        name: 'Polyester Spun',
        type: 'raw_material',
        unit: 'kg',
        openingQty: 20,
      );

      final batchTag = await issueRepo.issueMaterials(
        workerId: workerId,
        date: DateTime.now(),
        lines: [IssueLine(itemId: itemId, quantity: 50)],
      );

      final updatedItem = await itemRepo.getItemById(itemId);
      expect(updatedItem?.currentQty, equals(-30.0));

      final stockTxs = await db.select(db.stockTransactions).get();
      final issueTx = stockTxs.firstWhere((t) => t.type == 'issued_to_worker');
      expect(issueTx.quantity, equals(-50.0));
      expect(issueTx.notes, contains(batchTag));
    });

    test('(c) Qty 0 throws validation error and rolls back transaction cleanly', () async {
      final workerId = await workerRepo.addWorker(name: 'Mahesh');
      final itemId = await itemRepo.addItem(
        name: 'Elastic Band',
        type: 'raw_material',
        unit: 'meter',
        openingQty: 100,
      );

      expect(
        () async => await issueRepo.issueMaterials(
          workerId: workerId,
          date: DateTime.now(),
          lines: [IssueLine(itemId: itemId, quantity: 0)],
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Verify roll back
      final updatedItem = await itemRepo.getItemById(itemId);
      expect(updatedItem?.currentQty, equals(100.0));

      final stockTxs = await db.select(db.stockTransactions).get();
      expect(stockTxs.where((t) => t.type == 'issued_to_worker'), isEmpty);

      final workerTxs = await db.select(db.workerTransactions).get();
      expect(workerTxs, isEmpty);
    });

    test('(d) Batch tag substring is included in notes of all created rows for multi-line issue', () async {
      final workerId = await workerRepo.addWorker(name: 'Anita');
      final item1Id = await itemRepo.addItem(
        name: 'Thread White',
        type: 'raw_material',
        unit: 'spool',
        openingQty: 50,
      );
      final item2Id = await itemRepo.addItem(
        name: 'Thread Black',
        type: 'raw_material',
        unit: 'spool',
        openingQty: 50,
      );

      final batchTag = await issueRepo.issueMaterials(
        workerId: workerId,
        date: DateTime.now(),
        lines: [
          IssueLine(itemId: item1Id, quantity: 10),
          IssueLine(itemId: item2Id, quantity: 15),
        ],
      );

      expect(batchTag, startsWith('ISSUE-'));

      final stockTxs = await db.select(db.stockTransactions).get();
      final issueTxs = stockTxs.where((t) => t.type == 'issued_to_worker').toList();
      expect(issueTxs.length, equals(2));
      for (final tx in issueTxs) {
        expect(tx.notes, contains(batchTag));
      }

      final workerTxs = await db.select(db.workerTransactions).get();
      expect(workerTxs.length, equals(2));
      for (final tx in workerTxs) {
        expect(tx.notes, contains(batchTag));
      }
    });
  });
}
