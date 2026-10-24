import 'package:drift/drift.dart';
import '../db/app_database.dart';
import '../models/item_model.dart';

class ItemRepository {
  final AppDatabase _db;

  ItemRepository(this._db);

  /// Fetch all non-ready_stock items ordered by name
  Future<List<ItemModel>> getAllItems() async {
    final query = _db.select(_db.items)
      ..where((t) => t.type.equals('ready_stock').not())
      ..orderBy([
        (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)
      ]);
    final entities = await query.get();
    return entities.map(ItemModel.fromEntity).toList();
  }

  /// Watch all non-ready_stock items in real time
  Stream<List<ItemModel>> watchAllItems() {
    final query = _db.select(_db.items)
      ..where((t) => t.type.equals('ready_stock').not())
      ..orderBy([
        (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)
      ]);
    return query.watch().map((entities) => entities.map(ItemModel.fromEntity).toList());
  }

  /// Fetch all active ready stock items ordered by name
  Future<List<ItemModel>> getReadyStockItems() async {
    final query = _db.select(_db.items)
      ..where((t) => t.isActive.equals(true) & t.type.equals('ready_stock'))
      ..orderBy([
        (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)
      ]);
    final entities = await query.get();
    return entities.map(ItemModel.fromEntity).toList();
  }

  /// Watch all active ready stock items in real time
  Stream<List<ItemModel>> watchReadyStockItems() {
    final query = _db.select(_db.items)
      ..where((t) => t.isActive.equals(true) & t.type.equals('ready_stock'))
      ..orderBy([
        (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)
      ]);
    return query.watch().map((entities) => entities.map(ItemModel.fromEntity).toList());
  }

  /// Get single item by ID
  Future<ItemModel?> getItemById(int id) async {
    final query = _db.select(_db.items)..where((t) => t.id.equals(id));
    final entity = await query.getSingleOrNull();
    return entity != null ? ItemModel.fromEntity(entity) : null;
  }

  /// Fetch all active raw material items ordered by name
  Future<List<ItemModel>> getActiveRawMaterials() async {
    final query = _db.select(_db.items)
      ..where((t) => t.isActive.equals(true) & t.type.equals('raw_material'))
      ..orderBy([
        (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)
      ]);
    final entities = await query.get();
    return entities.map(ItemModel.fromEntity).toList();
  }

  /// Fetch all active finished product items ordered by name
  Future<List<ItemModel>> getFinishedProducts() async {
    final query = _db.select(_db.items)
      ..where((t) => t.isActive.equals(true) & t.type.equals('finished_product'))
      ..orderBy([
        (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)
      ]);
    final entities = await query.get();
    return entities.map(ItemModel.fromEntity).toList();
  }

  /// Search items by name, category, or SKU
  Future<List<ItemModel>> searchItems(String queryText) async {
    if (queryText.trim().isEmpty) {
      return getAllItems();
    }
    final pattern = '%${queryText.trim().toLowerCase()}%';
    final query = _db.select(_db.items)
      ..where((t) => t.name.lower().like(pattern) | t.category.lower().like(pattern) | t.sku.lower().like(pattern))
      ..orderBy([
        (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)
      ]);
    final entities = await query.get();
    return entities.map(ItemModel.fromEntity).toList();
  }

  /// Check if an item name already exists (case-insensitive), optionally excluding an item ID
  Future<bool> itemNameExists(String name, {int? excludeId}) async {
    final cleanName = name.trim().toLowerCase();
    var query = _db.select(_db.items)..where((t) => t.name.lower().equals(cleanName));
    if (excludeId != null) {
      query = query..where((t) => t.id.equals(excludeId).not());
    }
    final existing = await query.get();
    return existing.isNotEmpty;
  }

  /// Add a new item inside a single transaction.
  /// Sets currentQty = openingQty, and if openingQty > 0, inserts an opening_stock transaction row.
  Future<int> addItem({
    required String name,
    String? category,
    String? sku,
    required String type, // 'raw_material' or 'finished_product'
    required String unit,
    double purchaseRate = 0.0,
    double sellingRate = 0.0,
    double? wholesaleRate,
    double openingQty = 0.0,
    double minStockLevel = 0.0,
    String? supplierInfo,
    bool isActive = true,
  }) async {
    return await _db.transaction(() async {
      final now = DateTime.now();
      final itemCompanion = ItemsCompanion.insert(
        name: name.trim(),
        category: Value(category?.trim().isEmpty == true ? null : category?.trim()),
        sku: Value(sku?.trim().isEmpty == true ? null : sku?.trim()),
        type: type,
        unit: unit.trim(),
        purchaseRate: Value(purchaseRate),
        sellingRate: Value(sellingRate),
        wholesaleRate: Value(wholesaleRate),
        openingQty: Value(openingQty),
        currentQty: Value(openingQty),
        minStockLevel: Value(minStockLevel),
        supplierInfo: Value(supplierInfo?.trim().isEmpty == true ? null : supplierInfo?.trim()),
        isActive: Value(isActive),
        createdAt: Value(now),
      );

      final itemId = await _db.into(_db.items).insert(itemCompanion);

      if (openingQty > 0) {
        final txCompanion = StockTransactionsCompanion.insert(
          itemId: itemId,
          type: 'opening_stock',
          quantity: openingQty,
          referenceType: const Value('manual'),
          referenceId: const Value(null),
          date: now,
          notes: const Value('Opening stock'),
          createdAt: Value(now),
        );
        await _db.into(_db.stockTransactions).insert(txCompanion);
      }

      return itemId;
    });
  }

  /// Update item details. Must NOT modify openingQty or currentQty.
  Future<bool> updateItem({
    required int id,
    required String name,
    String? category,
    String? sku,
    required String type,
    required String unit,
    double? purchaseRate,
    double? sellingRate,
    double? wholesaleRate,
    bool clearWholesaleRate = false,
    double? minStockLevel,
    String? supplierInfo,
    bool? isActive,
  }) async {
    final statement = _db.update(_db.items)..where((t) => t.id.equals(id));
    final updatedRows = await statement.write(
      ItemsCompanion(
        name: Value(name.trim()),
        category: Value(category?.trim().isEmpty == true ? null : category?.trim()),
        sku: Value(sku?.trim().isEmpty == true ? null : sku?.trim()),
        type: Value(type),
        unit: Value(unit.trim()),
        purchaseRate: purchaseRate != null ? Value(purchaseRate) : const Value.absent(),
        sellingRate: sellingRate != null ? Value(sellingRate) : const Value.absent(),
        wholesaleRate: clearWholesaleRate ? const Value(null) : (wholesaleRate != null ? Value(wholesaleRate) : const Value.absent()),
        minStockLevel: minStockLevel != null ? Value(minStockLevel) : const Value.absent(),
        supplierInfo: Value(supplierInfo?.trim().isEmpty == true ? null : supplierInfo?.trim()),
        isActive: isActive != null ? Value(isActive) : const Value.absent(),
      ),
    );
    return updatedRows > 0;
  }

  /// Activate or deactivate an item (never hard-delete).
  Future<bool> setItemActive(int id, bool isActive) async {
    final statement = _db.update(_db.items)..where((t) => t.id.equals(id));
    final updatedRows = await statement.write(
      ItemsCompanion(
        isActive: Value(isActive),
      ),
    );
    return updatedRows > 0;
  }

  /// Summary of inventory stock (raw materials count, finished goods count, stock value, low stock count)
  Future<StockOverviewSummary> getStockOverview() async {
    final activeItems = await (_db.select(_db.items)
      ..where((t) => t.isActive.equals(true))).get();

    int rawCount = 0;
    int finishedCount = 0;
    double stockValue = 0.0;
    int lowStockCount = 0;

    for (final item in activeItems) {
      if (item.type == 'raw_material') {
        rawCount++;
      } else if (item.type == 'finished_product') {
        finishedCount++;
      }

      if (item.currentQty > 0) {
        stockValue += (item.currentQty * item.purchaseRate);
      }

      if (item.minStockLevel > 0 && item.currentQty <= item.minStockLevel) {
        lowStockCount++;
      }
    }

    return StockOverviewSummary(
      rawMaterialCount: rawCount,
      finishedProductCount: finishedCount,
      totalStockValue: (stockValue * 100).roundToDouble() / 100.0,
      lowStockCount: lowStockCount,
    );
  }

  /// Get Stock Report breakdown for active items
  Future<StockReportData> getStockReport() async {
    final query = _db.select(_db.items)
      ..where((t) => t.isActive.equals(true))
      ..orderBy([(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)]);
    final entities = await query.get();

    final items = <StockReportItem>[];
    double totalRawVal = 0.0;
    double totalFinishedVal = 0.0;

    for (final e in entities) {
      final val = (e.currentQty * e.purchaseRate * 100).roundToDouble() / 100.0;
      if (e.type == 'raw_material') {
        totalRawVal += val;
      } else {
        totalFinishedVal += val;
      }

      items.add(
        StockReportItem(
          id: e.id,
          name: e.name,
          type: e.type,
          currentQty: e.currentQty,
          unit: e.unit,
          purchaseRate: e.purchaseRate,
          stockValue: val,
        ),
      );
    }

    totalRawVal = (totalRawVal * 100).roundToDouble() / 100.0;
    totalFinishedVal = (totalFinishedVal * 100).roundToDouble() / 100.0;
    final grandVal = ((totalRawVal + totalFinishedVal) * 100).roundToDouble() / 100.0;

    return StockReportData(
      items: items,
      totalItems: items.length,
      totalRawMaterialValue: totalRawVal,
      totalFinishedProductValue: totalFinishedVal,
      grandTotalValue: grandVal,
    );
  }

  /// Get Low Stock Report breakdown for active items at or below minStockLevel
  Future<LowStockReportData> getLowStockReport() async {
    final query = _db.select(_db.items)
      ..where((t) => t.isActive.equals(true) & t.minStockLevel.isBiggerThanValue(0.0))
      ..orderBy([(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)]);
    final entities = await query.get();

    final outOfStock = <LowStockReportItem>[];
    final lowStock = <LowStockReportItem>[];

    for (final e in entities) {
      if (e.currentQty <= e.minStockLevel) {
        final item = LowStockReportItem(
          id: e.id,
          name: e.name,
          unit: e.unit,
          currentQty: e.currentQty,
          minStockLevel: e.minStockLevel,
          type: e.type,
        );

        if (e.currentQty <= 0) {
          outOfStock.add(item);
        } else {
          lowStock.add(item);
        }
      }
    }

    return LowStockReportData(
      outOfStock: outOfStock,
      lowStock: lowStock,
      totalLowCount: outOfStock.length + lowStock.length,
    );
  }
}

class StockOverviewSummary {
  final int rawMaterialCount;
  final int finishedProductCount;
  final double totalStockValue;
  final int lowStockCount;

  const StockOverviewSummary({
    required this.rawMaterialCount,
    required this.finishedProductCount,
    required this.totalStockValue,
    required this.lowStockCount,
  });
}

class StockReportItem {
  final int id;
  final String name;
  final String type;
  final double currentQty;
  final String unit;
  final double purchaseRate;
  final double stockValue;

  const StockReportItem({
    required this.id,
    required this.name,
    required this.type,
    required this.currentQty,
    required this.unit,
    required this.purchaseRate,
    required this.stockValue,
  });
}

class StockReportData {
  final List<StockReportItem> items;
  final int totalItems;
  final double totalRawMaterialValue;
  final double totalFinishedProductValue;
  final double grandTotalValue;

  const StockReportData({
    required this.items,
    required this.totalItems,
    required this.totalRawMaterialValue,
    required this.totalFinishedProductValue,
    required this.grandTotalValue,
  });
}

class LowStockReportItem {
  final int id;
  final String name;
  final String unit;
  final double currentQty;
  final double minStockLevel;
  final String type;

  const LowStockReportItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.currentQty,
    required this.minStockLevel,
    required this.type,
  });
}

class LowStockReportData {
  final List<LowStockReportItem> outOfStock;
  final List<LowStockReportItem> lowStock;
  final int totalLowCount;

  const LowStockReportData({
    required this.outOfStock,
    required this.lowStock,
    required this.totalLowCount,
  });
}
