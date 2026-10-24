import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/item_model.dart';
import '../../../data/repositories/providers.dart';

class ReadyStockScreen extends ConsumerStatefulWidget {
  const ReadyStockScreen({super.key});

  @override
  ConsumerState<ReadyStockScreen> createState() => _ReadyStockScreenState();
}

class _ReadyStockScreenState extends ConsumerState<ReadyStockScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ItemModel> _filterItems(List<ItemModel> items) {
    if (_searchQuery.isEmpty) return items;
    final q = _searchQuery.toLowerCase();
    return items.where((item) => item.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final readyStockAsync = ref.watch(readyStockStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ready Stock'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/stock');
            }
          },
        ),
      ),
      body: readyStockAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error loading ready stock: $err',
              style: const TextStyle(color: AppColors.critical),
            ),
          ),
        ),
        data: (allItems) {
          final items = _filterItems(allItems);

          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= AppConstants.tabletBreakpoint;
              final padding = isTablet ? 24.0 : 16.0;

              if (allItems.isEmpty) {
                return _buildEmptyState(context);
              }

              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(padding, padding, padding, 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar & Add Button
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
                                  hintText: 'Search ready stock colour',
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
                                onPressed: () => context.go('/ready-stock/add'),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('+ Add Colour'),
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
                        const SizedBox(height: 16),

                        // Header Info Banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.activePillBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.activePillBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.palette_outlined, color: AppColors.primary, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'READY STOCK COLOUR LEDGER',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${allItems.length} colours tracked • Record Stock In (transfer) and Stock Out (dispatch).',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // List of items
                        if (items.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                'No matching colour found',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final isOutOfStock = item.currentQty <= 0;

                              return Card(
                                margin: EdgeInsets.zero,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(color: AppColors.borderLight),
                                ),
                                child: InkWell(
                                  onTap: () => context.go('/ready-stock/${item.id}'),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: isOutOfStock
                                              ? AppColors.criticalBg
                                              : AppColors.activePillBg,
                                          child: Icon(
                                            Icons.color_lens_outlined,
                                            size: 20,
                                            color: isOutOfStock
                                                ? AppColors.critical
                                                : AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Ready Stock Colour',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${item.currentQty % 1 == 0 ? item.currentQty.toInt() : item.currentQty.toStringAsFixed(1)} ${item.unit}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isOutOfStock
                                                    ? AppColors.critical
                                                    : AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isOutOfStock
                                                    ? AppColors.criticalBg
                                                    : AppColors.successBg,
                                                borderRadius: BorderRadius.circular(9999),
                                              ),
                                              child: Text(
                                                isOutOfStock ? 'Out of Stock' : 'In Stock',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: isOutOfStock
                                                      ? AppColors.critical
                                                      : AppColors.success,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.chevron_right,
                                          color: AppColors.textMuted,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  // Mobile FAB
                  if (!isTablet)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton.extended(
                        onPressed: () => context.go('/ready-stock/add'),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Colour'),
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.palette_outlined,
                size: 48,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Ready Stock Colours',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first ready stock colour to start tracking ready stock inventory and transfers.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/ready-stock/add'),
              icon: const Icon(Icons.add),
              label: const Text('Add Colour'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
}
