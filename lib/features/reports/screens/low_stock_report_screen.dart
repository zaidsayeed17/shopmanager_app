import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/item_repository.dart';
import '../../../data/repositories/providers.dart';

class LowStockReportScreen extends ConsumerWidget {
  const LowStockReportScreen({super.key});

  String _formatQty(double qty) {
    return qty % 1 == 0 ? qty.toInt().toString() : qty.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(lowStockReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Low Stock Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/reports');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, size: 20),
            tooltip: 'Export Report',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export coming in a later phase'),
                  backgroundColor: AppColors.textPrimary,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= AppConstants.tabletBreakpoint;
          final padding = isTablet ? 24.0 : 16.0;

          return reportAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error loading report: $err')),
            data: (data) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Header
                    LayoutBuilder(
                      builder: (context, box) {
                        final width = box.maxWidth;
                        final crossCount = isTablet ? 3 : (width > 450 ? 3 : 1);
                        final tileWidth = (width - (crossCount - 1) * 12) / crossCount;

                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildSummaryTile('Total Items Needing Action', '${data.totalLowCount}', AppColors.primary, tileWidth),
                            _buildSummaryTile('Out of Stock', '${data.outOfStock.length}', AppColors.critical, tileWidth),
                            _buildSummaryTile('Low Stock Warning', '${data.lowStock.length}', AppColors.warning, tileWidth),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    if (data.totalLowCount == 0)
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Column(
                              children: const [
                                Icon(Icons.check_circle_outline, size: 48, color: AppColors.success),
                                SizedBox(height: 12),
                                Text(
                                  'All Stock Levels Healthy',
                                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 16),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'No items are currently out of stock or below their minimum reorder levels.',
                                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else ...[
                      // Out of stock section
                      if (data.outOfStock.isNotEmpty) ...[
                        Row(
                          children: const [
                            Icon(Icons.error_outline, color: AppColors.critical, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Out of Stock Items',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.critical),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Card(
                          margin: EdgeInsets.zero,
                          clipBehavior: Clip.antiAlias,
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: data.outOfStock.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = data.outOfStock[index];
                              return _buildItemRow(context, item, isOutOfStock: true);
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Low stock section
                      if (data.lowStock.isNotEmpty) ...[
                        Row(
                          children: const [
                            Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Low Stock Warnings',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.warning),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Card(
                          margin: EdgeInsets.zero,
                          clipBehavior: Clip.antiAlias,
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: data.lowStock.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = data.lowStock[index];
                              return _buildItemRow(context, item, isOutOfStock: false);
                            },
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, LowStockReportItem item, {required bool isOutOfStock}) {
    final statusColor = isOutOfStock ? AppColors.critical : AppColors.warning;

    return ListTile(
      dense: true,
      title: Row(
        children: [
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              item.type == 'raw_material' ? 'Raw Material' : 'Finished Product',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: statusColor),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          'Current: ${_formatQty(item.currentQty)} ${item.unit}  •  Min Level: ${_formatQty(item.minStockLevel)} ${item.unit}',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ),
      trailing: ElevatedButton.icon(
        onPressed: () {
          context.push('/stock/${item.id}/purchase');
        },
        icon: const Icon(Icons.add_shopping_cart, size: 14),
        label: const Text('Restock'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  Widget _buildSummaryTile(String label, String value, Color color, double width) {
    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
