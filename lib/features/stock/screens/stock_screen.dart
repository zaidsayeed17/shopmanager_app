import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/item_model.dart';
import '../../../data/repositories/providers.dart';

enum ItemCategoryFilter { all, rawMaterial, finishedProduct }
enum ItemSortOption { name, quantity }

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  final TextEditingController _searchController = TextEditingController();

  ItemCategoryFilter _selectedTab = ItemCategoryFilter.all;
  bool _lowStockOnly = false;
  ItemSortOption _sortBy = ItemSortOption.name;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ItemModel> _getFilteredAndSortedItems(List<ItemModel> allItems) {
    var filtered = allItems.where((item) {
      // 1. Search filter (name or category)
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = item.name.toLowerCase().contains(query);
        final matchesCategory = item.category?.toLowerCase().contains(query) ?? false;
        if (!matchesName && !matchesCategory) {
          return false;
        }
      }

      // 2. Tab Category Filter
      switch (_selectedTab) {
        case ItemCategoryFilter.all:
          break;
        case ItemCategoryFilter.rawMaterial:
          if (!item.isRawMaterial) return false;
          break;
        case ItemCategoryFilter.finishedProduct:
          if (!item.isFinishedProduct) return false;
          break;
      }

      // 3. Low Stock Only Filter (active items only)
      if (_lowStockOnly) {
        if (!item.isActive) return false;
        if (item.status != ItemStatus.lowStock && item.status != ItemStatus.outOfStock) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sorting
    filtered.sort((a, b) {
      if (_sortBy == ItemSortOption.name) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      } else {
        return b.currentQty.compareTo(a.currentQty); // Descending by quantity
      }
    });

    return filtered;
  }

  double _calculateTotalValue(List<ItemModel> items) {
    return items
        .where((i) => i.isActive)
        .fold(0.0, (sum, i) => sum + (i.currentQty * i.purchaseRate));
  }

  int _getAlertCount(List<ItemModel> items) {
    return items
        .where((i) => i.isActive && (i.status == ItemStatus.lowStock || i.status == ItemStatus.outOfStock))
        .length;
  }

  int _getRawCount(List<ItemModel> items) => items.where((i) => i.isRawMaterial).length;
  int _getFinishedCount(List<ItemModel> items) => items.where((i) => i.isFinishedProduct).length;

  Color _getStatusBg(ItemStatus status) {
    switch (status) {
      case ItemStatus.inStock:
        return AppColors.successBg;
      case ItemStatus.lowStock:
        return AppColors.warningBg;
      case ItemStatus.outOfStock:
        return AppColors.criticalBg;
      case ItemStatus.inactive:
        return AppColors.background;
    }
  }

  Color _getStatusText(ItemStatus status) {
    switch (status) {
      case ItemStatus.inStock:
        return AppColors.success;
      case ItemStatus.lowStock:
        return AppColors.tertiary;
      case ItemStatus.outOfStock:
        return AppColors.critical;
      case ItemStatus.inactive:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsStreamProvider);

    return Scaffold(
      body: itemsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error loading items: $err',
              style: const TextStyle(color: AppColors.critical),
            ),
          ),
        ),
        data: (allItems) {
          final isListEmpty = allItems.isEmpty;
          final filteredItems = _getFilteredAndSortedItems(allItems);

          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= AppConstants.tabletBreakpoint;
              final padding = isTablet ? 24.0 : 16.0;

              if (isListEmpty) {
                return _buildEmptyState(context);
              }

              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(padding, padding, padding, 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Search & Actions Row
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val.trim();
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search materials or products',
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
                                  contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppColors.borderLight),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                  ),
                                ),
                              ),
                            ),
                            if (isTablet) ...[
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: () => context.go('/stock/add'),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('+ Add Item'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Ready Stock Navigation Banner
                        Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: AppColors.activePillBorder),
                          ),
                          color: AppColors.activePillBg,
                          child: InkWell(
                            onTap: () => context.go('/ready-stock'),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.palette_outlined, color: AppColors.primary, size: 22),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Ready Stock Module',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          'View and manage colour-wise ready stock inventory',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: const [
                                      Text(
                                        'Ready Stock',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.arrow_forward, size: 18, color: AppColors.primary),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Summary Header / Cards
                        if (isTablet)
                          _buildTabletSummaryCards(allItems)
                        else
                          _buildMobileSummaryBanner(allItems),
                        const SizedBox(height: 16),

                        // Tab Category Selector
                        _buildSegmentedTabControl(allItems),
                        const SizedBox(height: 12),

                        // Filters & Sort Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FilterChip(
                              selected: _lowStockOnly,
                              label: Text('Low Stock Alerts (${_getAlertCount(allItems)})'),
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: _lowStockOnly ? FontWeight.bold : FontWeight.w500,
                                color: _lowStockOnly ? AppColors.critical : AppColors.textSecondary,
                              ),
                              selectedColor: AppColors.criticalBg,
                              backgroundColor: AppColors.surface,
                              side: BorderSide(
                                color: _lowStockOnly ? AppColors.critical : AppColors.borderLight,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              onSelected: (val) {
                                setState(() {
                                  _lowStockOnly = val;
                                });
                              },
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Sort:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                DropdownButton<ItemSortOption>(
                                  value: _sortBy,
                                  underline: const SizedBox.shrink(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: ItemSortOption.name,
                                      child: Text('Name (A-Z)'),
                                    ),
                                    DropdownMenuItem(
                                      value: ItemSortOption.quantity,
                                      child: Text('Quantity'),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _sortBy = val;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // List Content
                        if (filteredItems.isEmpty)
                          _buildNoResultsState()
                        else if (isTablet)
                          _buildTabletTable(filteredItems)
                        else
                          _buildMobileList(filteredItems),
                      ],
                    ),
                  ),

                  // Mobile FAB
                  if (!isTablet)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton.extended(
                        onPressed: () => context.go('/stock/add'),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Item'),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMobileSummaryBanner(List<ItemModel> allItems) {
    final totalValue = _calculateTotalValue(allItems);
    final alertCount = _getAlertCount(allItems);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.08),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TOTAL INVENTORY VALUE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Color(0xFF99EFE5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹ ${totalValue.toStringAsFixed(0)}',
            style: AppTypography.displayLg.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${allItems.length} total items • $alertCount low/out of stock alerts',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFE0F2FE),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletSummaryCards(List<ItemModel> allItems) {
    final totalValue = _calculateTotalValue(allItems);
    final alertCount = _getAlertCount(allItems);
    final rawCount = _getRawCount(allItems);
    final finishedCount = _getFinishedCount(allItems);

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'TOTAL ITEMS',
            value: '${allItems.length}',
            subtext: '$rawCount Raw • $finishedCount Finished',
            icon: Icons.inventory_2_outlined,
            iconColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            title: 'INVENTORY VALUE',
            value: '₹ ${totalValue.toStringAsFixed(0)}',
            subtext: 'Based on purchase rates',
            icon: Icons.payments_outlined,
            iconColor: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            title: 'LOW STOCK ALERTS',
            value: '$alertCount',
            subtext: alertCount > 0 ? 'Requires replenishment' : 'All stock levels healthy',
            icon: Icons.warning_amber_outlined,
            iconColor: alertCount > 0 ? AppColors.critical : AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.headlineLg.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  subtext,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabControl(List<ItemModel> allItems) {
    final rawCount = _getRawCount(allItems);
    final finishedCount = _getFinishedCount(allItems);

    final tabs = [
      'All (${allItems.length})',
      'Raw Materials ($rawCount)',
      'Finished Products ($finishedCount)',
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final filter = ItemCategoryFilter.values[index];
          final isSelected = _selectedTab == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = filter;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMobileList(List<ItemModel> items) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];

        return Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.borderLight),
          ),
          child: InkWell(
            onTap: () => context.go('/stock/${item.id}'),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildTypeTag(item.isRawMaterial),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.name,
                                style: AppTypography.labelLg.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  decoration: !item.isActive ? TextDecoration.lineThrough : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${item.category ?? 'Uncategorized'} • ${item.unit}',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            if (item.minStockLevel > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: Text(
                                  'Min: ${item.minStockLevel.toStringAsFixed(item.minStockLevel.truncateToDouble() == item.minStockLevel ? 0 : 1)}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item.currentQty.toStringAsFixed(item.currentQty.truncateToDouble() == item.currentQty ? 0 : 2)} ${item.unit}',
                        style: AppTypography.labelLg.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusBg(item.status),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          item.status.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getStatusText(item.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabletTable(List<ItemModel> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('CATEGORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('CURRENT STOCK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 1, child: Text('MIN STOCK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('UNIT RATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Center(child: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)))),
                SizedBox(width: 80, child: Center(child: Text('ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)))),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderLight),
            itemBuilder: (context, index) {
              final item = items[index];

              return InkWell(
                onTap: () => context.go('/stock/${item.id}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.name,
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: !item.isActive ? TextDecoration.lineThrough : null,
                            color: !item.isActive ? AppColors.textMuted : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildTypeTag(item.isRawMaterial),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.category ?? '—',
                          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${item.currentQty.toStringAsFixed(item.currentQty.truncateToDouble() == item.currentQty ? 0 : 2)} ${item.unit}',
                          style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          item.minStockLevel > 0
                              ? item.minStockLevel.toStringAsFixed(item.minStockLevel.truncateToDouble() == item.minStockLevel ? 0 : 1)
                              : '—',
                          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.purchaseRate > 0 ? '₹ ${item.purchaseRate.toStringAsFixed(0)}' : '—',
                          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStatusBg(item.status),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              item.status.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getStatusText(item.status),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.swap_vert, size: 18),
                              tooltip: 'Stock Movement',
                              onPressed: () => context.go('/stock/${item.id}'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              tooltip: 'Edit Item',
                              onPressed: () => context.go('/stock/edit/${item.id}'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTag(bool isRawMaterial) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isRawMaterial ? AppColors.activePillBg : AppColors.infoBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isRawMaterial ? AppColors.activePillBorder : AppColors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        isRawMaterial ? 'Raw Material' : 'Finished Product',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isRawMaterial ? AppColors.secondary : AppColors.info,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No items in your stock yet',
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add raw materials and finished products to track current stock levels and get low-stock warnings.',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/stock/add'),
              icon: const Icon(Icons.add),
              label: const Text('+ Add Your First Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 36, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(
            'No items match your filters',
            style: AppTypography.bodyLg.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
