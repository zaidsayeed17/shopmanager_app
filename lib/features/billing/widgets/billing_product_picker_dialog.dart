import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/billable_product_model.dart';
import '../../../data/repositories/providers.dart';

enum ProductSourceFilter { all, own, stock }

class BillingProductPickerDialog extends ConsumerStatefulWidget {
  final bool isWholesaleCustomer;
  final ValueChanged<BillableProduct> onProductSelected;

  const BillingProductPickerDialog({
    super.key,
    required this.isWholesaleCustomer,
    required this.onProductSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required bool isWholesaleCustomer,
    required ValueChanged<BillableProduct> onProductSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BillingProductPickerDialog(
        isWholesaleCustomer: isWholesaleCustomer,
        onProductSelected: onProductSelected,
      ),
    );
  }

  @override
  ConsumerState<BillingProductPickerDialog> createState() => _BillingProductPickerDialogState();
}

class _BillingProductPickerDialogState extends ConsumerState<BillingProductPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  ProductSourceFilter _filter = ProductSourceFilter.all;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(billableProductsStreamProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Drag handle and Title bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderMedium,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Product to Bill',
                      style: AppTypography.headlineMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search products by name, category, or SKU...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
              ),
            ),
          ),

          // Filter chips: All | Our Products | Stock Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All Products', ProductSourceFilter.all),
                const SizedBox(width: 8),
                _buildFilterChip('Our Products ∞', ProductSourceFilter.own),
                const SizedBox(width: 8),
                _buildFilterChip('Stock Items', ProductSourceFilter.stock),
              ],
            ),
          ),

          const Divider(height: 1),

          // Product list
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (allProducts) {
                var filtered = allProducts.where((p) {
                  // Source filter
                  if (_filter == ProductSourceFilter.own && !p.isOwn) return false;
                  if (_filter == ProductSourceFilter.stock && !p.isStock) return false;

                  // Text search
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    final matchName = p.name.toLowerCase().contains(q);
                    final matchCat = p.category?.toLowerCase().contains(q) ?? false;
                    final matchSku = p.sku?.toLowerCase().contains(q) ?? false;
                    return matchName || matchCat || matchSku;
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return _buildEmptyList(context);
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (ctx, idx) => const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (ctx, idx) {
                    final product = filtered[idx];
                    return _buildProductTile(context, product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ProductSourceFilter filter) {
    final isSelected = _filter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filter = filter;
          });
        }
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }

  Widget _buildProductTile(BuildContext context, BillableProduct product) {
    final appliedPrice = product.priceForCustomer(widget.isWholesaleCustomer);
    final hasWholesaleDiscount = widget.isWholesaleCustomer &&
        product.wholesalePrice != null &&
        product.wholesalePrice! > 0 &&
        product.wholesalePrice! < product.retailPrice;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: product.isOwn
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          product.isOwn ? Icons.all_inclusive : Icons.inventory_2_outlined,
          color: product.isOwn ? AppColors.primary : AppColors.secondary,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              product.name,
              style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Source Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: product.isOwn
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.textSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              product.source.badgeLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: product.isOwn ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          if (product.isStock) ...[
            Text(
              'Available: ${product.currentQty.toStringAsFixed(product.currentQty.truncateToDouble() == product.currentQty ? 0 : 2)} ${product.unit}',
              style: TextStyle(
                fontSize: 12,
                color: product.currentQty <= 0 ? AppColors.critical : AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '₹${appliedPrice.toStringAsFixed(2)}',
            style: AppTypography.bodyMd.copyWith(
              fontWeight: FontWeight.bold,
              color: widget.isWholesaleCustomer ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          if (hasWholesaleDiscount)
            Text(
              'MRP ₹${product.retailPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
                decoration: TextDecoration.lineThrough,
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.of(context).pop();
        widget.onProductSelected(product);
      },
    );
  }

  Widget _buildEmptyList(BuildContext context) {
    if (_filter == ProductSourceFilter.own) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.all_inclusive, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              const Text('No selling products found', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text(
                'Add self-manufactured or unlimited products to sell without inventory limits.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/products/add');
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('+ Add Selling Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filter == ProductSourceFilter.stock) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              const Text('No stock items found', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text(
                'Add inventory stock items to track quantities and deductions.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/stock/add');
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('+ Add Stock Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const Center(
      child: Text('No products match your criteria'),
    );
  }
}
