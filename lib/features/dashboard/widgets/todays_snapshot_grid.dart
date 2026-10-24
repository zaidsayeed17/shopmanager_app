import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/providers.dart';

class TodaysSnapshotGrid extends ConsumerWidget {
  final bool isTablet;
  final bool isEmptyState;

  const TodaysSnapshotGrid({
    super.key,
    required this.isTablet,
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

  String _buildPaymentsSubtext(double cash, double upi, double other) {
    final parts = <String>[];
    if (cash > 0) parts.add('₹${cash.toInt()} Cash');
    if (upi > 0) parts.add('₹${upi.toInt()} UPI');
    if (other > 0) parts.add('₹${other.toInt()} Other');
    if (parts.isEmpty) return 'No collections yet';
    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesSummary = ref.watch(todaysSalesSummaryProvider).value;
    final quickSaleSummary = ref.watch(todaysQuickSaleSummaryProvider).value;
    final pmtsSummary = ref.watch(todaysPaymentsSummaryProvider).value;
    final outSummary = ref.watch(totalOutstandingProvider).value;
    final stockSummary = ref.watch(stockOverviewProvider).value;

    final salesVal = salesSummary?.totalAmount ?? 0.0;
    final salesCount = salesSummary?.billCount ?? 0;

    final qsVal = quickSaleSummary?.totalAmount ?? 0.0;
    final qsCount = quickSaleSummary?.billCount ?? 0;

    final pmtsVal = pmtsSummary?.totalAmount ?? 0.0;
    final cashVal = pmtsSummary?.cashAmount ?? 0.0;
    final upiVal = pmtsSummary?.upiAmount ?? 0.0;
    final otherVal = pmtsSummary?.otherAmount ?? 0.0;

    final outVal = outSummary?.totalOutstanding ?? 0.0;
    final outCount = outSummary?.customersWithBalanceCount ?? 0;

    final lowStockCount = stockSummary?.lowStockCount ?? 0;

    final card1 = _SnapshotCard(
      title: "Total Sales",
      value: isEmptyState ? '₹0' : _formatCurrency(salesVal),
      subtext: isEmptyState
          ? '0 bills generated today'
          : '$salesCount bill${salesCount == 1 ? '' : 's'} today',
      icon: Icons.trending_up,
      iconColor: AppColors.secondary,
    );

    final cardQS = _SnapshotCard(
      title: 'Quick Sales',
      value: isEmptyState ? '₹0' : _formatCurrency(qsVal),
      subtext: isEmptyState
          ? '0 counter sales'
          : '$qsCount counter sale${qsCount == 1 ? '' : 's'}',
      icon: Icons.flash_on,
      iconColor: Colors.amber.shade700,
      badgeText: 'Direct',
      badgeColor: AppColors.amberHeaderBg,
      badgeTextColor: Colors.black87,
    );

    final card2 = _SnapshotCard(
      title: 'Payments Recd',
      value: isEmptyState ? '₹0' : _formatCurrency(pmtsVal),
      subtext: isEmptyState
          ? 'No collections yet'
          : _buildPaymentsSubtext(cashVal, upiVal, otherVal),
      icon: Icons.account_balance_wallet_outlined,
      iconColor: AppColors.primary,
    );

    final isOutPositive = !isEmptyState && outVal > 0;
    final card3 = _SnapshotCard(
      title: 'Outstanding',
      value: isEmptyState ? '₹0' : _formatCurrency(outVal),
      valueColor: isOutPositive ? AppColors.tertiary : AppColors.textPrimary,
      subtext: isEmptyState
          ? 'All dues clear'
          : (outVal > 0 ? 'Across $outCount customer${outCount == 1 ? '' : 's'}' : 'No Outstanding'),
      badgeText: isOutPositive ? 'Aging' : 'No dues',
      badgeColor: isOutPositive ? AppColors.warningBg : AppColors.successBg,
      badgeTextColor: isOutPositive ? AppColors.tertiary : AppColors.success,
    );

    final isLowStock = !isEmptyState && lowStockCount > 0;
    final card4 = _SnapshotCard(
      title: 'Low Stock',
      value: isEmptyState ? '0 Items' : '$lowStockCount Item${lowStockCount == 1 ? '' : 's'}',
      valueColor: isLowStock ? AppColors.critical : AppColors.success,
      subtext: isEmptyState
          ? 'All items stocked'
          : (isLowStock ? '$lowStockCount items below min level' : 'All items stocked'),
      subtextColor: isLowStock ? AppColors.critical : AppColors.textSecondary,
      badgeText: isLowStock ? 'Action' : 'All Stocked',
      badgeColor: isLowStock ? AppColors.criticalBg : AppColors.successBg,
      badgeTextColor: isLowStock ? AppColors.critical : AppColors.success,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "TODAY'S SNAPSHOT",
              style: AppTypography.labelSm.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              isEmptyState ? 'Day Opening' : 'Realtime Tally',
              style: AppTypography.labelMd.copyWith(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (isTablet)
          Row(
            children: [
              Expanded(child: card1),
              const SizedBox(width: 8),
              Expanded(child: cardQS),
              const SizedBox(width: 8),
              Expanded(child: card2),
              const SizedBox(width: 8),
              Expanded(child: card3),
              const SizedBox(width: 8),
              Expanded(child: card4),
            ],
          )
        else
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: card1),
                  const SizedBox(width: 10),
                  Expanded(child: cardQS),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: card2),
                  const SizedBox(width: 10),
                  Expanded(child: card3),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: card4),
                  const SizedBox(width: 10),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ],
          ),
      ],
    );
  }
}

class _SnapshotCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;
  final String subtext;
  final Color? subtextColor;
  final IconData? icon;
  final Color? iconColor;
  final String? badgeText;
  final Color? badgeColor;
  final Color? badgeTextColor;

  const _SnapshotCard({
    required this.title,
    required this.value,
    this.valueColor,
    required this.subtext,
    this.subtextColor,
    this.icon,
    this.iconColor,
    this.badgeText,
    this.badgeColor,
    this.badgeTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: badgeColor ?? AppColors.background,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badgeText!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: badgeTextColor ?? AppColors.textSecondary,
                    ),
                  ),
                )
              else if (icon != null)
                Icon(
                  icon,
                  size: 18,
                  color: iconColor ?? AppColors.textSecondary,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.headlineLg.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySm.copyWith(
              fontSize: 11,
              color: subtextColor ?? AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
