import '../../core/utils/pricing_utils.dart';
import 'item_model.dart';
import 'selling_product_model.dart';

enum BillProductSource {
  own,
  stock;

  String get badgeLabel {
    switch (this) {
      case BillProductSource.own:
        return 'Our Product ∞';
      case BillProductSource.stock:
        return 'Stock';
    }
  }

  String get shortBadgeLabel {
    switch (this) {
      case BillProductSource.own:
        return 'Our ∞';
      case BillProductSource.stock:
        return 'Stock';
    }
  }
}

class BillableProduct {
  final BillProductSource source;
  final int id; // itemId for stock, sellingProductId for own
  final String name;
  final String unit;
  final double retailPrice;
  final double? wholesalePrice;
  final double currentQty; // double.infinity for own products
  final String? category;
  final String? sku;
  final String? photoPath;
  final bool isActive;

  const BillableProduct({
    required this.source,
    required this.id,
    required this.name,
    required this.unit,
    required this.retailPrice,
    this.wholesalePrice,
    required this.currentQty,
    this.category,
    this.sku,
    this.photoPath,
    this.isActive = true,
  });

  bool get isOwn => source == BillProductSource.own;
  bool get isStock => source == BillProductSource.stock;

  /// Resolve unit price based on customer's wholesale status
  double priceForCustomer(bool isWholesaleCustomer) {
    return resolveUnitPrice(
      retail: retailPrice,
      wholesale: wholesalePrice,
      isWholesaleCustomer: isWholesaleCustomer,
    );
  }

  factory BillableProduct.fromStockItem(ItemModel item) {
    return BillableProduct(
      source: BillProductSource.stock,
      id: item.id,
      name: item.name,
      unit: item.unit,
      retailPrice: item.sellingRate,
      wholesalePrice: item.wholesaleRate,
      currentQty: item.currentQty,
      category: item.category,
      sku: item.sku,
      photoPath: null,
      isActive: item.isActive,
    );
  }

  factory BillableProduct.fromItem(ItemModel item) => BillableProduct.fromStockItem(item);

  factory BillableProduct.fromSellingProduct(SellingProductModel product) {
    return BillableProduct(
      source: BillProductSource.own,
      id: product.id,
      name: product.name,
      unit: 'pcs',
      retailPrice: product.price,
      wholesalePrice: product.wholesalePrice,
      currentQty: double.infinity,
      category: null,
      sku: null,
      photoPath: product.photoPath,
      isActive: product.isActive,
    );
  }
}
