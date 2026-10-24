import 'package:drift/drift.dart';
import '../db/app_database.dart';
import '../models/worker_model.dart';

class WorkerRepository {
  final AppDatabase _db;

  WorkerRepository(this._db);

  /// Fetch counts of pending/partial item transactions grouped by workerId
  Future<Map<int, int>> getPendingItemCounts() async {
    final workerIdCol = _db.workerTransactions.workerId;
    final countCol = workerIdCol.count();

    final query = _db.selectOnly(_db.workerTransactions)
      ..addColumns([workerIdCol, countCol])
      ..where(_db.workerTransactions.status.equals('pending') |
          _db.workerTransactions.status.equals('partial'))
      ..groupBy([workerIdCol]);

    final rows = await query.get();
    final result = <int, int>{};
    for (final row in rows) {
      final wId = row.read(workerIdCol);
      final count = row.read(countCol);
      if (wId != null && count != null) {
        result[wId] = count;
      }
    }
    return result;
  }

  /// Get count of pending/partial transactions for a single worker
  Future<int> getPendingItemCount(int workerId) async {
    final countCol = _db.workerTransactions.id.count();
    final query = _db.selectOnly(_db.workerTransactions)
      ..addColumns([countCol])
      ..where(_db.workerTransactions.workerId.equals(workerId) &
          (_db.workerTransactions.status.equals('pending') |
              _db.workerTransactions.status.equals('partial')));

    final result = await query.map((row) => row.read(countCol)).getSingle();
    return result ?? 0;
  }

  /// Fetch all workers ordered by name with pending counts merged
  Future<List<WorkerModel>> getAllWorkers() async {
    final query = _db.select(_db.workers)
      ..orderBy([
        (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)
      ]);
    final entities = await query.get();
    final pendingCounts = await getPendingItemCounts();

    return entities
        .map((e) => WorkerModel.fromEntity(e, pendingItemCount: pendingCounts[e.id] ?? 0))
        .toList();
  }

  /// Watch all workers in real time with pending counts merged
  Stream<List<WorkerModel>> watchAllWorkers() {
    final query = _db.select(_db.workers)
      ..orderBy([
        (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)
      ]);

    return query.watch().asyncMap((entities) async {
      final pendingCounts = await getPendingItemCounts();
      return entities
          .map((e) => WorkerModel.fromEntity(e, pendingItemCount: pendingCounts[e.id] ?? 0))
          .toList();
    });
  }

  /// Get a single worker by ID with pending item count
  Future<WorkerModel?> getWorkerById(int id) async {
    final query = _db.select(_db.workers)..where((t) => t.id.equals(id));
    final entity = await query.getSingleOrNull();
    if (entity == null) return null;
    final pendingCount = await getPendingItemCount(id);
    return WorkerModel.fromEntity(entity, pendingItemCount: pendingCount);
  }

  /// Search workers by name, mobile, or workType (case-insensitive)
  Future<List<WorkerModel>> searchWorkers(String queryText) async {
    if (queryText.trim().isEmpty) {
      return getAllWorkers();
    }
    final pattern = '%${queryText.trim().toLowerCase()}%';
    final query = _db.select(_db.workers)
      ..where((t) =>
          t.name.lower().like(pattern) |
          t.mobile.like(pattern) |
          t.workType.lower().like(pattern))
      ..orderBy([
        (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)
      ]);

    final entities = await query.get();
    final pendingCounts = await getPendingItemCounts();

    return entities
        .map((e) => WorkerModel.fromEntity(e, pendingItemCount: pendingCounts[e.id] ?? 0))
        .toList();
  }

  /// Add a new worker
  Future<int> addWorker({
    required String name,
    String? mobile,
    String? workType,
    String? address,
    String? notes,
    DateTime? joiningDate,
    String? paymentType,
    double? defaultHourRate,
    double? defaultNagRate,
  }) async {
    final companion = WorkersCompanion.insert(
      name: name.trim(),
      mobile: Value(mobile?.trim().isEmpty == true ? null : mobile?.trim()),
      workType: Value(workType?.trim().isEmpty == true ? null : workType?.trim()),
      address: Value(address?.trim().isEmpty == true ? null : address?.trim()),
      notes: Value(notes?.trim().isEmpty == true ? null : notes?.trim()),
      joiningDate: Value(joiningDate),
      paymentType: Value(paymentType?.trim().isEmpty == true ? null : paymentType?.trim()),
      defaultHourRate: Value(defaultHourRate),
      defaultNagRate: Value(defaultNagRate),
      isActive: const Value(true),
      createdAt: Value(DateTime.now()),
    );
    return await _db.into(_db.workers).insert(companion);
  }

  /// Update an existing worker
  Future<bool> updateWorker({
    required int id,
    required String name,
    String? mobile,
    String? workType,
    String? address,
    String? notes,
    bool? isActive,
    DateTime? joiningDate,
    String? paymentType,
    double? defaultHourRate,
    double? defaultNagRate,
  }) async {
    final statement = _db.update(_db.workers)..where((t) => t.id.equals(id));
    final updatedRows = await statement.write(
      WorkersCompanion(
        name: Value(name.trim()),
        mobile: Value(mobile?.trim().isEmpty == true ? null : mobile?.trim()),
        workType: Value(workType?.trim().isEmpty == true ? null : workType?.trim()),
        address: Value(address?.trim().isEmpty == true ? null : address?.trim()),
        notes: Value(notes?.trim().isEmpty == true ? null : notes?.trim()),
        isActive: isActive != null ? Value(isActive) : const Value.absent(),
        joiningDate: Value(joiningDate),
        paymentType: Value(paymentType?.trim().isEmpty == true ? null : paymentType?.trim()),
        defaultHourRate: Value(defaultHourRate),
        defaultNagRate: Value(defaultNagRate),
      ),
    );
    return updatedRows > 0;
  }

  /// Activate or deactivate a worker (never hard-delete)
  Future<bool> setWorkerActive(int id, bool isActive) async {
    final statement = _db.update(_db.workers)..where((t) => t.id.equals(id));
    final updatedRows = await statement.write(
      WorkersCompanion(
        isActive: Value(isActive),
      ),
    );
    return updatedRows > 0;
  }

  /// Count of distinct workers currently processing pending material
  Future<WorkersPendingSummary> getWorkersWithPendingSummary() async {
    final pendingCounts = await getPendingItemCounts();
    return WorkersPendingSummary(workersWithPendingCount: pendingCounts.length);
  }

  /// Preview of top N pending worker transactions across all workers
  Future<List<PendingMaterialPreview>> getPendingMaterialPreview({int limit = 3}) async {
    final query = _db.select(_db.workerTransactions).join([
      innerJoin(_db.workers, _db.workers.id.equalsExp(_db.workerTransactions.workerId)),
      innerJoin(_db.items, _db.items.id.equalsExp(_db.workerTransactions.itemId)),
    ])
      ..where(_db.workerTransactions.status.equals('pending') |
          _db.workerTransactions.status.equals('partial'))
      ..orderBy([
        OrderingTerm(expression: _db.workerTransactions.id, mode: OrderingMode.desc),
      ])
      ..limit(limit * 2);

    final rows = await query.get();
    final result = <PendingMaterialPreview>[];

    for (final r in rows) {
      final tx = r.readTable(_db.workerTransactions);
      final worker = r.readTable(_db.workers);
      final item = r.readTable(_db.items);

      final prodQuery = _db.select(_db.productionInputs).join([
        innerJoin(
          _db.productionRecords,
          _db.productionRecords.id.equalsExp(_db.productionInputs.productionRecordId),
        ),
      ])..where(_db.productionRecords.workerId.equals(worker.id) & _db.productionInputs.itemId.equals(item.id));

      final prodRows = await prodQuery.get();
      double totalAccounted = 0;
      for (final prow in prodRows) {
        final inp = prow.readTable(_db.productionInputs);
        totalAccounted += (inp.quantityUsed + inp.quantityReturned);
      }

      final remaining = ((tx.quantityIssued - totalAccounted) * 1000).roundToDouble() / 1000.0;
      if (remaining > 0) {
        result.add(PendingMaterialPreview(
          id: tx.id,
          workerId: worker.id,
          workerName: worker.name,
          itemName: item.name,
          remainingQty: remaining,
          unit: item.unit,
          status: tx.status == 'partial' ? 'Partial' : 'Pending',
          date: tx.date,
        ));
        if (result.length >= limit) break;
      }
    }

    return result;
  }
}

class PendingMaterialPreview {
  final int id;
  final int workerId;
  final String workerName;
  final String itemName;
  final double remainingQty;
  final String unit;
  final String status;
  final DateTime date;

  const PendingMaterialPreview({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.itemName,
    required this.remainingQty,
    required this.unit,
    required this.status,
    required this.date,
  });
}

class WorkersPendingSummary {
  final int workersWithPendingCount;

  const WorkersPendingSummary({
    required this.workersWithPendingCount,
  });
}
