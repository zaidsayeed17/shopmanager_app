import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/providers.dart';
import '../customers_placeholder_data.dart';
import '../widgets/bills_tab_view.dart';
import '../widgets/customer_detail_header_card.dart';
import '../widgets/ledger_tab_view.dart';
import '../widgets/outstanding_balance_card.dart';
import '../widgets/payments_tab_view.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  final String customerId;

  const CustomerDetailScreen({
    super.key,
    required this.customerId,
  });

  @override
  ConsumerState<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final numericId = int.tryParse(widget.customerId) ?? 1;
    final customerAsync = ref.watch(customerByIdProvider(numericId));
    final summaryAsync = ref.watch(customerFinancialSummaryProvider(numericId));
    final ledgerAsync = ref.watch(customerLedgerEntriesProvider(numericId));
    final billsAsync = ref.watch(customerBillsProvider(numericId));
    final paymentsAsync = ref.watch(customerPaymentsProvider(numericId));

    return customerAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Customer Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/customers'),
          ),
        ),
        body: Center(
          child: Text('Error loading customer: $err'),
        ),
      ),
      data: (dbCustomer) {
        final customer = dbCustomer ??
            Customer(
              id: numericId,
              name: 'Customer #${widget.customerId}',
              mobile: '0000000000',
            );

        final summary = summaryAsync.value ??
            CustomerFinancialSummary(
              totalBilled: customer.outstandingBalance,
              totalPaid: 0.0,
              outstandingBalance: customer.outstandingBalance,
            );

        final ledgerEntries = ledgerAsync.value ?? [];
        final olderLedgerEntries = <LedgerEntry>[];
        final bills = billsAsync.value ?? [];
        final payments = paymentsAsync.value ?? [];

        return Scaffold(
          appBar: AppBar(
            title: Text(
              customer.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
                  context.go('/customers');
                }
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Customer',
                onPressed: () => context.go('/customers/edit/${customer.id}'),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= 768;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isTablet)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CustomerDetailHeaderCard(customer: customer),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutstandingBalanceCard(
                              customer: customer,
                              summary: summary,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      CustomerDetailHeaderCard(customer: customer),
                      const SizedBox(height: 12),
                      OutstandingBalanceCard(
                        customer: customer,
                        summary: summary,
                      ),
                    ],
                    const SizedBox(height: 20),
                    _buildSegmentedTabControl(bills.length, payments.length),
                    const SizedBox(height: 16),
                    _buildActiveTabView(
                      customer: customer,
                      summary: summary,
                      ledgerEntries: ledgerEntries,
                      olderLedgerEntries: olderLedgerEntries,
                      bills: bills,
                      payments: payments,
                      isTablet: isTablet,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSegmentedTabControl(int billCount, int paymentCount) {
    final tabs = [
      'Ledger',
      'Bills ($billCount)',
      'Payments ($paymentCount)',
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? AppColors.surface
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActiveTabView({
    required Customer customer,
    required CustomerFinancialSummary summary,
    required List<LedgerEntry> ledgerEntries,
    required List<LedgerEntry> olderLedgerEntries,
    required List<CustomerBill> bills,
    required List<CustomerPayment> payments,
    required bool isTablet,
  }) {
    switch (_selectedTabIndex) {
      case 0:
        return LedgerTabView(
          entries: ledgerEntries,
          olderEntries: olderLedgerEntries,
          isTablet: isTablet,
          customer: customer,
          summary: summary,
        );
      case 1:
        return BillsTabView(bills: bills);
      case 2:
        return PaymentsTabView(payments: payments);
      default:
        return const SizedBox.shrink();
    }
  }
}
