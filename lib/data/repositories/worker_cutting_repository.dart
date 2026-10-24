import 'package:drift/drift.dart';
import '../db/app_database.dart';

class WorkerCuttingEntryWithItem {
  final WorkerCuttingEntryEntity entry;
  final String itemName;
  final String itemUnit;

  const WorkerCuttingEntryWithItem({
    required this.entry,
    required this.itemName,
    required this.itemUnit,
  });
}

class WorkerCuttingSummaryItem {
  final int itemId;
  final String itemName;
  final double totalQuantity;
  final double totalAmount;

  const WorkerCuttingSummaryItem({
    required this.itemId,
    required this.itemName,
    required this.totalQuantity,
    required this.totalAmount,
  });
}

class WorkerCuttingSummary {
  final List<WorkerCuttingSummaryItem> items;
  final double overallTotalQuantity;
  final double overallTotalAmount;

  const WorkerCuttingSummary({
    required this.items,
    required this.overallTotalQuantity,
    required this.overallTotalAmount,
  });

  factory WorkerCuttingSummary.empty() => const WorkerCuttingSummary(
        items: [],
        overallTotalQuantity: 0.0,
        overallTotalAmount: 0.0,
      );
}

class WorkerCuttingRepository {
  final AppDatabase _db;

  WorkerCuttingRepository(this._db);

  double _round2(double val) {
    return (val * 100).roundToDouble() / 100.0;
  }

  double _round3(double val) {
    return (val * 1000).roundToDouble() / 1000.0;
  }

  /// Add a new worker cutting entry
  /// Deducts colour stock in stockTransactions ('worker_cutting' type, negative quantity)
  /// and updates item's currentQty inside one transaction. Warn-only if stock is insufficient.
  Future<int> addCuttingEntry({
    required int workerId,
    required int itemId,
    required DateTime date,
    required double quantity,
    required double rate,
    String? remark,
  }) async {
    if (quantity <= 0) {
      throw ArgumentError('Cutting quantity must be greater than zero.');
    }
    if (rate <= 0) {
      throw ArgumentError('Cutting rate must be greater than zero.');
    }

    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    if (date.isAfter(todayEnd)) {
      throw ArgumentError('Cutting entry date cannot be in the future.');
    }

    final totalAmount = _round2(quantity * rate);

    // Fetch worker name for transaction note
    final workerQuery = _db.select(_db.workers)..where((t) => t.id.equals(workerId));
    final worker = await workerQuery.getSingleOrNull();

    return await _db.transaction(() async {
      // 1. Insert WorkerCuttingEntries row
      final entryCompanion = WorkerCuttingEntriesCompanion.insert(
        workerId: workerId,
        itemId: itemId,
        date: date,
        quantity: quantity,
        rate: rate,
        totalAmount: Value(totalAmount),
        remark: Value(remark?.trim().isEmpty == true ? null : remark?.trim()),
        createdAt: Value(DateTime.now()),
      );
      final entryId = await _db.into(_db.workerCuttingEntries).insert(entryCompanion);

      // 2. Insert StockTransactions row
      final noteStr =
          'Cut by ${worker?.name ?? 'Worker #$workerId'}${remark != null && remark.trim().isNotEmpty ? ' — ${remark.trim()}' : ''}';
      final txCompanion = StockTransactionsCompanion.insert(
        itemId: itemId,
        type: 'worker_cutting',
        quantity: -quantity,
        unitRate: Value(rate),
        referenceType: const Value('worker_cutting'),
        referenceId: Value(entryId),
        date: date,
        notes: Value(noteStr),
        createdAt: Value(DateTime.now()),
      );
      await _db.into(_db.stockTransactions).insert(txCompanion);

      // 3. Update Item currentQty (warn-only, allowed to go negative)
      final itemQuery = _db.select(_db.items)..where((t) => t.id.equals(itemId));
      final item = await itemQuery.getSingle();
      final updatedQty = _round3(item.currentQty - quantity);
      await (_db.update(_db.items)..where((t) => t.id.equals(itemId))).write(
        ItemsCompanion(currentQty: Value(updatedQty)),
      );

      return entryId;
    });
  }

  /// Get cutting entries for a worker with colour item details
  Future<List<WorkerCuttingEntryWithItem>> getCuttingEntriesForWorker(
    int workerId, {
    DateTime? from,
    DateTime? to,
  }) async {
    var query = _db.select(_db.workerCuttingEntries).join([
      innerJoin(_db.items, _db.items.id.equalsExp(_db.workerCuttingEntries.itemId)),
    ])..where(_db.workerCuttingEntries.workerId.equals(workerId));

    if (from != null) {
      query = query..where(_db.workerCuttingEntries.date.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query = query..where(_db.workerCuttingEntries.date.isSmallerOrEqualValue(to));
    }

    query = query
      ..orderBy([
        OrderingTerm(expression: _db.workerCuttingEntries.date, mode: OrderingMode.desc),
        OrderingTerm(expression: _db.workerCuttingEntries.id, mode: OrderingMode.desc),
      ]);

    final rows = await query.get();
    return rows.map((row) {
      final entry = row.readTable(_db.workerCuttingEntries);
      final item = row.readTable(_db.items);
      return WorkerCuttingEntryWithItem(
        entry: entry,
        itemName: item.name,
        itemUnit: item.unit,
      );
    }).toList();
  }

  /// Watch cutting entries for a worker in real time
  Stream<List<WorkerCuttingEntryWithItem>> watchCuttingEntriesForWorker(int workerId) {
    final query = _db.select(_db.workerCuttingEntries).join([
      innerJoin(_db.items, _db.items.id.equalsExp(_db.workerCuttingEntries.itemId)),
    ])
      ..where(_db.workerCuttingEntries.workerId.equals(workerId))
      ..orderBy([
        OrderingTerm(expression: _db.workerCuttingEntries.date, mode: OrderingMode.desc),
        OrderingTerm(expression: _db.workerCuttingEntries.id, mode: OrderingMode.desc),
      ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final entry = row.readTable(_db.workerCuttingEntries);
        final item = row.readTable(_db.items);
        return WorkerCuttingEntryWithItem(
          entry: entry,
          itemName: item.name,
          itemUnit: item.unit,
        );
      }).toList();
    });
  }

  /// Get today's cutting summary aggregated per colour (defaults to DateTime.now())
  Future<WorkerCuttingSummary> getTodaysCuttingSummary(int workerId, {DateTime? targetDate}) async {
    final now = targetDate ?? DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _getSummaryForPeriod(workerId, startOfDay, endOfDay);
  }

  /// Get monthly cutting summary aggregated per colour for a specific month
  Future<WorkerCuttingSummary> getMonthlyCuttingSummary(
    int workerId, {
    required int year,
    required int month,
  }) async {
    final startOfMonth = DateTime(year, month, 1);
    final nextMonth = month == 12 ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
    final endOfMonth = nextMonth.subtract(const Duration(seconds: 1));

    return _getSummaryForPeriod(workerId, startOfMonth, endOfMonth);
  }

  Future<WorkerCuttingSummary> _getSummaryForPeriod(
    int workerId,
    DateTime from,
    DateTime to,
  ) async {
    final entries = await getCuttingEntriesForWorker(workerId, from: from, to: to);
    if (entries.isEmpty) {
      return WorkerCuttingSummary.empty();
    }

    final map = <int, _SummaryAccumulator>{};
    double overallQty = 0.0;
    double overallAmt = 0.0;

    for (final e in entries) {
      final itemId = e.entry.itemId;
      final acc = map.putIfAbsent(
        itemId,
        () => _SummaryAccumulator(itemId: itemId, itemName: e.itemName),
      );
      acc.totalQuantity += e.entry.quantity;
      acc.totalAmount += e.entry.totalAmount;

      overallQty += e.entry.quantity;
      overallAmt += e.entry.totalAmount;
    }

    final itemsList = map.values
        .map((acc) => WorkerCuttingSummaryItem(
              itemId: acc.itemId,
              itemName: acc.itemName,
              totalQuantity: _round3(acc.totalQuantity),
              totalAmount: _round2(acc.totalAmount),
            ))
        .toList();

    return WorkerCuttingSummary(
      items: itemsList,
      overallTotalQuantity: _round3(overallQty),
      overallTotalAmount: _round2(overallAmt),
    );
  }
}

class _SummaryAccumulator {
  final int itemId;
  final String itemName;
  double totalQuantity = 0.0;
  double totalAmount = 0.0;

  _SummaryAccumulator({required this.itemId, required this.itemName});
}
