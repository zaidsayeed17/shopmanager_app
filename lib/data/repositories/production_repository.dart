import 'package:drift/drift.dart';
import '../db/app_database.dart';
import '../models/item_model.dart';

class PendingMaterialForWorker {
  final int itemId;
  final ItemModel item;
  final double originalQuantityIssued;
  final double remainingPendingQuantity;
  final DateTime issueDate;
  final List<int> workerTransactionIds;

  const PendingMaterialForWorker({
    required this.itemId,
    required this.item,
    required this.originalQuantityIssued,
    required this.remainingPendingQuantity,
    required this.issueDate,
    required this.workerTransactionIds,
  });
}

class ProductionInputLine {
  final int itemId;
  final double quantityUsed;
  final double quantityReturned;

  const ProductionInputLine({
    required this.itemId,
    required this.quantityUsed,
    this.quantityReturned = 0.0,
  });
}

class ProductionRepository {
  final AppDatabase _db;

  ProductionRepository(this._db);

  double _round3(double val) {
    return (val * 1000).round() / 1000;
  }

  /// Fetch list of raw materials pending with a worker.
  /// Only includes items where remaining pending quantity > 0.
  Future<List<PendingMaterialForWorker>> getPendingMaterialsForWorker(int workerId) async {
    // 1. Fetch pending or partial worker transactions for worker
    final txQuery = _db.select(_db.workerTransactions)
      ..where((t) =>
          t.workerId.equals(workerId) &
          (t.status.equals('pending') | t.status.equals('partial')))
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.asc)]);

    final txEntities = await txQuery.get();
    if (txEntities.isEmpty) return [];

    // Group transaction entities by itemId
    final itemTxMap = <int, List<WorkerTransactionEntity>>{};
    for (final tx in txEntities) {
      itemTxMap.putIfAbsent(tx.itemId, () => []).add(tx);
    }

    final results = <PendingMaterialForWorker>[];

    for (final entry in itemTxMap.entries) {
      final itemId = entry.key;
      final txs = entry.value;

      // Fetch item entity
      final itemQuery = _db.select(_db.items)..where((t) => t.id.equals(itemId));
      final itemEntity = await itemQuery.getSingleOrNull();
      if (itemEntity == null) continue;

      // Total issued to worker across all transactions for this itemId
      final allTxsQuery = _db.select(_db.workerTransactions)
        ..where((t) => t.workerId.equals(workerId) & t.itemId.equals(itemId));
      final allTxs = await allTxsQuery.get();
      final totalIssued = _round3(allTxs.fold<double>(0, (sum, t) => sum + t.quantityIssued));

      // Calculate total consumed/returned via productionInputs for this worker & item
      final prodQuery = _db.select(_db.productionInputs).join([
        innerJoin(
          _db.productionRecords,
          _db.productionRecords.id.equalsExp(_db.productionInputs.productionRecordId),
        ),
      ])..where(_db.productionRecords.workerId.equals(workerId) & _db.productionInputs.itemId.equals(itemId));

      final prodRows = await prodQuery.get();
      double totalAccountedFor = 0;
      for (final row in prodRows) {
        final input = row.readTable(_db.productionInputs);
        totalAccountedFor += (input.quantityUsed + input.quantityReturned);
      }
      totalAccountedFor = _round3(totalAccountedFor);

      final remaining = _round3(totalIssued - totalAccountedFor);
      if (remaining <= 0) continue;

      final originalIssued = _round3(txs.fold<double>(0, (sum, t) => sum + t.quantityIssued));
      final earliestDate = txs.map((t) => t.date).reduce((a, b) => a.isBefore(b) ? a : b);

      results.add(
        PendingMaterialForWorker(
          itemId: itemId,
          item: ItemModel.fromEntity(itemEntity),
          originalQuantityIssued: originalIssued,
          remainingPendingQuantity: remaining,
          issueDate: earliestDate,
          workerTransactionIds: txs.map((t) => t.id).toList(),
        ),
      );
    }

    return results;
  }

  /// Record a production event.
  /// Validates:
  /// - inputs not empty
  /// - outputItemId set (> 0) and outputQty > 0
  /// - date not in future
  /// - EVERY line's quantityUsed > 0 and quantityUsed <= remainingPendingQuantity for that item/worker
  /// - quantityReturned >= 0 and quantityReturned <= (remainingPendingQuantity - quantityUsed)
  /// Atomically inside Drift transaction:
  /// (a) Insert productionRecords row
  /// (b) Insert productionInputs rows
  ///     If quantityReturned > 0: insert stockTransactions row ('returned_from_worker', +quantityReturned) & increase item.currentQty
  /// (c) Update workerTransactions row(s) status ('completed' if remaining <= 0, else 'partial')
  /// (d) Insert stockTransactions row for output ('production_completed', +outputQty)
  /// (e) Increase output item currentQty by +outputQty
  Future<int> recordProduction({
    required int workerId,
    required DateTime date,
    String? batchRef,
    required List<ProductionInputLine> inputs,
    required int outputItemId,
    required double outputQty,
    String? notes,
  }) async {
    if (inputs.isEmpty) {
      throw ArgumentError('At least one raw material input is required.');
    }
    if (outputItemId <= 0) {
      throw ArgumentError('Please select a finished product.');
    }
    if (outputQty <= 0) {
      throw ArgumentError('Quantity produced must be greater than zero.');
    }
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    if (date.isAfter(todayEnd)) {
      throw ArgumentError('Production date cannot be in the future.');
    }

    // Get current pending materials for worker
    final pendingMaterials = await getPendingMaterialsForWorker(workerId);
    final pendingMap = {for (final p in pendingMaterials) p.itemId: p};

    for (final input in inputs) {
      final pending = pendingMap[input.itemId];
      if (pending == null) {
        throw ArgumentError('Item #${input.itemId} is not pending for this worker.');
      }
      final qUsed = _round3(input.quantityUsed);
      final qRet = _round3(input.quantityReturned);

      if (qUsed <= 0) {
        throw ArgumentError('Quantity used for ${pending.item.name} must be greater than zero.');
      }
      if (qUsed > pending.remainingPendingQuantity + 0.0001) {
        throw ArgumentError(
          'Only ${pending.remainingPendingQuantity} ${pending.item.unit} pending for this worker. Reduce quantity used to ${pending.remainingPendingQuantity} or lower.',
        );
      }
      if (qRet < 0) {
        throw ArgumentError('Quantity returned cannot be negative.');
      }
      final maxReturn = _round3(pending.remainingPendingQuantity - qUsed);
      if (qRet > maxReturn + 0.0001) {
        throw ArgumentError('Quantity returned cannot exceed remaining leftover ($maxReturn ${pending.item.unit}).');
      }
    }

    // Fetch worker entity for notes
    final workerEntity = await (_db.select(_db.workers)..where((t) => t.id.equals(workerId))).getSingle();
    final roundedOutputQty = _round3(outputQty);

    return await _db.transaction(() async {
      final createdAt = DateTime.now();

      // (a) Insert productionRecords row
      final prodRecordCompanion = ProductionRecordsCompanion.insert(
        workerId: workerId,
        outputItemId: outputItemId,
        outputQty: roundedOutputQty,
        date: date,
        batchRef: Value(batchRef?.trim().isEmpty == true ? null : batchRef?.trim()),
        notes: Value(notes?.trim().isEmpty == true ? null : notes?.trim()),
        createdAt: Value(createdAt),
      );
      final productionRecordId = await _db.into(_db.productionRecords).insert(prodRecordCompanion);

      // (b) For each input line
      for (final input in inputs) {
        final qUsed = _round3(input.quantityUsed);
        final qRet = _round3(input.quantityReturned);

        final prodInputCompanion = ProductionInputsCompanion.insert(
          productionRecordId: productionRecordId,
          itemId: input.itemId,
          quantityUsed: qUsed,
          quantityReturned: Value(qRet),
          createdAt: Value(createdAt),
        );
        await _db.into(_db.productionInputs).insert(prodInputCompanion);

        // If returned > 0, insert returned_from_worker stock transaction and update raw item stock
        if (qRet > 0) {
          final stockTxCompanion = StockTransactionsCompanion.insert(
            itemId: input.itemId,
            type: 'returned_from_worker',
            quantity: qRet,
            referenceType: const Value('production'),
            referenceId: Value(productionRecordId),
            date: date,
            notes: Value('Returned from ${workerEntity.name}'),
            createdAt: Value(createdAt),
          );
          await _db.into(_db.stockTransactions).insert(stockTxCompanion);

          final itemEntity = await (_db.select(_db.items)..where((t) => t.id.equals(input.itemId))).getSingle();
          final updatedRawQty = _round3(itemEntity.currentQty + qRet);
          await (_db.update(_db.items)..where((t) => t.id.equals(input.itemId))).write(
            ItemsCompanion(currentQty: Value(updatedRawQty)),
          );
        }

        // (c) Update workerTransactions row(s) status for input.itemId
        final pendingInfo = pendingMap[input.itemId]!;
        final newRemaining = _round3(pendingInfo.remainingPendingQuantity - (qUsed + qRet));
        final newStatus = newRemaining <= 0.0001 ? 'completed' : 'partial';

        for (final txId in pendingInfo.workerTransactionIds) {
          await (_db.update(_db.workerTransactions)..where((t) => t.id.equals(txId))).write(
            WorkerTransactionsCompanion(status: Value(newStatus)),
          );
        }
      }

      // (d) Insert ONE stockTransactions row for the output
      final outputTxCompanion = StockTransactionsCompanion.insert(
        itemId: outputItemId,
        type: 'production_completed',
        quantity: roundedOutputQty,
        referenceType: const Value('production'),
        referenceId: Value(productionRecordId),
        date: date,
        notes: Value(batchRef?.trim().isNotEmpty == true ? batchRef!.trim() : 'Production output'),
        createdAt: Value(createdAt),
      );
      await _db.into(_db.stockTransactions).insert(outputTxCompanion);

      // (e) Increase items.currentQty for outputItemId
      final outputItemEntity = await (_db.select(_db.items)..where((t) => t.id.equals(outputItemId))).getSingle();
      final updatedOutputQty = _round3(outputItemEntity.currentQty + roundedOutputQty);
      await (_db.update(_db.items)..where((t) => t.id.equals(outputItemId))).write(
        ItemsCompanion(currentQty: Value(updatedOutputQty)),
      );

      return productionRecordId;
    });
  }

  /// Get Worker Material Report for all workers with pending/partial material issuances
  Future<WorkerMaterialReportData> getWorkerMaterialReport() async {
    final workers = await (_db.select(_db.workers)..orderBy([(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)])).get();

    final items = <WorkerMaterialReportItem>[];
    final distinctWorkerIds = <int>{};

    for (final worker in workers) {
      final pendingList = await getPendingMaterialsForWorker(worker.id);
      for (final p in pendingList) {
        if (p.remainingPendingQuantity > 0) {
          distinctWorkerIds.add(worker.id);
          items.add(
            WorkerMaterialReportItem(
              workerId: worker.id,
              workerName: worker.name,
              itemId: p.itemId,
              itemName: p.item.name,
              itemUnit: p.item.unit,
              originalIssuedQty: p.originalQuantityIssued,
              remainingPendingQty: p.remainingPendingQuantity,
              issueDate: p.issueDate,
            ),
          );
        }
      }
    }

    return WorkerMaterialReportData(
      items: items,
      distinctWorkersCount: distinctWorkerIds.length,
      pendingLineItemsCount: items.length,
    );
  }

  /// Get Worker Production Report for date range [from] to [to]
  Future<WorkerProductionReportData> getWorkerProductionReport({
    DateTime? from,
    DateTime? to,
  }) async {
    final now = DateTime.now();
    final startDate = from != null ? DateTime(from.year, from.month, from.day) : DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30));
    final endDate = to != null ? DateTime(to.year, to.month, to.day, 23, 59, 59) : DateTime(now.year, now.month, now.day, 23, 59, 59);

    final query = _db.select(_db.productionRecords).join([
      innerJoin(_db.workers, _db.workers.id.equalsExp(_db.productionRecords.workerId)),
      innerJoin(_db.items, _db.items.id.equalsExp(_db.productionRecords.outputItemId)),
    ])
      ..where(_db.productionRecords.date.isBetweenValues(startDate, endDate))
      ..orderBy([
        OrderingTerm(expression: _db.productionRecords.date, mode: OrderingMode.desc),
        OrderingTerm(expression: _db.productionRecords.id, mode: OrderingMode.desc),
      ]);

    final rows = await query.get();

    final items = <WorkerProductionItem>[];
    final activeWorkerIds = <int>{};

    for (final row in rows) {
      final rec = row.readTable(_db.productionRecords);
      final worker = row.readTable(_db.workers);
      final outputItem = row.readTable(_db.items);

      activeWorkerIds.add(worker.id);

      items.add(
        WorkerProductionItem(
          id: rec.id,
          date: rec.date,
          workerName: worker.name,
          batchRef: rec.batchRef,
          outputItemName: outputItem.name,
          outputItemUnit: outputItem.unit,
          outputQty: rec.outputQty,
        ),
      );
    }

    return WorkerProductionReportData(
      items: items,
      totalEvents: items.length,
      activeWorkersCount: activeWorkerIds.length,
    );
  }
}

class WorkerMaterialReportItem {
  final int workerId;
  final String workerName;
  final int itemId;
  final String itemName;
  final String itemUnit;
  final double originalIssuedQty;
  final double remainingPendingQty;
  final DateTime issueDate;

  const WorkerMaterialReportItem({
    required this.workerId,
    required this.workerName,
    required this.itemId,
    required this.itemName,
    required this.itemUnit,
    required this.originalIssuedQty,
    required this.remainingPendingQty,
    required this.issueDate,
  });
}

class WorkerMaterialReportData {
  final List<WorkerMaterialReportItem> items;
  final int distinctWorkersCount;
  final int pendingLineItemsCount;

  const WorkerMaterialReportData({
    required this.items,
    required this.distinctWorkersCount,
    required this.pendingLineItemsCount,
  });
}

class WorkerProductionItem {
  final int id;
  final DateTime date;
  final String workerName;
  final String? batchRef;
  final String outputItemName;
  final String outputItemUnit;
  final double outputQty;

  const WorkerProductionItem({
    required this.id,
    required this.date,
    required this.workerName,
    this.batchRef,
    required this.outputItemName,
    required this.outputItemUnit,
    required this.outputQty,
  });
}

class WorkerProductionReportData {
  final List<WorkerProductionItem> items;
  final int totalEvents;
  final int activeWorkersCount;

  const WorkerProductionReportData({
    required this.items,
    required this.totalEvents,
    required this.activeWorkersCount,
  });
}
