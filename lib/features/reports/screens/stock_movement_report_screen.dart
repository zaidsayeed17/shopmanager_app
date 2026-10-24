import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/providers.dart';

class StockMovementReportScreen extends ConsumerStatefulWidget {
  const StockMovementReportScreen({super.key});

  @override
  ConsumerState<StockMovementReportScreen> createState() => _StockMovementReportScreenState();
}

class _StockMovementReportScreenState extends ConsumerState<StockMovementReportScreen> {
  late DateTime _fromDate;
  late DateTime _toDate;
  String _selectedType = 'all';

  final List<Map<String, String>> _typeOptions = const [
    {'value': 'all', 'label': 'All Types'},
    {'value': 'purchase', 'label': 'Purchase'},
    {'value': 'sale', 'label': 'Sale'},
    {'value': 'production_used', 'label': 'Production Used'},
    {'value': 'production_completed', 'label': 'Production Output'},
    {'value': 'adjustment_in', 'label': 'Adjustment (+)'},
    {'value': 'adjustment_out', 'label': 'Adjustment (-)'},
    {'value': 'returned', 'label': 'Return'},
    {'value': 'waste', 'label': 'Waste/Damage'},
  ];

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
    final absVal = qty.abs();
    final str = absVal % 1 == 0 ? absVal.toInt().toString() : absVal.toStringAsFixed(2);
    return qty > 0 ? '+$str' : '-$str';
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'purchase':
      case 'adjustment_in':
      case 'production_completed':
        return AppColors.success;
      case 'sale':
      case 'production_used':
      case 'adjustment_out':
      case 'waste':
        return AppColors.critical;
      case 'returned':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  String _getTypeLabel(String type) {
    final found = _typeOptions.firstWhere((e) => e['value'] == type, orElse: () => {'label': type});
    return found['label']!;
  }

  @override
  Widget build(BuildContext context) {
    final params = StockMovementReportParams(
      from: _fromDate,
      to: _toDate,
      typeFilter: _selectedType == 'all' ? null : _selectedType,
    );

    final reportAsync = ref.watch(stockMovementReportProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Movement Report'),
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
                // Date Range & Type Filter Row
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickDateRange,
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text('${_formatDateShort(_fromDate)} - ${_formatDateShort(_toDate)}'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.borderLight),
                          ),
                        ),
                        DropdownButtonHideUnderline(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.borderLight),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedType,
                              isDense: true,
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedType = val);
                              },
                              items: _typeOptions.map((opt) {
                                return DropdownMenuItem(
                                  value: opt['value'],
                                  child: Text(opt['label']!, style: const TextStyle(fontSize: 13)),
                                );
                              }).toList(),
                            ),
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
                            final crossCount = isTablet ? 3 : (width > 450 ? 3 : 1);
                            final tileWidth = (width - (crossCount - 1) * 12) / crossCount;

                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _buildSummaryTile('Total Events', '${data.totalEvents}', AppColors.primary, tileWidth),
                                _buildSummaryTile('Stock In Events', '${data.stockInCount}', AppColors.success, tileWidth),
                                _buildSummaryTile('Stock Out Events', '${data.stockOutCount}', AppColors.critical, tileWidth),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        if (data.items.isEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Center(
                                child: Column(
                                  children: const [
                                    Icon(Icons.swap_horiz, size: 48, color: AppColors.textMuted),
                                    SizedBox(height: 12),
                                    Text(
                                      'No stock movements found',
                                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'No movements recorded for the selected date range or filter.',
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
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: data.items.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final item = data.items[index];
                                final isPositive = item.quantity > 0;
                                final color = _getTypeColor(item.type);

                                return ListTile(
                                  dense: true,
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.itemName,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          _getTypeLabel(item.type),
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Text(
                                        _formatDate(item.date),
                                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                      ),
                                      if (item.referenceNote != null && item.referenceNote!.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '• ${item.referenceNote}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  trailing: Text(
                                    '${_formatQty(item.quantity)} ${item.itemUnit}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isPositive ? AppColors.success : AppColors.critical,
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
