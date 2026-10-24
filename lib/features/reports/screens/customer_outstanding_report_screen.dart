import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/billing_repository.dart';
import '../../../data/repositories/providers.dart';

class CustomerOutstandingReportScreen extends ConsumerStatefulWidget {
  const CustomerOutstandingReportScreen({super.key});

  @override
  ConsumerState<CustomerOutstandingReportScreen> createState() => _CustomerOutstandingReportScreenState();
}

class _CustomerOutstandingReportScreenState extends ConsumerState<CustomerOutstandingReportScreen> {
  bool _highestFirst = true;

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  String _formatDateShort(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _getOutstandingColor(double amount) {
    if (amount >= 10000) {
      return AppColors.critical;
    } else {
      return AppColors.tertiary; // Amber for moderate dues
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(customerOutstandingReportProvider(_highestFirst));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Outstanding Report'),
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
                    // Summary Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Outstanding',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatCurrency(data.totalOutstanding),
                                  style: AppTypography.headlineLg.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: data.totalOutstanding > 0 ? AppColors.critical : AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${data.customerCount}',
                                  style: AppTypography.headlineMd.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Customers',
                                  style: AppTypography.bodySm.copyWith(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (data.customerCount == 0)
                      _buildEmptyState()
                    else ...[
                      // Sort Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'CUSTOMER DUES (${data.customerCount})',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Row(
                            children: [
                              const Text(
                                'Sort: ',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              ChoiceChip(
                                label: const Text('Highest First'),
                                selected: _highestFirst,
                                onSelected: (val) {
                                  if (val) setState(() => _highestFirst = true);
                                },
                                selectedColor: AppColors.primary,
                                backgroundColor: AppColors.surface,
                                labelStyle: TextStyle(
                                  fontSize: 11,
                                  color: _highestFirst ? Colors.white : AppColors.textPrimary,
                                  fontWeight: _highestFirst ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(width: 6),
                              ChoiceChip(
                                label: const Text('Oldest Bill First'),
                                selected: !_highestFirst,
                                onSelected: (val) {
                                  if (val) setState(() => _highestFirst = false);
                                },
                                selectedColor: AppColors.primary,
                                backgroundColor: AppColors.surface,
                                labelStyle: TextStyle(
                                  fontSize: 11,
                                  color: !_highestFirst ? Colors.white : AppColors.textPrimary,
                                  fontWeight: !_highestFirst ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Dues List / Grid
                      if (isTablet)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: constraints.maxWidth >= 1000 ? 3 : 2,
                            mainAxisExtent: 96,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: data.items.length,
                          itemBuilder: (context, index) {
                            final item = data.items[index];
                            return _buildCustomerTile(item);
                          },
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: data.items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = data.items[index];
                            return _buildCustomerTile(item);
                          },
                        ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCustomerTile(CustomerOutstandingItem item) {
    final textColor = _getOutstandingColor(item.outstanding);
    final lastBilledStr = item.lastBilledDate != null
        ? 'Last billed: ${_formatDateShort(item.lastBilledDate!)}'
        : 'No bills recorded';

    return InkWell(
      onTap: () => context.push('/customers/${item.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.name,
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.mobile} • $lastBilledStr',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatCurrency(item.outstanding),
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
          ],
        ),
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
              color: AppColors.successBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline, size: 36, color: AppColors.success),
          ),
          const SizedBox(height: 16),
          Text(
            'No outstanding balances — all customers are settled up!',
            style: AppTypography.headlineMd.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Every customer account has zero dues recorded.',
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
