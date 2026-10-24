import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/bill_model.dart';
import '../../../data/repositories/providers.dart';

enum QuickSaleStatusFilter { all, paid, partial, unpaid }

class QuickSaleHistoryScreen extends ConsumerStatefulWidget {
  const QuickSaleHistoryScreen({super.key});

  @override
  ConsumerState<QuickSaleHistoryScreen> createState() => _QuickSaleHistoryScreenState();
}

class _QuickSaleHistoryScreenState extends ConsumerState<QuickSaleHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  QuickSaleStatusFilter _selectedFilter = QuickSaleStatusFilter.all;
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')} ${_months[dt.month - 1]} ${dt.year}';
  }

  String _formatCurrency(double amount) {
    if (amount % 1 == 0) {
      return '₹${amount.toInt().toString().replaceAllMapped(
        RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))'),
        (m) => '${m[1]},',
      )}';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }

  List<BillModel> _getFilteredSales(List<BillModel> sales) {
    return sales.where((sale) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesNum = sale.billNumber.toLowerCase().contains(query);
        final matchesCust = sale.customerName.toLowerCase().contains(query);
        if (!matchesNum && !matchesCust) {
          return false;
        }
      }

      if (_selectedDateRange != null) {
        final start = DateTime(
          _selectedDateRange!.start.year,
          _selectedDateRange!.start.month,
          _selectedDateRange!.start.day,
        );
        final end = DateTime(
          _selectedDateRange!.end.year,
          _selectedDateRange!.end.month,
          _selectedDateRange!.end.day,
          23,
          59,
          59,
        );
        if (sale.billDate.isBefore(start) || sale.billDate.isAfter(end)) {
          return false;
        }
      }

      switch (_selectedFilter) {
        case QuickSaleStatusFilter.all:
          return true;
        case QuickSaleStatusFilter.paid:
          return sale.paymentStatus == BillPaymentStatus.paid;
        case QuickSaleStatusFilter.partial:
          return sale.paymentStatus == BillPaymentStatus.partial;
        case QuickSaleStatusFilter.unpaid:
          return sale.paymentStatus == BillPaymentStatus.unpaid;
      }
    }).toList();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _selectedDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final params = QuickSalesQueryParams(
      from: _selectedDateRange?.start,
      to: _selectedDateRange?.end,
    );
    final salesAsync = ref.watch(quickSalesProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Sale History'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () => context.push('/quick-sale/new'),
              icon: const Icon(Icons.flash_on, size: 16),
              label: const Text('New Sale'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amberHeaderBg,
                foregroundColor: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: salesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error loading quick sales: $err',
              style: const TextStyle(color: AppColors.critical),
            ),
          ),
        ),
        data: (allSales) {
          final filtered = _getFilteredSales(allSales);
          final totalAmount = filtered.fold<double>(0.0, (sum, s) => sum + s.grandTotal);

          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= AppConstants.tabletBreakpoint;
              final padding = isTablet ? 24.0 : 16.0;

              return Column(
                children: [
                  // Top Controls & Summary Card
                  Container(
                    color: AppColors.surface,
                    padding: EdgeInsets.symmetric(horizontal: padding, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats Header Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryBadge(
                                label: 'Total Sales',
                                value: '${filtered.length} entries',
                                icon: Icons.receipt_long,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryBadge(
                                label: 'Total Revenue',
                                value: _formatCurrency(totalAmount),
                                icon: Icons.payments,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Search Bar
                        TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val.trim();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search QS number or customer...',
                            prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.borderLight),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Filter Chips & Date Picker
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ActionChip(
                                avatar: const Icon(Icons.calendar_today, size: 14),
                                label: Text(
                                  _selectedDateRange == null
                                      ? 'All Time'
                                      : '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: _selectedDateRange == null
                                    ? AppColors.background
                                    : AppColors.primary.withValues(alpha: 0.1),
                                side: BorderSide(
                                  color: _selectedDateRange == null
                                      ? AppColors.borderLight
                                      : AppColors.primary,
                                ),
                                onPressed: _pickDateRange,
                              ),
                              if (_selectedDateRange != null) ...[
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedDateRange = null;
                                    });
                                  },
                                  child: const Icon(Icons.cancel, size: 18, color: AppColors.textMuted),
                                ),
                              ],
                              const SizedBox(width: 12),
                              _buildStatusChip('All (${allSales.length})', QuickSaleStatusFilter.all),
                              const SizedBox(width: 6),
                              _buildStatusChip('Paid', QuickSaleStatusFilter.paid, AppColors.success),
                              const SizedBox(width: 6),
                              _buildStatusChip('Partial', QuickSaleStatusFilter.partial, AppColors.warning),
                              const SizedBox(width: 6),
                              _buildStatusChip('Unpaid', QuickSaleStatusFilter.unpaid, AppColors.critical),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: AppColors.borderLight),

                  // Sales List
                  Expanded(
                    child: filtered.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: EdgeInsets.all(padding),
                            itemCount: filtered.length,
                            separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                            itemBuilder: (ctx, index) {
                              final sale = filtered[index];
                              return _buildSaleCard(sale);
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSummaryBadge({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppTypography.labelSm.copyWith(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.titleMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, QuickSaleStatusFilter filter, [Color? color]) {
    final isSelected = _selectedFilter == filter;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? (color ?? AppColors.primary) : AppColors.textSecondary,
      ),
      selectedColor: color != null ? color.withValues(alpha: 0.12) : AppColors.activePillBg,
      backgroundColor: AppColors.background,
      side: BorderSide(
        color: isSelected ? (color ?? AppColors.primary) : AppColors.borderLight,
        width: isSelected ? 1.5 : 1.0,
      ),
      onSelected: (_) {
        setState(() {
          _selectedFilter = filter;
        });
      },
    );
  }

  Widget _buildSaleCard(BillModel sale) {
    Color statusColor;
    String statusText;
    switch (sale.paymentStatus) {
      case BillPaymentStatus.paid:
        statusColor = AppColors.success;
        statusText = 'PAID';
        break;
      case BillPaymentStatus.partial:
        statusColor = AppColors.warning;
        statusText = 'PARTIAL';
        break;
      case BillPaymentStatus.unpaid:
        statusColor = AppColors.critical;
        statusText = 'UNPAID';
        break;
      case BillPaymentStatus.voided:
        statusColor = AppColors.textMuted;
        statusText = 'VOID';
        break;
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: InkWell(
        onTap: () => context.push('/billing/${sale.id}'),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.amberHeaderBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.flash_on, size: 12, color: Colors.black87),
                            const SizedBox(width: 2),
                            Text(
                              sale.billNumber,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(sale.billDate),
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        sale.isWalkIn ? Icons.directions_walk : Icons.person_outline,
                        size: 16,
                        color: sale.isWalkIn ? AppColors.textMuted : AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        sale.customerName,
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatCurrency(sale.grandTotal),
                    style: AppTypography.titleMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.flash_off, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              'No Quick Sales Found',
              style: AppTypography.titleMd.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _selectedFilter != QuickSaleStatusFilter.all
                  ? 'Try clearing your filters or search query.'
                  : 'Start direct counter sales without creating customer accounts.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.push('/quick-sale/new'),
              icon: const Icon(Icons.flash_on, size: 18),
              label: const Text('Create Quick Sale'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
