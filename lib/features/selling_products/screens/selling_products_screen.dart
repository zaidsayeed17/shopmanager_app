import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/selling_product_model.dart';
import '../../../data/repositories/providers.dart';

class SellingProductsScreen extends ConsumerStatefulWidget {
  const SellingProductsScreen({super.key});

  @override
  ConsumerState<SellingProductsScreen> createState() => _SellingProductsScreenState();
}

class _SellingProductsScreenState extends ConsumerState<SellingProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(SellingProductModel product) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${product.name}?'),
        content: const Text(
          'Are you sure you want to delete this product? Past bills with this product will keep their historical record.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.critical,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(sellingProductRepositoryProvider).deleteProduct(product.id);
        ref.invalidate(sellingProductsStreamProvider);
        ref.invalidate(activeSellingProductsStreamProvider);
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('${product.name} deleted successfully.'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Failed to delete product: $e'),
              backgroundColor: AppColors.critical,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(sellingProductsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Selling Products',
          style: AppTypography.headlineMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => context.go('/products/add'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('+ Add Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error loading products: $err', style: const TextStyle(color: AppColors.critical)),
          ),
        ),
        data: (allProducts) {
          final query = _searchQuery.trim().toLowerCase();
          final filtered = allProducts.where((p) {
            if (query.isEmpty) return true;
            return p.name.toLowerCase().contains(query) ||
                (p.description?.toLowerCase().contains(query) ?? false);
          }).toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= AppConstants.tabletBreakpoint;
              final padding = isTablet ? 24.0 : 16.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info banner
                  Container(
                    margin: EdgeInsets.fromLTRB(padding, padding, padding, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.all_inclusive, color: AppColors.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Products you make yourself — unlimited, no stock tracking.',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search bar
                  Padding(
                    padding: EdgeInsets.all(padding),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search products by name or description...',
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
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                      ),
                    ),
                  ),

                  // Content table or empty state
                  Expanded(
                    child: filtered.isEmpty
                        ? _buildEmptyState(context, isSearch: _searchQuery.isNotEmpty)
                        : _buildProductsTable(context, filtered, padding),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {required bool isSearch}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearch ? Icons.search_off : Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              isSearch ? 'No products match your search' : 'No selling products added yet',
              style: AppTypography.headlineMd.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              isSearch
                  ? 'Try adjusting your search terms'
                  : 'Add custom or manufactured products to sell without inventory limits.',
              style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (!isSearch) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.go('/products/add'),
                icon: const Icon(Icons.add),
                label: const Text('+ Add Your First Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductsTable(BuildContext context, List<SellingProductModel> products, double padding) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.background),
            columnSpacing: 24,
            columns: const [
              DataColumn(label: Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Retail Price', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Wholesale Price', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: products.map((p) {
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.all_inclusive, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          p.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    onTap: () => context.go('/products/edit/${p.id}'),
                  ),
                  DataCell(
                    Text('₹${p.price.toStringAsFixed(2)}'),
                    onTap: () => context.go('/products/edit/${p.id}'),
                  ),
                  DataCell(
                    Text(
                      p.wholesalePrice != null ? '₹${p.wholesalePrice!.toStringAsFixed(2)}' : '—',
                      style: TextStyle(
                        color: p.wholesalePrice != null ? AppColors.textPrimary : AppColors.textMuted,
                      ),
                    ),
                    onTap: () => context.go('/products/edit/${p.id}'),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: p.isActive
                            ? AppColors.success.withValues(alpha: 0.12)
                            : AppColors.textMuted.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        p.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: p.isActive ? AppColors.success : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                          tooltip: 'Edit',
                          onPressed: () => context.go('/products/edit/${p.id}'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.critical),
                          tooltip: 'Delete',
                          onPressed: () => _confirmDelete(p),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
