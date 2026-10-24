import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/worker_model.dart';
import '../../../data/repositories/providers.dart';
import '../../../data/repositories/worker_wage_repository.dart';

class WorkerDetailPlaceholderScreen extends ConsumerWidget {
  final String workerId;

  const WorkerDetailPlaceholderScreen({
    super.key,
    required this.workerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final numericId = int.tryParse(workerId) ?? 0;
    final workerAsync = ref.watch(workerByIdProvider(numericId));

    return workerAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Worker Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/workers'),
          ),
        ),
        body: Center(child: Text('Error: $err')),
      ),
      data: (worker) {
        final title = worker?.name ?? 'Worker #$workerId';
        final hasPaymentType =
            worker?.paymentType != null && worker!.paymentType!.trim().isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              title,
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/workers');
                }
              },
            ),
            actions: [
              if (worker != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit Worker',
                  onPressed: () => context.go('/workers/edit/${worker.id}'),
                ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= AppConstants.tabletBreakpoint;
              final contentPadding = isTablet ? 24.0 : 16.0;

              return Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 800 : double.infinity,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(contentPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Worker Header Card
                        _buildWorkerHeaderCard(context, worker),
                        const SizedBox(height: 16),

                        // 2. Action Buttons Row (3 Buttons)
                        if (worker != null) ...[
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => context.go('/workers/${worker.id}/issue'),
                                icon: const Icon(Icons.outbox_outlined, size: 18),
                                label: const Text('+ Issue Material'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.surface,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => context.go('/workers/${worker.id}/production'),
                                icon: const Icon(Icons.precision_manufacturing_outlined, size: 18),
                                label: const Text('+ Record Production'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: AppColors.surface,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: hasPaymentType
                                    ? () => context.go('/workers/${worker.id}/work-entry/add')
                                    : () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Set up payment type first via Edit Worker to add work entries.',
                                            ),
                                            backgroundColor: AppColors.tertiary,
                                          ),
                                        );
                                      },
                                icon: Icon(
                                  Icons.add_task_outlined,
                                  size: 18,
                                  color: hasPaymentType ? AppColors.surface : AppColors.textMuted,
                                ),
                                label: Text(
                                  '+ Add Work Entry',
                                  style: TextStyle(
                                    color: hasPaymentType ? AppColors.surface : AppColors.textMuted,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      hasPaymentType ? AppColors.primary : AppColors.borderLight,
                                  foregroundColor:
                                      hasPaymentType ? AppColors.surface : AppColors.textMuted,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => context.go('/workers/${worker.id}/cutting/add'),
                                icon: const Icon(Icons.content_cut_outlined, size: 18),
                                label: const Text('+ Cutting Entry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.tertiary,
                                  foregroundColor: AppColors.surface,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (!hasPaymentType) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Set up payment type first via Edit Worker',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.tertiary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                        ],

                        // 3. Worker Cutting Summary & History Section Header
                        _buildSectionHeader('WORKER CUTTING SUMMARY & HISTORY'),
                        const SizedBox(height: 12),
                        _buildCuttingSummaryCard(ref, numericId),
                        const SizedBox(height: 16),
                        _buildCuttingEntriesList(ref, numericId),
                        const SizedBox(height: 24),

                        // 4. Payment / Wage History Section Header
                        _buildSectionHeader('PAYMENT / WORK HISTORY'),
                        const SizedBox(height: 12),

                        // 5. Live Wage Summary Card
                        _buildWageSummaryCard(ref, numericId),
                        const SizedBox(height: 16),

                        // 6. Work Entries List
                        _buildWorkEntriesList(ref, numericId),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildWorkerHeaderCard(BuildContext context, WorkerModel? worker) {
    if (worker == null) return const SizedBox.shrink();

    final paymentTypeLabel = worker.paymentType == 'hour'
        ? 'Hour Based (₹${worker.defaultHourRate?.toStringAsFixed(2) ?? '0'}/h)'
        : worker.paymentType == 'piece'
            ? 'Piece Based (₹${worker.defaultNagRate?.toStringAsFixed(2) ?? '0'}/pc)'
            : worker.paymentType == 'both'
                ? 'Both (₹${worker.defaultHourRate?.toStringAsFixed(2) ?? '0'}/h, ₹${worker.defaultNagRate?.toStringAsFixed(2) ?? '0'}/pc)'
                : 'Payment Type Not Configured';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.activePillBg,
            child: Text(
              worker.initials,
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      worker.name,
                      style: AppTypography.headlineMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Text(
                        worker.formattedWorkerId,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${worker.workType ?? 'General Worker'} ${worker.mobile != null && worker.mobile!.isNotEmpty ? '• +91 ${worker.mobile}' : ''}',
                  style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: worker.paymentType != null ? AppColors.infoBg : AppColors.warningBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    paymentTypeLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: worker.paymentType != null ? AppColors.info : AppColors.tertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.labelSm.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildWageSummaryCard(WidgetRef ref, int workerId) {
    final summaryAsync = ref.watch(workerWageSummaryProvider(workerId));

    return summaryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error loading wage summary: $e'),
      data: (summary) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryMetric('Total Hours', '${summary.totalHours % 1 == 0 ? summary.totalHours.toInt() : summary.totalHours.toStringAsFixed(1)} hrs'),
                  _buildSummaryMetric('Total Nag/Pc', '${summary.totalNag % 1 == 0 ? summary.totalNag.toInt() : summary.totalNag.toStringAsFixed(1)} pcs'),
                  _buildSummaryMetric('Total Earnings', '₹${summary.totalEarnings.toStringAsFixed(2)}'),
                ],
              ),
              const Divider(height: 24, thickness: 0.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryMetric('Total Advance', '₹${summary.totalAdvance.toStringAsFixed(2)}'),
                  _buildSummaryMetric(
                    'Remaining Amount',
                    '₹${summary.remainingAmount.toStringAsFixed(2)}',
                    isHighlight: true,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryMetric(String label, String value, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: isHighlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkEntriesList(WidgetRef ref, int workerId) {
    final entriesStream = ref.watch(workerWorkEntriesStreamProvider(workerId));

    return entriesStream.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error loading work entries: $e'),
      data: (entries) {
        if (entries.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Column(
              children: [
                Icon(Icons.history_outlined, size: 36, color: AppColors.textMuted),
                SizedBox(height: 8),
                Text(
                  'No work entries recorded yet.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tap "+ Add Work Entry" above to record daily work and wages.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final entry = entries[index];
            final status = getWorkEntryStatus(entry.totalAmount, entry.advance);
            final dateStr =
                '${entry.date.day.toString().padLeft(2, '0')}/${entry.date.month.toString().padLeft(2, '0')}/${entry.date.year}';

            final parts = <String>[];
            if (entry.hours != null && entry.hours! > 0) {
              final hStr = entry.hours! % 1 == 0 ? entry.hours!.toInt().toString() : entry.hours!.toStringAsFixed(1);
              parts.add('${hStr}h @ ₹${entry.hourRate?.toStringAsFixed(2) ?? '0'}');
            }
            if (entry.nagQty != null && entry.nagQty! > 0) {
              final nStr = entry.nagQty! % 1 == 0 ? entry.nagQty!.toInt().toString() : entry.nagQty!.toStringAsFixed(1);
              parts.add('${nStr}pc @ ₹${entry.nagRate?.toStringAsFixed(2) ?? '0'}');
            }

            final workSummary = parts.join(' + ');

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              dateStr,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusPill(status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          workSummary,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        if (entry.workDescription != null &&
                            entry.workDescription!.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Item/Work: ${entry.workDescription!.trim()}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        if (entry.notes != null && entry.notes!.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Note: ${entry.notes!.trim()}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${entry.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Adv: ₹${entry.advance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Payable: ₹${entry.finalPayable.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusPill(WorkEntryPaymentStatus status) {
    Color bg;
    Color fg;
    switch (status) {
      case WorkEntryPaymentStatus.paid:
        bg = AppColors.successBg;
        fg = AppColors.success;
        break;
      case WorkEntryPaymentStatus.partial:
        bg = AppColors.warningBg;
        fg = AppColors.tertiary;
        break;
      case WorkEntryPaymentStatus.unpaid:
        bg = AppColors.criticalBg;
        fg = AppColors.critical;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildCuttingSummaryCard(WidgetRef ref, int workerId) {
    final todaysSummaryAsync = ref.watch(workerTodaysCuttingSummaryProvider(workerId));

    return todaysSummaryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error loading cutting summary: $e'),
      data: (summary) {
        if (summary.items.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Text(
              'No cutting entries recorded today.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Cutting Summary",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Total: ${summary.overallTotalQuantity % 1 == 0 ? summary.overallTotalQuantity.toInt() : summary.overallTotalQuantity.toStringAsFixed(1)} nag (₹${summary.overallTotalAmount.toStringAsFixed(2)})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: summary.items.map((item) {
                  final qtyStr = item.totalQuantity % 1 == 0
                      ? item.totalQuantity.toInt().toString()
                      : item.totalQuantity.toStringAsFixed(1);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      '${item.itemName}: $qtyStr nag (₹${item.totalAmount.toStringAsFixed(2)})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCuttingEntriesList(WidgetRef ref, int workerId) {
    final cuttingEntriesStream = ref.watch(workerCuttingEntriesStreamProvider(workerId));

    return cuttingEntriesStream.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error loading cutting history: $e'),
      data: (entries) {
        if (entries.isEmpty) {
          return const SizedBox.shrink();
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = entries[index];
            final entry = item.entry;
            final dateStr =
                '${entry.date.day.toString().padLeft(2, '0')}/${entry.date.month.toString().padLeft(2, '0')}/${entry.date.year}';
            final qtyStr =
                entry.quantity % 1 == 0 ? entry.quantity.toInt().toString() : entry.quantity.toStringAsFixed(1);

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.activePillBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.content_cut_outlined, size: 18, color: AppColors.primary),
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
                              item.itemName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              dateStr,
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$qtyStr nag @ ₹${entry.rate.toStringAsFixed(2)} / nag',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        if (entry.remark != null && entry.remark!.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Remark: ${entry.remark!.trim()}',
                            style: const TextStyle(
                                fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '₹${entry.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
