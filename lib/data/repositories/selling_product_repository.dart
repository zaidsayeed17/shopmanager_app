import 'package:drift/drift.dart';
import '../db/app_database.dart';
import '../models/selling_product_model.dart';

class SellingProductRepository {
  final AppDatabase _db;

  SellingProductRepository(this._db);

  /// Fetch all selling products ordered by name ASC
  Future<List<SellingProductModel>> getAllProducts() async {
    final query = _db.select(_db.sellingProducts)
      ..orderBy([(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)]);
    final entities = await query.get();
    return entities.map(SellingProductModel.fromEntity).toList();
  }

  /// Watch all selling products in real-time
  Stream<List<SellingProductModel>> watchAllProducts() {
    final query = _db.select(_db.sellingProducts)
      ..orderBy([(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)]);
    return query.watch().map((entities) => entities.map(SellingProductModel.fromEntity).toList());
  }

  /// Fetch active selling products
  Future<List<SellingProductModel>> getActiveProducts() async {
    final query = _db.select(_db.sellingProducts)
      ..where((t) => t.isActive.equals(true))
      ..orderBy([(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)]);
    final entities = await query.get();
    return entities.map(SellingProductModel.fromEntity).toList();
  }

  /// Watch active selling products in real-time
  Stream<List<SellingProductModel>> watchActiveProducts() {
    final query = _db.select(_db.sellingProducts)
      ..where((t) => t.isActive.equals(true))
      ..orderBy([(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)]);
    return query.watch().map((entities) => entities.map(SellingProductModel.fromEntity).toList());
  }

  /// Get product by ID
  Future<SellingProductModel?> getProductById(int id) async {
    final query = _db.select(_db.sellingProducts)..where((t) => t.id.equals(id));
    final entity = await query.getSingleOrNull();
    return entity != null ? SellingProductModel.fromEntity(entity) : null;
  }

  /// Search active selling products by name or description
  Future<List<SellingProductModel>> searchProducts(String queryText) async {
    if (queryText.trim().isEmpty) {
      return getActiveProducts();
    }
    final pattern = '%${queryText.trim().toLowerCase()}%';
    final query = _db.select(_db.sellingProducts)
      ..where((t) => t.isActive.equals(true) & (t.name.lower().like(pattern) | t.description.lower().like(pattern)))
      ..orderBy([(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)]);
    final entities = await query.get();
    return entities.map(SellingProductModel.fromEntity).toList();
  }

  /// Add new selling product
  Future<int> addProduct({
    required String name,
    required double price,
    double? wholesalePrice,
    String? description,
    String? photoPath,
    bool isActive = true,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Product name is required.');
    }
    if (price <= 0) {
      throw ArgumentError('Retail price must be greater than zero.');
    }
    if (wholesalePrice != null && wholesalePrice <= 0) {
      throw ArgumentError('Wholesale price must be greater than zero if provided.');
    }

    final companion = SellingProductsCompanion.insert(
      name: trimmedName,
      price: Value(price),
      wholesalePrice: Value(wholesalePrice),
      description: Value(description?.trim().isEmpty == true ? null : description?.trim()),
      photoPath: Value(photoPath),
      isActive: Value(isActive),
      createdAt: Value(DateTime.now()),
    );

    return await _db.into(_db.sellingProducts).insert(companion);
  }

  /// Update existing selling product
  Future<void> updateProduct({
    required int id,
    required String name,
    required double price,
    double? wholesalePrice,
    String? description,
    String? photoPath,
    required bool isActive,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Product name is required.');
    }
    if (price <= 0) {
      throw ArgumentError('Retail price must be greater than zero.');
    }
    if (wholesalePrice != null && wholesalePrice <= 0) {
      throw ArgumentError('Wholesale price must be greater than zero if provided.');
    }

    final statement = _db.update(_db.sellingProducts)..where((t) => t.id.equals(id));
    await statement.write(
      SellingProductsCompanion(
        name: Value(trimmedName),
        price: Value(price),
        wholesalePrice: Value(wholesalePrice),
        description: Value(description?.trim().isEmpty == true ? null : description?.trim()),
        photoPath: Value(photoPath),
        isActive: Value(isActive),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Delete product by ID
  Future<void> deleteProduct(int id) async {
    await (_db.delete(_db.sellingProducts)..where((t) => t.id.equals(id))).go();
  }
}
