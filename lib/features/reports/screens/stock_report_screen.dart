import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/providers.dart';

class StockReportScreen extends ConsumerStatefulWidget {
  const StockReportScreen({super.key});

  @override
  ConsumerState<StockReportScreen> createState() => _StockReportScreenState();
}

class _StockReportScreenState extends ConsumerState<StockReportScreen> {
  String _selectedFilter = 'all'; // 'all', 'raw_material', 'finished_product'
  String _sortBy = 'value'; // 'value', 'name'

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  String _formatQty(double qty) {
    return qty % 1 == 0 ? qty.toInt().toString() : qty.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(stockReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Report'),
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
              var filteredItems = data.items;
              if (_selectedFilter != 'all') {
                filteredItems = filteredItems.where((i) => i.type == _selectedFilter).toList();
              }

              if (_sortBy == 'value') {
                filteredItems.sort((a, b) => b.stockValue.compareTo(a.stockValue));
              } else {
                filteredItems.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
              }

              return SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Header Grid
                    LayoutBuilder(
                      builder: (context, box) {
                        final width = box.maxWidth;
                        final crossCount = isTablet ? 4 : (width > 500 ? 2 : 1);

                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildSummaryTile('Total Items', '${data.totalItems}', AppColors.primary, (width - (crossCount - 1) * 12) / crossCount),
                            _buildSummaryTile('Grand Stock Value', _formatCurrency(data.grandTotalValue), AppColors.secondary, (width - (crossCount - 1) * 12) / crossCount),
                            _buildSummaryTile('Raw Material Value', _formatCurrency(data.totalRawMaterialValue), AppColors.info, (width - (crossCount - 1) * 12) / crossCount),
                            _buildSummaryTile('Finished Goods Value', _formatCurrency(data.totalFinishedProductValue), AppColors.tertiary, (width - (crossCount - 1) * 12) / crossCount),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Filter & Sort Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('All'),
                              selected: _selectedFilter == 'all',
                              onSelected: (val) {
                                if (val) setState(() => _selectedFilter = 'all');
                              },
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: _selectedFilter == 'all' ? Colors.white : AppColors.textPrimary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('Raw Materials'),
                              selected: _selectedFilter == 'raw_material',
                              onSelected: (val) {
                                if (val) setState(() => _selectedFilter = 'raw_material');
                              },
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: _selectedFilter == 'raw_material' ? Colors.white : AppColors.textPrimary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('Finished Goods'),
                              selected: _selectedFilter == 'finished_product',
                              onSelected: (val) {
                                if (val) setState(() => _selectedFilter = 'finished_product');
                              },
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: _selectedFilter == 'finished_product' ? Colors.white : AppColors.textPrimary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        DropdownButton<String>(
                          value: _sortBy,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'value', child: Text('Sort by Value', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'name', child: Text('Sort by Name', style: TextStyle(fontSize: 12))),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _sortBy = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (filteredItems.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final typeLabel = item.type == 'raw_material' ? 'Raw Material' : 'Finished Product';
                          final typeColor = item.type == 'raw_material' ? AppColors.info : AppColors.secondary;

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: AppTypography.bodyMd.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: typeColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              typeLabel,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: typeColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${_formatQty(item.currentQty)} ${item.unit} @ ${_formatCurrency(item.purchaseRate)}',
                                            style: AppTypography.bodySm.copyWith(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatCurrency(item.stockValue),
                                      style: AppTypography.bodyLg.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const Text(
                                      'Stock Value',
                                      style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSummaryTile(String label, String value, Color color, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.labelSm.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.headlineLgMobile.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            'No inventory items match the selected filter.',
            style: AppTypography.bodyLg.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
