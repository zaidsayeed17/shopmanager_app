import '../db/app_database.dart';

enum ItemStatus {
  inStock,
  lowStock,
  outOfStock,
  inactive;

  String get label {
    switch (this) {
      case ItemStatus.inStock:
        return 'In Stock';
      case ItemStatus.lowStock:
        return 'Low Stock';
      case ItemStatus.outOfStock:
        return 'Out of Stock';
      case ItemStatus.inactive:
        return 'Inactive';
    }
  }
}

class ItemModel {
  final int id;
  final String name;
  final String? category;
  final String? sku;
  final String type; // 'raw_material' or 'finished_product'
  final String unit;
  final double purchaseRate;
  final double sellingRate;
  final double? wholesaleRate;
  final double openingQty;
  final double currentQty;
  final double minStockLevel;
  final String? supplierInfo;
  final bool isActive;
  final DateTime? createdAt;

  const ItemModel({
    required this.id,
    required this.name,
    this.category,
    this.sku,
    required this.type,
    required this.unit,
    this.purchaseRate = 0.0,
    this.sellingRate = 0.0,
    this.wholesaleRate,
    this.openingQty = 0.0,
    this.currentQty = 0.0,
    this.minStockLevel = 0.0,
    this.supplierInfo,
    this.isActive = true,
    this.createdAt,
  });

  bool get isRawMaterial => type == 'raw_material';
  bool get isFinishedProduct => type == 'finished_product';

  ItemStatus get status {
    if (!isActive) {
      return ItemStatus.inactive;
    }
    if (currentQty <= 0) {
      return ItemStatus.outOfStock;
    }
    if (minStockLevel > 0 && currentQty <= minStockLevel) {
      return ItemStatus.lowStock;
    }
    return ItemStatus.inStock;
  }

  factory ItemModel.fromEntity(ItemEntity entity) {
    return ItemModel(
      id: entity.id,
      name: entity.name,
      category: entity.category,
      sku: entity.sku,
      type: entity.type,
      unit: entity.unit,
      purchaseRate: entity.purchaseRate,
      sellingRate: entity.sellingRate,
      wholesaleRate: entity.wholesaleRate,
      openingQty: entity.openingQty,
      currentQty: entity.currentQty,
      minStockLevel: entity.minStockLevel,
      supplierInfo: entity.supplierInfo,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }

  ItemModel copyWith({
    int? id,
    String? name,
    String? category,
    String? sku,
    String? type,
    String? unit,
    double? purchaseRate,
    double? sellingRate,
    double? wholesaleRate,
    double? openingQty,
    double? currentQty,
    double? minStockLevel,
    String? supplierInfo,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      sku: sku ?? this.sku,
      type: type ?? this.type,
      unit: unit ?? this.unit,
      purchaseRate: purchaseRate ?? this.purchaseRate,
      sellingRate: sellingRate ?? this.sellingRate,
      wholesaleRate: wholesaleRate ?? this.wholesaleRate,
      openingQty: openingQty ?? this.openingQty,
      currentQty: currentQty ?? this.currentQty,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      supplierInfo: supplierInfo ?? this.supplierInfo,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
