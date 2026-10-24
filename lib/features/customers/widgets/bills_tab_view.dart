import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../customers_placeholder_data.dart';

class BillsTabView extends StatelessWidget {
  final List<CustomerBill> bills;

  const BillsTabView({
    super.key,
    required this.bills,
  });

  @override
  Widget build(BuildContext context) {
    if (bills.isEmpty) {
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
            Icon(Icons.receipt_long_outlined,
                size: 36, color: AppColors.textMuted),
            SizedBox(height: 8),
            Text(
              'No bills generated yet',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: bills.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: AppColors.borderLight),
        itemBuilder: (context, index) {
          final bill = bills[index];

          Color statusBg;
          Color statusText;
          switch (bill.status) {
            case BillStatus.paid:
              statusBg = AppColors.successBg;
              statusText = AppColors.success;
              break;
            case BillStatus.partial:
              statusBg = AppColors.warningBg;
              statusText = AppColors.tertiary;
              break;
            case BillStatus.unpaid:
              statusBg = AppColors.criticalBg;
              statusText = AppColors.critical;
              break;
            case BillStatus.voided:
              statusBg = AppColors.borderLight;
              statusText = AppColors.textMuted;
              break;
          }

          return InkWell(
            onTap: () {
              if (bill.id != null) {
                context.push('/billing/${bill.id}');
              } else {
                context.go('/billing');
              }
            },
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
                            Text(
                              'Bill #${bill.billNumber}',
                              style: AppTypography.labelLg.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                bill.statusLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: statusText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bill.itemsSummary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySm.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹ ${bill.totalAmount.toStringAsFixed(0)}',
                        style: AppTypography.labelLg.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        bill.date,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
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
    );
  }
}
