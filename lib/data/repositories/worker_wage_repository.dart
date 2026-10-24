import 'package:drift/drift.dart';
import '../db/app_database.dart';

enum WorkEntryPaymentStatus {
  paid,
  partial,
  unpaid;

  String get label {
    switch (this) {
      case WorkEntryPaymentStatus.paid:
        return 'Paid';
      case WorkEntryPaymentStatus.partial:
        return 'Partial';
      case WorkEntryPaymentStatus.unpaid:
        return 'Unpaid';
    }
  }
}

/// Single source of truth for work entry payment status calculation
WorkEntryPaymentStatus getWorkEntryStatus(double totalAmount, double advance) {
  if (advance >= totalAmount - 0.001) {
    return WorkEntryPaymentStatus.paid;
  }
  if (advance > 0.001) {
    return WorkEntryPaymentStatus.partial;
  }
  return WorkEntryPaymentStatus.unpaid;
}

class WorkerWageSummary {
  final double totalHours;
  final double totalNag;
  final double totalEarnings;
  final double totalAdvance;
  final double remainingAmount;

  const WorkerWageSummary({
    required this.totalHours,
    required this.totalNag,
    required this.totalEarnings,
    required this.totalAdvance,
    required this.remainingAmount,
  });

  factory WorkerWageSummary.empty() => const WorkerWageSummary(
        totalHours: 0.0,
        totalNag: 0.0,
        totalEarnings: 0.0,
        totalAdvance: 0.0,
        remainingAmount: 0.0,
      );
}

class WorkerWageRepository {
  final AppDatabase _db;

  WorkerWageRepository(this._db);

  double _round2(double val) {
    return (val * 100).roundToDouble() / 100.0;
  }

  /// Update a worker's saved payment configuration (type and default rates)
  Future<void> updateWorkerPaymentConfig({
    required int workerId,
    required String? paymentType,
    double? defaultHourRate,
    double? defaultNagRate,
  }) async {
    if (paymentType == 'hour' || paymentType == 'both') {
      if (defaultHourRate == null || defaultHourRate <= 0) {
        throw ArgumentError('Default hour rate must be greater than zero for hour-based or both payment type.');
      }
    }
    if (paymentType == 'piece' || paymentType == 'both') {
      if (defaultNagRate == null || defaultNagRate <= 0) {
        throw ArgumentError('Default nag/piece rate must be greater than zero for piece-based or both payment type.');
      }
    }

    final statement = _db.update(_db.workers)..where((t) => t.id.equals(workerId));
    await statement.write(
      WorkersCompanion(
        paymentType: Value(paymentType),
        defaultHourRate: Value(defaultHourRate),
        defaultNagRate: Value(defaultNagRate),
      ),
    );
  }

  /// Add a new daily work entry for a worker
  Future<int> addWorkEntry({
    required int workerId,
    required DateTime date,
    String? workDescription,
    double? hours,
    double? hourRate,
    double? nagQty,
    double? nagRate,
    double advance = 0.0,
    String? notes,
  }) async {
    // 1. Fetch worker to check payment configuration
    final query = _db.select(_db.workers)..where((t) => t.id.equals(workerId));
    final worker = await query.getSingleOrNull();
    if (worker == null) {
      throw ArgumentError('Worker #$workerId does not exist.');
    }
    final pType = worker.paymentType;
    if (pType == null || pType.trim().isEmpty) {
      throw ArgumentError('Worker has no payment type configured. Configure payment type in Edit Worker first.');
    }

    // 2. Validate date (cannot be future)
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    if (date.isAfter(todayEnd)) {
      throw ArgumentError('Work entry date cannot be in the future.');
    }

    // 3. Validate inputs based on paymentType
    final hasHours = hours != null && hours > 0;
    final hasPiece = nagQty != null && nagQty > 0;

    if (pType == 'hour') {
      if (!hasHours) {
        throw ArgumentError('Hours worked must be greater than zero.');
      }
      if (hourRate == null || hourRate <= 0) {
        throw ArgumentError('Hour rate must be greater than zero.');
      }
    } else if (pType == 'piece') {
      if (!hasPiece) {
        throw ArgumentError('Nag/Piece quantity must be greater than zero.');
      }
      if (nagRate == null || nagRate <= 0) {
        throw ArgumentError('Nag/Piece rate must be greater than zero.');
      }
    } else if (pType == 'both') {
      if (!hasHours && !hasPiece) {
        throw ArgumentError('At least one of hours worked or piece quantity must be greater than zero.');
      }
      if (hasHours && (hourRate == null || hourRate <= 0)) {
        throw ArgumentError('Hour rate must be greater than zero.');
      }
      if (hasPiece && (nagRate == null || nagRate <= 0)) {
        throw ArgumentError('Nag/Piece rate must be greater than zero.');
      }
    }

    // 4. Calculate amounts
    final hAmount = (pType == 'hour' || pType == 'both') && hasHours
        ? _round2(hours * (hourRate ?? 0.0))
        : 0.0;
    final nAmount = (pType == 'piece' || pType == 'both') && hasPiece
        ? _round2(nagQty * (nagRate ?? 0.0))
        : 0.0;
    final totAmount = _round2(hAmount + nAmount);

    // 5. Validate advance
    if (advance < 0) {
      throw ArgumentError('Advance cannot be negative.');
    }
    if (advance > totAmount + 0.001) {
      throw ArgumentError(
        'Advance (₹${advance.toStringAsFixed(2)}) cannot exceed total amount earned (₹${totAmount.toStringAsFixed(2)}).',
      );
    }

    final finPayable = _round2(totAmount - advance);

    final companion = WorkWorkEntriesCompanion.insert(
      workerId: workerId,
      date: date,
      workDescription: Value(workDescription?.trim().isEmpty == true ? null : workDescription?.trim()),
      hours: Value((pType == 'hour' || pType == 'both') && hasHours ? hours : null),
      hourRate: Value((pType == 'hour' || pType == 'both') && hasHours ? hourRate : null),
      hourAmount: Value(hAmount),
      nagQty: Value((pType == 'piece' || pType == 'both') && hasPiece ? nagQty : null),
      nagRate: Value((pType == 'piece' || pType == 'both') && hasPiece ? nagRate : null),
      nagAmount: Value(nAmount),
      totalAmount: Value(totAmount),
      advance: Value(_round2(advance)),
      finalPayable: Value(finPayable),
      notes: Value(notes?.trim().isEmpty == true ? null : notes?.trim()),
      createdAt: Value(DateTime.now()),
    );

    return await _db.into(_db.workWorkEntries).insert(companion);
  }

  /// Get all work entries for a worker, most recent first
  Future<List<WorkWorkEntryEntity>> getWorkEntriesForWorker(int workerId) async {
    final query = _db.select(_db.workWorkEntries)
      ..where((t) => t.workerId.equals(workerId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
      ]);
    return await query.get();
  }

  /// Watch work entries for a worker in real time, most recent first
  Stream<List<WorkWorkEntryEntity>> watchWorkEntriesForWorker(int workerId) {
    final query = _db.select(_db.workWorkEntries)
      ..where((t) => t.workerId.equals(workerId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  /// Get summary of wage totals computed LIVE from workWorkEntries table
  Future<WorkerWageSummary> getWorkerWageSummary(int workerId) async {
    final entries = await getWorkEntriesForWorker(workerId);
    if (entries.isEmpty) {
      return WorkerWageSummary.empty();
    }

    double totHours = 0.0;
    double totNag = 0.0;
    double totEarnings = 0.0;
    double totAdvance = 0.0;
    double totRemaining = 0.0;

    for (final e in entries) {
      totHours += e.hours ?? 0.0;
      totNag += e.nagQty ?? 0.0;
      totEarnings += e.totalAmount;
      totAdvance += e.advance;
      totRemaining += e.finalPayable;
    }

    return WorkerWageSummary(
      totalHours: _round2(totHours),
      totalNag: _round2(totNag),
      totalEarnings: _round2(totEarnings),
      totalAdvance: _round2(totAdvance),
      remainingAmount: _round2(totRemaining),
    );
  }
}
