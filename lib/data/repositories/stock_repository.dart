import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../db/app_database.dart';

class StockTransactionWithBalance {
  final StockTransactionEntity transaction;
  final double runningBalance;

  const StockTransactionWithBalance({
    required this.transaction,
    required this.runningBalance,
  });

  bool get isPositive => transaction.quantity > 0;
  bool get isNegative => transaction.quantity < 0;

  String get formattedTypeLabel {
    if (transaction.type == 'adjustment_decrease') {
      final notes = transaction.notes?.toLowerCase() ?? '';
      if (notes.contains('wastage')) {
        return 'Wastage';
      }
    }
    switch (transaction.type) {
      case 'opening_stock':
        return 'Opening Stock';
      case 'purchase':
        return 'Purchase';
      case 'adjustment_increase':
        return 'Adjustment (+)';
      case 'adjustment_decrease':
        return 'Adjustment (−)';
      case 'issued_to_worker':
        return 'Issued to Worker';
      case 'returned_from_worker':
        return 'Returned from Worker';
      case 'production_completed':
        return 'Production Completed';
      case 'sold':
        return 'Sold in Bill';
      case 'worker_cutting':
        return 'Worker Cutting';
      case 'ready_stock_transfer':
        return 'Stock In';
      case 'ready_stock_out':
        return 'Stock Out';
      default:
        return 'Stock Movement';
    }
  }

  IconData get typeIcon {
    if (transaction.type == 'adjustment_decrease') {
      final notes = transaction.notes?.toLowerCase() ?? '';
      if (notes.contains('wastage')) {
        return Icons.delete_outline;
      }
    }
    switch (transaction.type) {
      case 'opening_stock':
        return Icons.inventory_2_outlined;
      case 'purchase':
        return Icons.shopping_cart_outlined;
      case 'adjustment_increase':
        return Icons.add_circle_outline;
      case 'adjustment_decrease':
        return Icons.remove_circle_outline;
      case 'issued_to_worker':
        return Icons.assignment_ind_outlined;
      case 'returned_from_worker':
        return Icons.assignment_return_outlined;
      case 'production_completed':
        return Icons.precision_manufacturing_outlined;
      case 'sold':
        return Icons.receipt_long_outlined;
      case 'worker_cutting':
        return Icons.content_cut_outlined;
      case 'ready_stock_transfer':
        return Icons.move_to_inbox_outlined;
      case 'ready_stock_out':
        return Icons.outbox_outlined;
      default:
        return Icons.compare_arrows_outlined;
    }
  }

  Color get iconColor {
    switch (transaction.type) {
      case 'opening_stock':
        return AppColors.primary;
      case 'purchase':
        return AppColors.success;
      case 'adjustment_increase':
        return AppColors.success;
      case 'adjustment_decrease':
        return AppColors.critical;
      case 'issued_to_worker':
        return AppColors.tertiary;
      case 'returned_from_worker':
        return AppColors.info;
      case 'production_completed':
        return AppColors.secondary;
      case 'sold':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }
}

class StockRepository {
  final AppDatabase _db;

  StockRepository(this._db);

  /// Helper method to round floating-point numbers to 3 decimal places
  static double round3(double value) {
    return (value * 1000).roundToDouble() / 1000;
  }

  /// Watch stock transactions for a specific item with computed running balance
  Stream<List<StockTransactionWithBalance>> watchItemTransactions(int itemId) {
    final query = _db.select(_db.stockTransactions)
      ..where((t) => t.itemId.equals(itemId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.date, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc),
      ]);

    return query.watch().map((entities) {
      double running = 0.0;
      final result = <StockTransactionWithBalance>[];

      for (final entity in entities) {
        running = round3(running + entity.quantity);
        result.add(StockTransactionWithBalance(
          transaction: entity,
          runningBalance: running,
        ));
      }

      // Present most-recent-first
      return result.reversed.toList();
    });
  }

  /// Get stock transactions for a specific item with computed running balance
  Future<List<StockTransactionWithBalance>> getItemTransactions(int itemId) async {
    final query = _db.select(_db.stockTransactions)
      ..where((t) => t.itemId.equals(itemId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.date, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc),
      ]);

    final entities = await query.get();
    double running = 0.0;
    final result = <StockTransactionWithBalance>[];

    for (final entity in entities) {
      running = round3(running + entity.quantity);
      result.add(StockTransactionWithBalance(
        transaction: entity,
        runningBalance: running,
      ));
    }

    return result.reversed.toList();
  }

  /// Record a purchase inside a single transaction
  Future<int> recordPurchase({
    required int itemId,
    required double quantity,
    required double unitRate,
    required DateTime date,
    String? supplier,
    String? notes,
    bool updateItemRate = true,
  }) async {
    if (quantity <= 0) {
      throw ArgumentError('Purchase quantity must be greater than zero.');
    }
    if (unitRate < 0) {
      throw ArgumentError('Purchase rate cannot be negative.');
    }

    return await _db.transaction(() async {
      final itemQuery = _db.select(_db.items)..where((t) => t.id.equals(itemId));
      final item = await itemQuery.getSingleOrNull();
      if (item == null) {
        throw Exception('Item with ID $itemId not found.');
      }

      String? finalNotes;
      if (supplier != null && supplier.trim().isNotEmpty) {
        final prefix = 'Supplier: ${supplier.trim()}';
        finalNotes = (notes != null && notes.trim().isNotEmpty)
            ? '$prefix • ${notes.trim()}'
            : prefix;
      } else {
        finalNotes = (notes?.trim().isEmpty == true) ? null : notes?.trim();
      }

      final roundedQty = round3(quantity);
      final roundedRate = round3(unitRate);
      final now = DateTime.now();

      final txCompanion = StockTransactionsCompanion.insert(
        itemId: itemId,
        type: 'purchase',
        quantity: roundedQty,
        unitRate: Value(roundedRate),
        referenceType: const Value('manual'),
        referenceId: const Value(null),
        date: date,
        notes: Value(finalNotes),
        createdAt: Value(now),
      );

      final txId = await _db.into(_db.stockTransactions).insert(txCompanion);

      final newQty = round3(item.currentQty + roundedQty);
      await (_db.update(_db.items)..where((t) => t.id.equals(itemId))).write(
        ItemsCompanion(
          currentQty: Value(newQty),
          purchaseRate: updateItemRate ? Value(roundedRate) : const Value.absent(),
        ),
      );

      return txId;
    });
  }

  /// Record a stock adjustment inside a single transaction
  Future<int> recordAdjustment({
    required int itemId,
    required bool isIncrease,
    required double quantity,
    required String reason,
    required DateTime date,
    String? notes,
  }) async {
    if (quantity <= 0) {
      throw ArgumentError('Adjustment quantity must be greater than zero.');
    }

    return await _db.transaction(() async {
      final itemQuery = _db.select(_db.items)..where((t) => t.id.equals(itemId));
      final item = await itemQuery.getSingleOrNull();
      if (item == null) {
        throw Exception('Item with ID $itemId not found.');
      }

      final roundedQty = round3(quantity);

      if (!isIncrease && roundedQty > item.currentQty) {
        final unitStr = item.unit;
        final currStr = item.currentQty.toStringAsFixed(
            item.currentQty.truncateToDouble() == item.currentQty ? 0 : 2);
        throw Exception(
            'Only $currStr $unitStr in stock. An adjustment can\'t take stock below zero.');
      }

      final signedQty = isIncrease ? roundedQty : round3(-roundedQty);
      final type = isIncrease ? 'adjustment_increase' : 'adjustment_decrease';

      String formattedNotes = reason.trim();
      if (notes != null && notes.trim().isNotEmpty) {
        formattedNotes = '$reason — ${notes.trim()}';
      }

      final now = DateTime.now();
      final txCompanion = StockTransactionsCompanion.insert(
        itemId: itemId,
        type: type,
        quantity: signedQty,
        unitRate: const Value(null),
        referenceType: const Value('manual'),
        referenceId: const Value(null),
        date: date,
        notes: Value(formattedNotes),
        createdAt: Value(now),
      );

      final txId = await _db.into(_db.stockTransactions).insert(txCompanion);

      final newQty = round3(item.currentQty + signedQty);
      await (_db.update(_db.items)..where((t) => t.id.equals(itemId))).write(
        ItemsCompanion(
          currentQty: Value(newQty),
        ),
      );

      return txId;
    });
  }

  /// Get Stock Movement Report for date range [from] to [to] and optional [typeFilter]
  Future<StockMovementReportData> getStockMovementReport({
    DateTime? from,
    DateTime? to,
    String? typeFilter,
  }) async {
    final now = DateTime.now();
    final startDate = from != null ? DateTime(from.year, from.month, from.day) : DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30));
    final endDate = to != null ? DateTime(to.year, to.month, to.day, 23, 59, 59) : DateTime(now.year, now.month, now.day, 23, 59, 59);

    var query = _db.select(_db.stockTransactions).join([
      innerJoin(_db.items, _db.items.id.equalsExp(_db.stockTransactions.itemId)),
    ])..where(_db.stockTransactions.date.isBetweenValues(startDate, endDate));

    if (typeFilter != null && typeFilter.isNotEmpty && typeFilter.toLowerCase() != 'all') {
      query = query..where(_db.stockTransactions.type.equals(typeFilter));
    }

    query = query..orderBy([
      OrderingTerm(expression: _db.stockTransactions.date, mode: OrderingMode.desc),
      OrderingTerm(expression: _db.stockTransactions.id, mode: OrderingMode.desc),
    ]);

    final rows = await query.get();

    final items = <StockMovementItem>[];
    int stockInCount = 0;
    int stockOutCount = 0;

    for (final row in rows) {
      final tx = row.readTable(_db.stockTransactions);
      final item = row.readTable(_db.items);

      if (tx.quantity > 0) {
        stockInCount++;
      } else if (tx.quantity < 0) {
        stockOutCount++;
      }

      items.add(
        StockMovementItem(
          id: tx.id,
          date: tx.date,
          itemName: item.name,
          itemUnit: item.unit,
          type: tx.type,
          quantity: tx.quantity,
          referenceNote: tx.notes,
        ),
      );
    }

    return StockMovementReportData(
      items: items,
      stockInCount: stockInCount,
      stockOutCount: stockOutCount,
      totalEvents: items.length,
    );
  }

  /// Record Ready Stock Movement (Stock In / Stock Out) inside a single transaction.
  /// Stock Out is hard-blocked if quantity exceeds current available stock.
  Future<int> recordReadyStockMovement({
    required int itemId,
    required double quantity,
    required bool isStockIn,
    required DateTime date,
    String? remark,
  }) async {
    if (quantity <= 0) {
      throw ArgumentError('Movement quantity must be greater than zero.');
    }

    return await _db.transaction(() async {
      final itemQuery = _db.select(_db.items)..where((t) => t.id.equals(itemId));
      final item = await itemQuery.getSingleOrNull();
      if (item == null) {
        throw Exception('Item with ID $itemId not found.');
      }
      if (item.type != 'ready_stock') {
        throw ArgumentError('Item #${item.id} is not a Ready Stock item.');
      }

      final roundedQty = round3(quantity);

      if (!isStockIn && roundedQty > item.currentQty + 0.0001) {
        throw ArgumentError(
          'Stock Out quantity (${roundedQty.toStringAsFixed(1)} ${item.unit}) cannot exceed available stock (${item.currentQty.toStringAsFixed(1)} ${item.unit}).',
        );
      }

      final signedQty = isStockIn ? roundedQty : -roundedQty;
      final typeStr = isStockIn ? 'ready_stock_transfer' : 'ready_stock_out';
      final noteStr = remark?.trim().isNotEmpty == true
          ? remark!.trim()
          : (isStockIn ? 'Ready Stock In' : 'Ready Stock Out');
      final now = DateTime.now();

      final txCompanion = StockTransactionsCompanion.insert(
        itemId: itemId,
        type: typeStr,
        quantity: signedQty,
        unitRate: Value(item.sellingRate > 0 ? item.sellingRate : item.purchaseRate),
        referenceType: const Value('manual'),
        referenceId: const Value(null),
        date: date,
        notes: Value(noteStr),
        createdAt: Value(now),
      );

      final txId = await _db.into(_db.stockTransactions).insert(txCompanion);

      final newQty = round3(item.currentQty + signedQty);
      await (_db.update(_db.items)..where((t) => t.id.equals(itemId))).write(
        ItemsCompanion(currentQty: Value(newQty)),
      );

      return txId;
    });
  }
}

class StockMovementItem {
  final int id;
  final DateTime date;
  final String itemName;
  final String itemUnit;
  final String type;
  final double quantity;
  final String? referenceNote;

  const StockMovementItem({
    required this.id,
    required this.date,
    required this.itemName,
    required this.itemUnit,
    required this.type,
    required this.quantity,
    this.referenceNote,
  });
}

class StockMovementReportData {
  final List<StockMovementItem> items;
  final int stockInCount;
  final int stockOutCount;
  final int totalEvents;

  const StockMovementReportData({
    required this.items,
    required this.stockInCount,
    required this.stockOutCount,
    required this.totalEvents,
  });
}
