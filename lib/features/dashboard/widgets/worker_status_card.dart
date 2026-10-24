import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/providers.dart';

class WorkerStatusCard extends ConsumerWidget {
  final bool isEmptyState;

  const WorkerStatusCard({
    super.key,
    this.isEmptyState = false,
  });

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _formatDate(DateTime dt) {
    return '${dt.day} ${_months[dt.month - 1]}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(workersPendingSummaryProvider).value;
    final previews = ref.watch(pendingMaterialPreviewProvider).value ?? [];

    final workersPendingCount = summary?.workersWithPendingCount ?? 0;
    final hasNoWork = isEmptyState || previews.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'WORKER STATUS',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            InkWell(
              onTap: () => context.go('/workers'),
              child: Row(
                children: [
                  Text(
                    'View all',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: AppColors.primary,
                  ),
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
          child: Column(
            children: [
              // Summary Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                  border: Border(
                    bottom: BorderSide(color: AppColors.borderLight, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: hasNoWork ? AppColors.textMuted : AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hasNoWork
                            ? 'No active job work'
                            : '$workersPendingCount worker${workersPendingCount == 1 ? '' : 's'} currently processing material',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (hasNoWork)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Assign raw material to workers to track processing jobs and daily output.',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/workers'),
                        icon: const Icon(Icons.assignment_ind, size: 16),
                        label: const Text('+ Assign Material'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.borderLight),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: previews.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderLight),
                  itemBuilder: (context, index) {
                    final item = previews[index];
                    final qtyStr = item.remainingQty % 1 == 0
                        ? item.remainingQty.toInt().toString()
                        : item.remainingQty.toStringAsFixed(1);

                    return InkWell(
                      onTap: () => context.go('/workers/${item.workerId}'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        item.workerName,
                                        style: AppTypography.labelLg.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '• ${item.itemName} ($qtyStr ${item.unit})',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.bodySm.copyWith(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 12,
                                        color: AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Issued ${_formatDate(item.date)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: item.status == 'Partial' ? AppColors.warningBg : AppColors.activePillBg,
                                borderRadius: BorderRadius.circular(9999),
                                border: Border.all(
                                  color: item.status == 'Partial' ? AppColors.warning.withValues(alpha: 0.3) : AppColors.activePillBorder,
                                ),
                              ),
                              child: Text(
                                item.status,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: item.status == 'Partial' ? AppColors.tertiary : AppColors.primary,
                                ),
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
        ),
      ],
    );
  }
}
