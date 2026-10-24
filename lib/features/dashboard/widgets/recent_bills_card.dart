import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/bill_model.dart';
import '../../../data/repositories/providers.dart';

class RecentBillsCard extends ConsumerWidget {
  final bool isEmptyState;

  const RecentBillsCard({
    super.key,
    this.isEmptyState = false,
  });

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _formatDate(DateTime dt) {
    return '${dt.day} ${_months[dt.month - 1]} ${dt.year}';
  }

  String _formatCurrency(double val) {
    if (val % 1 == 0) {
      return '₹${val.toInt().toString().replaceAllMapped(
        RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))'),
        (m) => '${m[1]},',
      )}';
    }
    return '₹${val.toStringAsFixed(2)}';
  }

  Widget _buildStatusBadge(BillModel bill) {
    if (bill.isVoided) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.criticalBg,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: const Text(
          'Voided',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.critical,
          ),
        ),
      );
    }

    Color bg;
    Color fg;
    String text;

    if (bill.isPaid) {
      bg = AppColors.successBg;
      fg = AppColors.success;
      text = 'Paid';
    } else if (bill.isPartial) {
      bg = AppColors.warningBg;
      fg = AppColors.tertiary;
      text = 'Partial';
    } else {
      bg = AppColors.criticalBg;
      fg = AppColors.critical;
      text = 'Unpaid';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bills = ref.watch(recentBillsProvider).value ?? [];
    final hasNoBills = isEmptyState || bills.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT BILLS',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            InkWell(
              onTap: () => context.go('/billing'),
              child: Row(
                children: [
                  Text(
                    hasNoBills ? '0 Total' : 'View all bills',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!hasNoBills) ...[
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
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
          child: hasNoBills
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          size: 28,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ready to start trading?',
                        style: AppTypography.headlineMd.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'No bills created yet — create your first bill to start tracking sales and receivables effortlessly.',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => context.go('/billing/new'),
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                          label: const Text('Create Bill'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.bolt, size: 16, color: AppColors.secondary),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Instant Invoicing',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.share, size: 16, color: AppColors.secondary),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'WhatsApp PDF',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bills.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderLight),
                  itemBuilder: (context, index) {
                    final bill = bills[index];

                    return InkWell(
                      onTap: () => context.go('/billing/${bill.id}'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bill.customerName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.labelLg.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${bill.billNumber} • ${_formatDate(bill.billDate)}',
                                    style: AppTypography.bodySm.copyWith(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatCurrency(bill.grandTotal),
                                  style: AppTypography.labelLg.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    decoration: bill.isVoided ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                _buildStatusBadge(bill),
                              ],
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
