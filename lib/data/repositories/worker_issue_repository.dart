import 'package:drift/drift.dart';
import '../db/app_database.dart';

class IssueLine {
  final int itemId;
  final double quantity;

  const IssueLine({
    required this.itemId,
    required this.quantity,
  });
}

class WorkerIssueRepository {
  final AppDatabase _db;

  WorkerIssueRepository(this._db);

  /// Atomically records handover of raw materials to a worker.
  /// 
  /// For each line:
  /// - Decrements items.currentQty (allowed to go negative).
  /// - Inserts a stockTransactions row with type 'issued_to_worker', quantity -qty, referenceType 'worker', referenceId workerId.
  /// - Inserts a workerTransactions row with workerId, itemId, quantityIssued qty, status 'pending'.
  /// All rows share a unique batch tag in their notes.
  Future<String> issueMaterials({
    required int workerId,
    required DateTime date,
    required List<IssueLine> lines,
    String? notes,
  }) async {
    if (lines.isEmpty) {
      throw ArgumentError('At least one material line is required.');
    }

    for (final line in lines) {
      if (line.quantity <= 0) {
        throw ArgumentError('Quantity must be greater than zero.');
      }
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final batchTag = 'ISSUE-$timestamp';

    await _db.transaction(() async {
      final now = DateTime.now();

      for (final line in lines) {
        // Fetch existing item
        final itemQuery = _db.select(_db.items)..where((t) => t.id.equals(line.itemId));
        final item = await itemQuery.getSingle();

        final updatedQty = item.currentQty - line.quantity;

        // Update item currentQty
        await (_db.update(_db.items)..where((t) => t.id.equals(line.itemId))).write(
          ItemsCompanion(currentQty: Value(updatedQty)),
        );

        final noteText = (notes != null && notes.trim().isNotEmpty)
            ? '${notes.trim()} (Batch: $batchTag)'
            : 'Batch: $batchTag';

        // Insert stock transaction row
        await _db.into(_db.stockTransactions).insert(
          StockTransactionsCompanion.insert(
            itemId: line.itemId,
            type: 'issued_to_worker',
            quantity: -line.quantity,
            referenceType: const Value('worker'),
            referenceId: Value(workerId),
            date: date,
            notes: Value(noteText),
            createdAt: Value(now),
          ),
        );

        // Insert worker transaction row
        await _db.into(_db.workerTransactions).insert(
          WorkerTransactionsCompanion.insert(
            workerId: workerId,
            itemId: line.itemId,
            quantityIssued: line.quantity,
            date: date,
            status: 'pending',
            notes: Value(noteText),
            createdAt: Value(now),
          ),
        );
      }
    });

    return batchTag;
  }
}
