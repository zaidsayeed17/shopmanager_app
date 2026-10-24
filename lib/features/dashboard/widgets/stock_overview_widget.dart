import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/providers.dart';

class StockOverviewWidget extends ConsumerWidget {
  final bool isEmptyState;

  const StockOverviewWidget({
    super.key,
    this.isEmptyState = false,
  });

  String _formatCurrency(double val) {
    if (val % 1 == 0) {
      return '₹${val.toInt().toString().replaceAllMapped(
        RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))'),
        (m) => '${m[1]},',
      )}';
    }
    return '₹${val.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockSummary = ref.watch(stockOverviewProvider).value;

    final rawCount = stockSummary?.rawMaterialCount ?? 0;
    final finishedCount = stockSummary?.finishedProductCount ?? 0;
    final stockVal = stockSummary?.totalStockValue ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STOCK OVERVIEW',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              isEmptyState ? 'Inventory Ready' : 'Live Stock',
              style: AppTypography.labelMd.copyWith(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _StockCard(
                title: 'Raw Materials',
                count: isEmptyState ? 0 : rawCount,
                subtext: isEmptyState
                    ? '+ Add Raw Materials'
                    : 'Val: ${_formatCurrency(stockVal)}',
                isWarning: false,
                onTap: () => context.go('/stock'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StockCard(
                title: 'Finished Goods',
                count: isEmptyState ? 0 : finishedCount,
                subtext: isEmptyState ? '+ Add Finished Goods' : 'Active Products',
                isWarning: false,
                onTap: () => context.go('/stock'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StockCard extends StatelessWidget {
  final String title;
  final int count;
  final String subtext;
  final bool isWarning;
  final VoidCallback onTap;

  const _StockCard({
    required this.title,
    required this.count,
    required this.subtext,
    required this.isWarning,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$count Items',
              style: AppTypography.headlineLg.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isWarning ? AppColors.warningBg : AppColors.background,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                subtext,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isWarning ? FontWeight.w600 : FontWeight.w500,
                  color: isWarning ? AppColors.warning : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
