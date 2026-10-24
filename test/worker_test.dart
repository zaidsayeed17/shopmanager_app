import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopmanager/data/db/app_database.dart';
import 'package:shopmanager/data/repositories/item_repository.dart';
import 'package:shopmanager/data/repositories/worker_repository.dart';

void main() {
  late AppDatabase database;
  late WorkerRepository workerRepo;
  late ItemRepository itemRepo;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    workerRepo = WorkerRepository(database);
    itemRepo = ItemRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('WorkerRepository Tests', () {
    test('(a) addWorker persists and getAllWorkers returns it', () async {
      final workerId = await workerRepo.addWorker(
        name: 'Ramesh Singh',
        mobile: '9820011223',
        workType: 'Stitching',
        address: 'Gala 4, Workshop Area',
        notes: 'Experienced operator',
      );

      expect(workerId, isNotNull);
      expect(workerId, greaterThan(0));

      final workers = await workerRepo.getAllWorkers();
      expect(workers.length, equals(1));

      final worker = workers.first;
      expect(worker.id, equals(workerId));
      expect(worker.name, equals('Ramesh Singh'));
      expect(worker.mobile, equals('9820011223'));
      expect(worker.workType, equals('Stitching'));
      expect(worker.address, equals('Gala 4, Workshop Area'));
      expect(worker.notes, equals('Experienced operator'));
      expect(worker.isActive, isTrue);
      expect(worker.formattedWorkerId, equals('W-${workerId.toString().padLeft(4, '0')}'));
    });

    test('(b) updateWorker changes only intended fields', () async {
      final workerId = await workerRepo.addWorker(
        name: 'Suresh Kumar',
        mobile: '9821100223',
        workType: 'Cutting',
        address: 'Old Town',
      );

      final success = await workerRepo.updateWorker(
        id: workerId,
        name: 'Suresh Kumar Master',
        mobile: '9821100223',
        workType: 'Master Cutting',
        address: 'New Industrial Hub',
        notes: 'Promoted to Master Cutter',
      );

      expect(success, isTrue);

      final updated = await workerRepo.getWorkerById(workerId);
      expect(updated, isNotNull);
      expect(updated!.name, equals('Suresh Kumar Master'));
      expect(updated.workType, equals('Master Cutting'));
      expect(updated.address, equals('New Industrial Hub'));
      expect(updated.notes, equals('Promoted to Master Cutter'));
      expect(updated.mobile, equals('9821100223'));
      expect(updated.isActive, isTrue);
    });

    test('(c) setWorkerActive(false) keeps the row (no deletion)', () async {
      final workerId = await workerRepo.addWorker(
        name: 'Anil Verma',
        mobile: '9769011223',
        workType: 'Finishing',
      );

      final success = await workerRepo.setWorkerActive(workerId, false);
      expect(success, isTrue);

      final worker = await workerRepo.getWorkerById(workerId);
      expect(worker, isNotNull);
      expect(worker!.id, equals(workerId));
      expect(worker.isActive, isFalse);

      final allWorkers = await workerRepo.getAllWorkers();
      expect(allWorkers.length, equals(1));
      expect(allWorkers.first.isActive, isFalse);
    });

    test('(d) searchWorkers matches by name, mobile, and work type, case-insensitively', () async {
      final w1 = await workerRepo.addWorker(
        name: 'Pooja Sharma',
        mobile: '9820011111',
        workType: 'Stitching',
      );
      final w2 = await workerRepo.addWorker(
        name: 'Vikas Patel',
        mobile: '9820022222',
        workType: 'Packing',
      );
      final w3 = await workerRepo.addWorker(
        name: 'Deepak Tailor',
        mobile: '9769033333',
        workType: 'Cutting',
      );

      // Search by name (case-insensitive)
      final resName = await workerRepo.searchWorkers('pooja');
      expect(resName.length, equals(1));
      expect(resName.first.id, equals(w1));

      // Search by mobile substring
      final resMobile = await workerRepo.searchWorkers('2222');
      expect(resMobile.length, equals(1));
      expect(resMobile.first.id, equals(w2));

      // Search by workType (case-insensitive)
      final resWorkType = await workerRepo.searchWorkers('CUTTING');
      expect(resWorkType.length, equals(1));
      expect(resWorkType.first.id, equals(w3));

      // Search matching non-existing text
      final resNone = await workerRepo.searchWorkers('NonExistent');
      expect(resNone, isEmpty);
    });

    test('(e) getPendingItemCounts counts rows with status pending and partial but NOT completed', () async {
      // Create a worker and an item
      final workerId = await workerRepo.addWorker(
        name: 'Mahesh Contractor',
        mobile: '9820099887',
        workType: 'Stitching',
      );
      final itemId = await itemRepo.addItem(
        name: 'Cotton Thread Spool',
        type: 'raw_material',
        unit: 'spools',
        openingQty: 100.0,
      );

      final now = DateTime.now();

      // Insert workerTransactions rows directly: 1 pending, 1 partial, 1 completed
      await database.into(database.workerTransactions).insert(
            WorkerTransactionsCompanion.insert(
              workerId: workerId,
              itemId: itemId,
              quantityIssued: 10.0,
              date: now,
              status: 'pending',
              createdAt: Value(now),
            ),
          );

      await database.into(database.workerTransactions).insert(
            WorkerTransactionsCompanion.insert(
              workerId: workerId,
              itemId: itemId,
              quantityIssued: 5.0,
              date: now,
              status: 'partial',
              createdAt: Value(now),
            ),
          );

      await database.into(database.workerTransactions).insert(
            WorkerTransactionsCompanion.insert(
              workerId: workerId,
              itemId: itemId,
              quantityIssued: 20.0,
              date: now,
              status: 'completed',
              createdAt: Value(now),
            ),
          );

      // Verify pending item count logic
      final pendingCounts = await workerRepo.getPendingItemCounts();
      expect(pendingCounts[workerId], equals(2)); // pending + partial = 2 (completed ignored)

      final singleCount = await workerRepo.getPendingItemCount(workerId);
      expect(singleCount, equals(2));

      final worker = await workerRepo.getWorkerById(workerId);
      expect(worker!.pendingItemCount, equals(2));
    });
  });
}
