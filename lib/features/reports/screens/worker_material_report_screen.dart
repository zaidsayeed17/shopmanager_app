import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/providers.dart';

class WorkerMaterialReportScreen extends ConsumerWidget {
  const WorkerMaterialReportScreen({super.key});

  String _formatQty(double qty) {
    return qty % 1 == 0 ? qty.toInt().toString() : qty.toStringAsFixed(2);
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(workerMaterialReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Material Report'),
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
                    // Summary Tiles
                    LayoutBuilder(
                      builder: (context, box) {
                        final width = box.maxWidth;
                        final crossCount = isTablet ? 2 : (width > 450 ? 2 : 1);
                        final tileWidth = (width - (crossCount - 1) * 12) / crossCount;

                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildSummaryTile('Workers Holding Materials', '${data.distinctWorkersCount}', AppColors.primary, tileWidth),
                            _buildSummaryTile('Pending Material Batches', '${data.pendingLineItemsCount}', AppColors.tertiary, tileWidth),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    if (data.items.isEmpty)
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Column(
                              children: const [
                                Icon(Icons.assignment_turned_in, size: 48, color: AppColors.success),
                                SizedBox(height: 12),
                                Text(
                                  'No Pending Materials',
                                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 16),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'All raw materials issued to workers have been completely used in production.',
                                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      Card(
                        margin: EdgeInsets.zero,
                        clipBehavior: Clip.antiAlias,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: data.items.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = data.items[index];

                            return ListTile(
                              dense: true,
                              onTap: () {
                                context.push('/workers/${item.workerId}');
                              },
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.workerName,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                    ),
                                  ),
                                  Text(
                                    '${_formatQty(item.remainingPendingQty)} ${item.itemUnit} pending',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.tertiary),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Material: ${item.itemName} (Issued: ${_formatQty(item.originalIssuedQty)} ${item.itemUnit})',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                    ),
                                    Text(
                                      _formatDate(item.issueDate),
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                            );
                          },
                        ),
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
