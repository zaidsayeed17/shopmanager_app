import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/billing_repository.dart';
import '../../../data/repositories/providers.dart';

class SalesReportScreen extends ConsumerStatefulWidget {
  final String? initialTab;

  const SalesReportScreen({
    super.key,
    this.initialTab,
  });

  @override
  ConsumerState<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends ConsumerState<SalesReportScreen> {
  late String _tab; // 'daily' or 'monthly'

  // Daily mode state: default to last 7 days
  late DateTime _dailyFrom;
  late DateTime _dailyTo;

  // Monthly mode state: default to 6 months
  int _monthsBack = 6;

  int? _hoveredBarIndex;

  @override
  void initState() {
    super.initState();
    _tab = (widget.initialTab == 'monthly') ? 'monthly' : 'daily';

    final now = DateTime.now();
    _dailyTo = DateTime(now.year, now.month, now.day);
    _dailyFrom = _dailyTo.subtract(const Duration(days: 6));
  }

  void _setPresetRange(int days) {
    final now = DateTime.now();
    setState(() {
      _dailyTo = DateTime(now.year, now.month, now.day);
      _dailyFrom = _dailyTo.subtract(Duration(days: days - 1));
    });
  }

  void _setThisMonthPreset() {
    final now = DateTime.now();
    setState(() {
      _dailyFrom = DateTime(now.year, now.month, 1);
      _dailyTo = DateTime(now.year, now.month, now.day);
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _dailyFrom, end: _dailyTo),
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
        _dailyFrom = picked.start;
        _dailyTo = picked.end;
      });
    }
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  String _formatDateShort(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatMonthShort(int month, int year) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[month - 1]} ${year.toString().substring(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDaily = _tab == 'daily';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Report'),
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

          return Column(
            children: [
              // Segmented Daily/Monthly Control
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        padding: const EdgeInsets.all(3),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _tab = 'daily'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isDaily ? AppColors.primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Daily',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isDaily ? FontWeight.bold : FontWeight.w500,
                                      color: isDaily ? Colors.white : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _tab = 'monthly'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: !isDaily ? AppColors.primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Monthly',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: !isDaily ? FontWeight.bold : FontWeight.w500,
                                      color: !isDaily ? Colors.white : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: isDaily ? _buildDailyReportView(isTablet, padding) : _buildMonthlyReportView(isTablet, padding),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDailyReportView(bool isTablet, double padding) {
    final params = DailySalesReportParams(from: _dailyFrom, to: _dailyTo);
    final reportAsync = ref.watch(dailySalesReportProvider(params));

    return reportAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading sales report: $err')),
      data: (data) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Controls
              _buildDailyControls(),
              const SizedBox(height: 16),

              if (data.totalBills == 0)
                _buildEmptyState()
              else ...[
                if (isTablet)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: _buildSummaryCards(data.totalSales, data.totalBills, data.averageBillValue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 6,
                        child: _buildChartCard(
                          points: data.points.map((p) => _BarDataPoint(
                            label: _formatDateShort(p.date),
                            value: p.totalSales,
                            count: p.billCount,
                          )).toList(),
                        ),
                      ),
                    ],
                  )
                else ...[
                  _buildSummaryCards(data.totalSales, data.totalBills, data.averageBillValue),
                  const SizedBox(height: 16),
                  _buildChartCard(
                    points: data.points.map((p) => _BarDataPoint(
                      label: _formatDateShort(p.date),
                      value: p.totalSales,
                      count: p.billCount,
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 20),

                _buildDailyBreakdownTable(data.points, data.totalSales, data.totalBills),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthlyReportView(bool isTablet, double padding) {
    final reportAsync = ref.watch(monthlySalesReportProvider(_monthsBack));

    return reportAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading sales report: $err')),
      data: (data) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Monthly Controls
              _buildMonthlyControls(),
              const SizedBox(height: 16),

              if (data.totalBills == 0)
                _buildEmptyState()
              else ...[
                if (isTablet)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: _buildSummaryCards(data.totalSales, data.totalBills, data.averageBillValue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 6,
                        child: _buildChartCard(
                          points: data.points.map((p) => _BarDataPoint(
                            label: _formatMonthShort(p.month, p.year),
                            value: p.totalSales,
                            count: p.billCount,
                          )).toList(),
                        ),
                      ),
                    ],
                  )
                else ...[
                  _buildSummaryCards(data.totalSales, data.totalBills, data.averageBillValue),
                  const SizedBox(height: 16),
                  _buildChartCard(
                    points: data.points.map((p) => _BarDataPoint(
                      label: _formatMonthShort(p.month, p.year),
                      value: p.totalSales,
                      count: p.billCount,
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 20),

                _buildMonthlyBreakdownTable(data.points, data.totalSales, data.totalBills),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPresetChip('Last 7 Days', () => _setPresetRange(7)),
                const SizedBox(width: 6),
                _buildPresetChip('Last 30 Days', () => _setPresetRange(30)),
                const SizedBox(width: 6),
                _buildPresetChip('This Month', _setThisMonthPreset),
                const SizedBox(width: 6),
                OutlinedButton.icon(
                  onPressed: _pickDateRange,
                  icon: const Icon(Icons.date_range, size: 16),
                  label: Text('${_formatDateShort(_dailyFrom)} - ${_formatDateShort(_dailyTo)}'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppColors.background,
      side: const BorderSide(color: AppColors.borderLight),
      labelStyle: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
    );
  }

  Widget _buildMonthlyControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const Text('Period: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 8),
          _buildMonthChip(3, '3 Months'),
          const SizedBox(width: 6),
          _buildMonthChip(6, '6 Months'),
          const SizedBox(width: 6),
          _buildMonthChip(12, '12 Months'),
        ],
      ),
    );
  }

  Widget _buildMonthChip(int months, String label) {
    final isSelected = _monthsBack == months;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _monthsBack = months);
        }
      },
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.background,
      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.borderLight),
      labelStyle: TextStyle(
        fontSize: 12,
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildSummaryCards(double totalSales, int totalBills, double avgBillValue) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Sales',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _formatCurrency(totalSales),
                style: AppTypography.headlineLg.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Bills',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalBills',
                      style: AppTypography.headlineMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Avg Bill Value',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(avgBillValue),
                      style: AppTypography.headlineMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartCard({required List<_BarDataPoint> points}) {
    if (points.isEmpty) return const SizedBox.shrink();

    // Find peak value
    double peakVal = 0.0;
    int peakIndex = -1;
    for (int i = 0; i < points.length; i++) {
      if (points[i].value > peakVal) {
        peakVal = points[i].value;
        peakIndex = i;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SALES TREND',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              if (peakIndex >= 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Peak: ${_formatCurrency(peakVal)}',
                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxBarHeight = constraints.maxHeight - 30; // space for x labels

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: points.asMap().entries.map((entry) {
                    final index = entry.key;
                    final pt = entry.value;
                    final isPeak = index == peakIndex && pt.value > 0;
                    final isHovered = _hoveredBarIndex == index;

                    final ratio = peakVal > 0 ? (pt.value / peakVal) : 0.0;
                    final barHeight = (ratio * maxBarHeight).clamp(4.0, maxBarHeight);

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _hoveredBarIndex = isHovered ? null : index;
                          });
                        },
                        child: Tooltip(
                          message: '${pt.label}\nSales: ${_formatCurrency(pt.value)}\nBills: ${pt.count}',
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (pt.value > 0 && (isPeak || isHovered))
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    '₹${(pt.value / 1000).toStringAsFixed(1)}k',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isPeak ? AppColors.primary : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: points.length > 15 ? 12 : 20,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color: isPeak
                                      ? AppColors.primary
                                      : (isHovered ? AppColors.secondary : AppColors.primary.withValues(alpha: 0.2)),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                  border: isPeak ? Border.all(color: AppColors.primary, width: 1) : null,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                pt.label,
                                style: TextStyle(
                                  fontSize: points.length > 15 ? 9 : 10,
                                  color: isPeak ? AppColors.primary : AppColors.textMuted,
                                  fontWeight: isPeak ? FontWeight.bold : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyBreakdownTable(List<DailySalesPoint> points, double totalSales, int totalBills) {
    // Reverse points to show most recent date first
    final sortedPoints = List<DailySalesPoint>.from(points.reversed);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              'BREAKDOWN BY DATE',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),

          // Header Row
          Container(
            color: AppColors.background,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: const [
                Expanded(flex: 4, child: Text('Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 3, child: Text('Bills', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 4, child: Text('Total Sales', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
              ],
            ),
          ),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedPoints.length,
            separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderLight),
            itemBuilder: (context, index) {
              final pt = sortedPoints[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        _formatDateShort(pt.date),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        '${pt.billCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        _formatCurrency(pt.totalSales),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: pt.totalSales > 0 ? FontWeight.bold : FontWeight.normal,
                          color: pt.totalSales > 0 ? AppColors.textPrimary : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Total Summary Row
          Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
              border: Border(top: BorderSide(color: AppColors.borderMedium, width: 1.5)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Expanded(flex: 4, child: Text('TOTAL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                Expanded(flex: 3, child: Text('$totalBills', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                Expanded(flex: 4, child: Text(_formatCurrency(totalSales), textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBreakdownTable(List<MonthlySalesPoint> points, double totalSales, int totalBills) {
    // Reverse points to show most recent month first
    final sortedPoints = List<MonthlySalesPoint>.from(points.reversed);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              'BREAKDOWN BY MONTH',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),

          // Header Row
          Container(
            color: AppColors.background,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: const [
                Expanded(flex: 4, child: Text('Month', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 3, child: Text('Bills', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 4, child: Text('Total Sales', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
              ],
            ),
          ),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedPoints.length,
            separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderLight),
            itemBuilder: (context, index) {
              final pt = sortedPoints[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        pt.monthLabel,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        '${pt.billCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        _formatCurrency(pt.totalSales),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: pt.totalSales > 0 ? FontWeight.bold : FontWeight.normal,
                          color: pt.totalSales > 0 ? AppColors.textPrimary : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Total Summary Row
          Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
              border: Border(top: BorderSide(color: AppColors.borderMedium, width: 1.5)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Expanded(flex: 4, child: Text('TOTAL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                Expanded(flex: 3, child: Text('$totalBills', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                Expanded(flex: 4, child: Text(_formatCurrency(totalSales), textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bar_chart_outlined, size: 32, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Text(
            'No sales recorded in this period',
            style: AppTypography.headlineMd.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different date range or record a new sale in billing.',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BarDataPoint {
  final String label;
  final double value;
  final int count;

  const _BarDataPoint({
    required this.label,
    required this.value,
    required this.count,
  });
}
