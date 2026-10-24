import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/bill_model.dart';
import '../../../data/repositories/providers.dart';

enum BillFilter { all, unpaid, partial, paid }

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  final TextEditingController _searchController = TextEditingController();
  BillFilter _selectedFilter = BillFilter.all;
  String _searchQuery = '';

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

  List<BillModel> _getFilteredBills(List<BillModel> allBills) {
    return allBills.where((bill) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesNum = bill.billNumber.toLowerCase().contains(query);
        final matchesCust = bill.customerName.toLowerCase().contains(query);
        if (!matchesNum && !matchesCust) {
          return false;
        }
      }

      switch (_selectedFilter) {
        case BillFilter.all:
          return true;
        case BillFilter.unpaid:
          return bill.paymentStatus == BillPaymentStatus.unpaid;
        case BillFilter.partial:
          return bill.paymentStatus == BillPaymentStatus.partial;
        case BillFilter.paid:
          return bill.paymentStatus == BillPaymentStatus.paid;
      }
    }).toList();
  }

  int _getCountByStatus(List<BillModel> bills, BillPaymentStatus status) {
    return bills.where((b) => b.paymentStatus == status).length;
  }

  @override
  Widget build(BuildContext context) {
    final billsAsync = ref.watch(billsStreamProvider);

    return Scaffold(
      body: billsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error loading bills: $err',
              style: const TextStyle(color: AppColors.critical),
            ),
          ),
        ),
        data: (allBills) {
          final filtered = _getFilteredBills(allBills);
          final isListEmpty = allBills.isEmpty;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= AppConstants.tabletBreakpoint;
              final padding = isTablet ? 24.0 : 16.0;

              if (isListEmpty) {
                return _buildEmptyState(context);
              }

              final unpaidCount = _getCountByStatus(allBills, BillPaymentStatus.unpaid);
              final partialCount = _getCountByStatus(allBills, BillPaymentStatus.partial);
              final paidCount = _getCountByStatus(allBills, BillPaymentStatus.paid);

              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(padding, padding, padding, isTablet ? 24 : 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header for Tablet View
                        if (isTablet) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Billing',
                                    style: AppTypography.headlineMd.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'LEDGER OVERVIEW',
                                    style: AppTypography.labelSm.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () => context.go('/billing/new'),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('+ New Bill'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Quick Sale Banner Block
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.amberHeaderBg,
                                AppColors.amberHeaderBg.withValues(alpha: 0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade300),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade700,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.flash_on, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Quick Sale / Direct Counter',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'Fast selling for walk-in or registered customers',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.black.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: () => context.push('/quick-sale/history'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.black87,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    ),
                                    child: const Text('History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                  const SizedBox(width: 4),
                                  ElevatedButton.icon(
                                    onPressed: () => context.push('/quick-sale/new'),
                                    icon: const Icon(Icons.flash_on, size: 14),
                                    label: const Text('Quick Sale', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black87,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Search Bar & Filter Controls Container
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: _searchController,
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val.trim();
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search by bill number or customer name',
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
                              const SizedBox(height: 12),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildFilterChip('All (${allBills.length})', BillFilter.all),
                                    const SizedBox(width: 8),
                                    _buildFilterChip('Unpaid ($unpaidCount)', BillFilter.unpaid, AppColors.critical),
                                    const SizedBox(width: 8),
                                    _buildFilterChip('Partial ($partialCount)', BillFilter.partial, AppColors.warning),
                                    const SizedBox(width: 8),
                                    _buildFilterChip('Paid ($paidCount)', BillFilter.paid, AppColors.success),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Bill List Header
                        Text(
                          'INVOICE RECORDS',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Bill List or Table View
                        if (filtered.isEmpty)
                          _buildNoResultsState()
                        else if (isTablet)
                          _buildTabletTable(filtered)
                        else
                          _buildMobileList(filtered),
                      ],
                    ),
                  ),

                  // Floating Action Button for Mobile ONLY
                  if (!isTablet)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton.extended(
                        onPressed: () => context.go('/billing/new'),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        icon: const Icon(Icons.add),
                        label: const Text('+ New Bill'),
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

  Widget _buildFilterChip(String label, BillFilter filter, [Color? activeTextColor]) {
    final isSelected = _selectedFilter == filter;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected
            ? (activeTextColor ?? AppColors.primary)
            : AppColors.textSecondary,
      ),
      selectedColor: activeTextColor != null
          ? activeTextColor.withValues(alpha: 0.12)
          : AppColors.activePillBg,
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: isSelected ? (activeTextColor ?? AppColors.primary) : AppColors.borderLight,
        width: isSelected ? 1.5 : 1.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9999),
      ),
      onSelected: (_) {
        setState(() {
          _selectedFilter = filter;
        });
      },
    );
  }

  Widget _buildStatusBadge(BillPaymentStatus status) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case BillPaymentStatus.paid:
        bg = AppColors.successBg;
        fg = AppColors.success;
        text = 'Paid';
        break;
      case BillPaymentStatus.partial:
        bg = AppColors.warningBg;
        fg = AppColors.warning;
        text = 'Partial';
        break;
      case BillPaymentStatus.voided:
        bg = AppColors.criticalBg;
        fg = AppColors.critical;
        text = 'Voided';
        break;
      case BillPaymentStatus.unpaid:
        bg = AppColors.criticalBg;
        fg = AppColors.critical;
        text = 'Unpaid';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildMobileList(List<BillModel> bills) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bills.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final bill = bills[index];

        return Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.borderLight),
          ),
          child: InkWell(
            onTap: () => context.go('/billing/${bill.id}'),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.billNumber,
                          style: AppTypography.labelLg.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          bill.customerName,
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(bill.billDate),
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 11,
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
                        _formatCurrency(bill.grandTotal),
                        style: AppTypography.labelLg.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusBadge(bill.paymentStatus),
                    ],
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabletTable(List<BillModel> bills) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('BILL #', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 3, child: Text('CUSTOMER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('AMOUNT', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Center(child: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)))),
                SizedBox(width: 36),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bills.length,
            separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderLight),
            itemBuilder: (context, index) {
              final bill = bills[index];

              return InkWell(
                onTap: () => context.go('/billing/${bill.id}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          bill.billNumber,
                          style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          bill.customerName,
                          style: AppTypography.bodyMd,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _formatDate(bill.billDate),
                          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _formatCurrency(bill.grandTotal),
                          textAlign: TextAlign.right,
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: _buildStatusBadge(bill.paymentStatus),
                        ),
                      ),
                      const SizedBox(
                        width: 36,
                        child: Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No bills yet — create your first bill',
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Record sales, track customer balances, and receive payments.',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/billing/new'),
              icon: const Icon(Icons.add),
              label: const Text('+ New Bill'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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

  Widget _buildNoResultsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 36, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(
            'No bills match "$_searchQuery"',
            style: AppTypography.bodyLg.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
