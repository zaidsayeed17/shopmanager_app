import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/providers.dart';

class WorkerProductionReportScreen extends ConsumerStatefulWidget {
  const WorkerProductionReportScreen({super.key});

  @override
  ConsumerState<WorkerProductionReportScreen> createState() => _WorkerProductionReportScreenState();
}

class _WorkerProductionReportScreenState extends ConsumerState<WorkerProductionReportScreen> {
  late DateTime _fromDate;
  late DateTime _toDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _toDate = DateTime(now.year, now.month, now.day);
    _fromDate = _toDate.subtract(const Duration(days: 29));
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDateShort(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatQty(double qty) {
    return qty % 1 == 0 ? qty.toInt().toString() : qty.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final params = DateRangeParams(from: _fromDate, to: _toDate);
    final reportAsync = ref.watch(workerProductionReportProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Production Report'),
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

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Range Control
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Date Period:',
                          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        OutlinedButton.icon(
                          onPressed: _pickDateRange,
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text('${_formatDateShort(_fromDate)} - ${_formatDateShort(_toDate)}'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.borderLight),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                reportAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error loading report: $err'),
                  ),
                  data: (data) {
                    return Column(
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
                                _buildSummaryTile('Total Production Batches', '${data.totalEvents}', AppColors.primary, tileWidth),
                                _buildSummaryTile('Active Contributing Workers', '${data.activeWorkersCount}', AppColors.secondary, tileWidth),
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
                                    Icon(Icons.precision_manufacturing_outlined, size: 48, color: AppColors.textMuted),
                                    SizedBox(height: 12),
                                    Text(
                                      'No Production Recorded',
                                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'No production batches completed in the selected date range.',
                                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
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
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.workerName,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                        ),
                                      ),
                                      Text(
                                        '+${_formatQty(item.outputQty)} ${item.outputItemUnit}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.success),
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Produced: ${item.outputItemName}${item.batchRef != null && item.batchRef!.isNotEmpty ? ' (${item.batchRef})' : ''}',
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          ),
                                        ),
                                        Text(
                                          _formatDate(item.date),
                                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
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
                  },
                ),
              ],
            ),
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
