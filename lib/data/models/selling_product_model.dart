import '../db/app_database.dart';

class SellingProductModel {
  final int id;
  final String name;
  final String? description;
  final double price; // Retail / regular selling price
  final double? wholesalePrice; // Optional wholesale price
  final String? photoPath;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SellingProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.wholesalePrice,
    this.photoPath,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  String get formattedPrice => '₹${price.toStringAsFixed(2)}';
  String? get formattedWholesalePrice =>
      wholesalePrice != null ? '₹${wholesalePrice!.toStringAsFixed(2)}' : null;

  factory SellingProductModel.fromEntity(SellingProductEntity entity) {
    return SellingProductModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      wholesalePrice: entity.wholesalePrice,
      photoPath: entity.photoPath,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  SellingProductModel copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    double? wholesalePrice,
    String? photoPath,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SellingProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      photoPath: photoPath ?? this.photoPath,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
