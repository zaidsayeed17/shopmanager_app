import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/providers.dart';

class PaymentReportScreen extends ConsumerStatefulWidget {
  const PaymentReportScreen({super.key});

  @override
  ConsumerState<PaymentReportScreen> createState() => _PaymentReportScreenState();
}

class _PaymentReportScreenState extends ConsumerState<PaymentReportScreen> {
  late DateTime _fromDate;
  late DateTime _toDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _toDate = DateTime(now.year, now.month, now.day);
    _fromDate = _toDate.subtract(const Duration(days: 6));
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

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDateShort(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }

  Color _getMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return AppColors.success;
      case 'upi':
        return AppColors.info;
      case 'bank':
        return Colors.indigo;
      case 'card':
        return Colors.purple;
      case 'credit':
        return AppColors.warning;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final params = DateRangeParams(from: _fromDate, to: _toDate);
    final reportAsync = ref.watch(paymentReportProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Report'),
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
                          'Payment Period:',
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
                        // Summary Cards Grid
                        LayoutBuilder(
                          builder: (context, box) {
                            final width = box.maxWidth;
                            final crossCount = isTablet ? 4 : (width > 500 ? 2 : 1);
                            final tileWidth = (width - (crossCount - 1) * 12) / crossCount;

                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _buildSummaryTile('Total Payments Collected', _formatCurrency(data.totalCollected), AppColors.primary, tileWidth),
                                _buildSummaryTile('Cash Payments', _formatCurrency(data.cashTotal), AppColors.success, tileWidth),
                                _buildSummaryTile('UPI Payments', _formatCurrency(data.upiTotal), AppColors.info, tileWidth),
                                _buildSummaryTile('Other Payments', _formatCurrency(data.otherTotal), AppColors.secondary, tileWidth),
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
                                    Icon(Icons.payments_outlined, size: 48, color: AppColors.textMuted),
                                    SizedBox(height: 12),
                                    Text(
                                      'No Payments Recorded',
                                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'No customer payments recorded during the selected period.',
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
                                final methodColor = _getMethodColor(item.method);

                                return ListTile(
                                  dense: true,
                                  onTap: item.billId != null
                                      ? () {
                                          context.push('/billing/${item.billId}');
                                        }
                                      : null,
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.customerName,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                        ),
                                      ),
                                      Text(
                                        _formatCurrency(item.amount),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: methodColor.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item.method.toUpperCase(),
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: methodColor),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (item.billNumber != null) ...[
                                          Text(
                                            'Bill #${item.billNumber}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        Text(
                                          _formatDate(item.date),
                                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                        ),
                                        if (item.notes != null && item.notes!.isNotEmpty) ...[
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '• ${item.notes}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  trailing: item.billId != null
                                      ? const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted)
                                      : null,
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
