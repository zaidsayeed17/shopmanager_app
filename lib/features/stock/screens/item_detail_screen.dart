import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/item_model.dart';
import '../../../data/repositories/providers.dart';
import '../../../data/repositories/stock_repository.dart';

enum TransactionHistoryFilter { all, stockIn, stockOut }

class ItemDetailScreen extends ConsumerStatefulWidget {
  final String itemId;

  const ItemDetailScreen({
    super.key,
    required this.itemId,
  });

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  TransactionHistoryFilter _historyFilter = TransactionHistoryFilter.all;

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

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final year = dt.year;
    return '$day $month $year';
  }

  String _formatQty(double qty) {
    return qty.toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 2);
  }

  List<StockTransactionWithBalance> _filterTransactions(
      List<StockTransactionWithBalance> list) {
    switch (_historyFilter) {
      case TransactionHistoryFilter.all:
        return list;
      case TransactionHistoryFilter.stockIn:
        return list.where((t) => t.isPositive).toList();
      case TransactionHistoryFilter.stockOut:
        return list.where((t) => t.isNegative).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final numericId = int.tryParse(widget.itemId) ?? 0;
    final itemsAsync = ref.watch(itemsStreamProvider);
    final txsAsync = ref.watch(stockTransactionsStreamProvider(numericId));

    return itemsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Item Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/stock'),
          ),
        ),
        body: Center(child: Text('Error loading item: $err')),
      ),
      data: (allItems) {
        final item = allItems.firstWhere(
          (i) => i.id == numericId,
          orElse: () => ItemModel(
            id: numericId,
            name: 'Item #$numericId',
            type: 'raw_material',
            unit: 'pcs',
          ),
        );

        final transactions = txsAsync.value ?? [];
        final filteredTxs = _filterTransactions(transactions);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              item.name,
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Item',
                onPressed: () => context.go('/stock/edit/${item.id}'),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= AppConstants.tabletBreakpoint;
              final padding = isTablet ? 24.0 : 16.0;

              return SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isTablet)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildItemSummaryCard(item),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: _buildActionButtonsCard(item),
                          ),
                        ],
                      )
                    else ...[
                      _buildItemSummaryCard(item),
                      const SizedBox(height: 12),
                      _buildActionButtonsCard(item),
                    ],
                    const SizedBox(height: 24),

                    // Stock History Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Stock History (${transactions.length})',
                          style: AppTypography.headlineMd.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            _buildFilterChip('All', TransactionHistoryFilter.all),
                            const SizedBox(width: 6),
                            _buildFilterChip('Stock In', TransactionHistoryFilter.stockIn),
                            const SizedBox(width: 6),
                            _buildFilterChip('Stock Out', TransactionHistoryFilter.stockOut),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Stock History List / Table / Empty
                    if (transactions.isEmpty)
                      _buildEmptyHistoryState(context, item.isActive, item.id)
                    else if (filteredTxs.isEmpty)
                      _buildNoFilteredResultsState()
                    else if (isTablet)
                      _buildTabletHistoryTable(filteredTxs, item)
                    else
                      _buildMobileHistoryList(filteredTxs, item),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildItemSummaryCard(ItemModel item) {
    final statusColor = _getStatusText(item.status);
    final isLowOrOut = item.status == ItemStatus.lowStock || item.status == ItemStatus.outOfStock;
    final belowMin = item.minStockLevel > 0 ? (item.minStockLevel - item.currentQty) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.04),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                            style: AppTypography.headlineLg.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              decoration: !item.isActive ? TextDecoration.lineThrough : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.category ?? 'Uncategorized'} • ${item.unit}',
                      style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusBg(item.status),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  item.status.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Large Stock Counter
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatQty(item.currentQty),
                style: AppTypography.displayLg.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                item.unit,
                style: AppTypography.bodyLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (isLowOrOut && item.minStockLevel > 0) ...[
            const SizedBox(height: 2),
            Text(
              belowMin > 0
                  ? '${_formatQty(belowMin)} ${item.unit} below minimum threshold (${_formatQty(item.minStockLevel)} ${item.unit})'
                  : 'Reached minimum threshold (${_formatQty(item.minStockLevel)} ${item.unit})',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.critical,
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 12),

          // 4 Facts Grid
          Row(
            children: [
              Expanded(
                child: _buildFactItem(
                  'Minimum Stock',
                  item.minStockLevel > 0 ? '${_formatQty(item.minStockLevel)} ${item.unit}' : '—',
                ),
              ),
              Expanded(
                child: _buildFactItem(
                  'Purchase Rate',
                  item.purchaseRate > 0 ? '₹ ${_formatQty(item.purchaseRate)}' : '—',
                ),
              ),
              Expanded(
                child: _buildFactItem(
                  'Selling Rate',
                  item.sellingRate > 0 ? '₹ ${_formatQty(item.sellingRate)}' : '—',
                ),
              ),
              Expanded(
                child: _buildFactItem(
                  'Stock Value',
                  '₹ ${_formatQty(item.currentQty * item.purchaseRate)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFactItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtonsCard(ItemModel item) {
    final canRecord = item.isActive;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: canRecord ? () => context.go('/stock/${item.id}/purchase') : null,
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: const Text('Add Stock'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: canRecord ? () => context.go('/stock/${item.id}/adjust') : null,
                  icon: const Icon(Icons.tune, size: 18),
                  label: const Text('Adjust Stock'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color: canRecord ? AppColors.primary : AppColors.borderLight,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (!canRecord) ...[
            const SizedBox(height: 8),
            const Text(
              'Reactivate this item to record stock movements.',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, TransactionHistoryFilter filter) {
    final isSelected = _historyFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _historyFilter = filter;
        });
      },
      selectedColor: AppColors.activePillBg,
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.borderLight,
      ),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }

  Widget _buildMobileHistoryList(
      List<StockTransactionWithBalance> transactions, ItemModel item) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final itemTx = transactions[index];
        final tx = itemTx.transaction;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: itemTx.iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  itemTx.typeIcon,
                  size: 18,
                  color: itemTx.iconColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          itemTx.formattedTypeLabel,
                          style: AppTypography.labelLg.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${itemTx.isPositive ? '+' : ''}${_formatQty(tx.quantity)} ${item.unit}',
                          style: AppTypography.labelLg.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: itemTx.isPositive
                                ? AppColors.success
                                : AppColors.critical,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(tx.date),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          'Balance: ${_formatQty(itemTx.runningBalance)} ${item.unit}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (tx.notes != null && tx.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        tx.notes!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabletHistoryTable(
      List<StockTransactionWithBalance> transactions, ItemModel item) {
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
                Expanded(flex: 2, child: Text('DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 4, child: Text('REFERENCE / NOTE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('QTY IN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('QTY OUT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('BALANCE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderLight),
            itemBuilder: (context, index) {
              final itemTx = transactions[index];
              final tx = itemTx.transaction;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        _formatDate(tx.date),
                        style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Icon(itemTx.typeIcon, size: 16, color: itemTx.iconColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              itemTx.formattedTypeLabel,
                              style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        tx.notes ?? '—',
                        style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        itemTx.isPositive ? '+${_formatQty(tx.quantity)}' : '—',
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        itemTx.isNegative ? _formatQty(tx.quantity.abs()) : '—',
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.critical,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${_formatQty(itemTx.runningBalance)} ${item.unit}',
                        style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryState(
      BuildContext context, bool isActive, int itemId) {
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
          const Icon(Icons.history_toggle_off, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            'No stock movements yet',
            style: AppTypography.headlineMd.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Record stock purchases or manual adjustments to track complete inventory logs.',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: isActive ? () => context.go('/stock/$itemId/purchase') : null,
            icon: const Icon(Icons.add_shopping_cart, size: 18),
            label: const Text('Add Stock'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoFilteredResultsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Column(
        children: [
          Icon(Icons.filter_alt_off, size: 36, color: AppColors.textMuted),
          SizedBox(height: 8),
          Text(
            'No stock movements match your filter',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
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
          color: isRawMaterial
              ? AppColors.activePillBorder
              : AppColors.info.withValues(alpha: 0.3),
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
}
