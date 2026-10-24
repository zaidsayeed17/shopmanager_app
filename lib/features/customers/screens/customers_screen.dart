import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/repositories/providers.dart';

enum CustomerFilter { all, withBalance, cleared }

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();

  CustomerFilter _selectedFilter = CustomerFilter.all;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Customer> _getFilteredCustomers(List<Customer> allCustomers) {
    return allCustomers.where((customer) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = customer.name.toLowerCase().contains(query);
        final matchesMobile = customer.mobile.contains(query);
        if (!matchesName && !matchesMobile) {
          return false;
        }
      }

      switch (_selectedFilter) {
        case CustomerFilter.all:
          return true;
        case CustomerFilter.withBalance:
          return customer.outstandingBalance > 0;
        case CustomerFilter.cleared:
          return customer.outstandingBalance == 0;
      }
    }).toList();
  }

  double _getTotalDue(List<Customer> customers) {
    return customers.fold(0.0, (sum, c) => sum + c.outstandingBalance);
  }

  int _getCountWithBalance(List<Customer> customers) {
    return customers.where((c) => c.outstandingBalance > 0).length;
  }

  int _getCountCleared(List<Customer> customers) {
    return customers.where((c) => c.outstandingBalance == 0).length;
  }

  Color _getAvatarBg(int index) {
    const colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.info,
      AppColors.tertiary,
    ];
    return colors[index % colors.length];
  }

  Color _getBalanceColor(double balance) {
    if (balance == 0) {
      return AppColors.success;
    } else if (balance >= 20000) {
      return AppColors.critical;
    } else {
      return AppColors.tertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersStreamProvider);

    return Scaffold(
      body: customersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error loading customers: $err',
              style: const TextStyle(color: AppColors.critical),
            ),
          ),
        ),
        data: (allCustomers) {
          final filtered = _getFilteredCustomers(allCustomers);
          final isListEmpty = allCustomers.isEmpty;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= AppConstants.tabletBreakpoint;
              final padding = isTablet ? 24.0 : 16.0;

              if (isListEmpty) {
                return _buildEmptyState(context);
              }

              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(padding, padding, padding, 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar & Add Button Row for Tablet
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val.trim();
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search by name or mobile number',
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
                                  fillColor: AppColors.surface,
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
                            ),
                            if (isTablet) ...[
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: () => context.go('/customers/add'),
                                icon: const Icon(Icons.person_add, size: 18),
                                label: const Text('+ Add Customer'),
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
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Total Due Summary Banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(15, 23, 42, 0.08),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TOTAL OUTSTANDING BALANCE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: Color(0xFF99EFE5),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹ ${_getTotalDue(allCustomers).toStringAsFixed(0)}',
                                style: AppTypography.displayLg.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isTablet ? 32 : 26,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_getCountWithBalance(allCustomers)} customers with pending dues • ${_getCountCleared(allCustomers)} cleared accounts',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFE0F2FE),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Filter Chips Row
                        Row(
                          children: [
                            _buildFilterChip('All (${allCustomers.length})', CustomerFilter.all),
                            const SizedBox(width: 8),
                            _buildFilterChip('With Balance (${_getCountWithBalance(allCustomers)})', CustomerFilter.withBalance),
                            const SizedBox(width: 8),
                            _buildFilterChip('Cleared (${_getCountCleared(allCustomers)})', CustomerFilter.cleared),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // List Header
                        Text(
                          'CUSTOMER LEDGER',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Customer List or Table
                        if (filtered.isEmpty)
                          _buildNoResultsState()
                        else if (isTablet)
                          _buildTabletTable(filtered)
                        else
                          _buildMobileList(filtered),
                      ],
                    ),
                  ),

                  // Floating Action Button for Mobile
                  if (!isTablet)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton.extended(
                        onPressed: () => context.go('/customers/add'),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        icon: const Icon(Icons.person_add),
                        label: const Text('Add Customer'),
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

  Widget _buildFilterChip(String label, CustomerFilter filter) {
    final isSelected = _selectedFilter == filter;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      selectedColor: AppColors.activePillBg,
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.borderLight,
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

  Widget _buildMobileList(List<Customer> customers) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: customers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final customer = customers[index];
        final avatarBg = _getAvatarBg(index);
        final balanceColor = _getBalanceColor(customer.outstandingBalance);

        return Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.borderLight),
          ),
          child: InkWell(
            onTap: () => context.go('/customers/${customer.id}'),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: avatarBg,
                    child: Text(
                      customer.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                customer.name,
                                style: AppTypography.labelLg.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                             if (customer.isWholesale) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.infoBg,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Wholesale',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.info,
                                  ),
                                ),
                              ),
                            ],
                            if (!customer.isActive) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Inactive',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '+91 ${customer.mobile}',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹ ${customer.outstandingBalance.toStringAsFixed(0)}',
                        style: AppTypography.labelLg.copyWith(
                          fontWeight: FontWeight.bold,
                          color: balanceColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        customer.outstandingBalance > 0 ? 'Due' : 'Cleared',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: customer.outstandingBalance > 0
                              ? AppColors.tertiary
                              : AppColors.success,
                        ),
                      ),
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

  Widget _buildTabletTable(List<Customer> customers) {
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
                Expanded(flex: 3, child: Text('CUSTOMER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('MOBILE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('OUTSTANDING', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Center(child: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)))),
                SizedBox(width: 48),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: customers.length,
            separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderLight),
            itemBuilder: (context, index) {
              final customer = customers[index];
              final avatarBg = _getAvatarBg(index);
              final balanceColor = _getBalanceColor(customer.outstandingBalance);

              return InkWell(
                onTap: () => context.go('/customers/${customer.id}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: avatarBg,
                              child: Text(
                                customer.initials,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                customer.name,
                                style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '+91 ${customer.mobile}',
                          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹ ${customer.outstandingBalance.toStringAsFixed(0)}',
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.bold,
                            color: balanceColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: customer.isActive ? AppColors.successBg : AppColors.background,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              customer.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: customer.isActive ? AppColors.success : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => context.go('/customers/edit/${customer.id}'),
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
                Icons.people_outline,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No customers yet',
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create your first customer profile to track ledger balances and dispatch invoices.',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/customers/add'),
              icon: const Icon(Icons.person_add),
              label: const Text('+ Add First Customer'),
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
            'No customers match "$_searchQuery"',
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
