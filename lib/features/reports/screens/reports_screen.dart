import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class _ReportItem {
  final String title;
  final String description;
  final IconData icon;
  final String route;

  const _ReportItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
  });
}

class _ReportSection {
  final String title;
  final List<_ReportItem> items;

  const _ReportSection({
    required this.title,
    required this.items,
  });
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static final List<_ReportSection> _allSections = [
    _ReportSection(
      title: 'Sales & Payments',
      items: [
        _ReportItem(
          title: 'Daily Sales Report',
          description: 'Track gross sales, bill counts & averages by day',
          icon: Icons.today_outlined,
          route: '/reports/sales?tab=daily',
        ),
        _ReportItem(
          title: 'Monthly Sales Report',
          description: 'Track gross sales & bill counts grouped by month',
          icon: Icons.calendar_month_outlined,
          route: '/reports/sales?tab=monthly',
        ),
        _ReportItem(
          title: 'Payment Report',
          description: 'Summary of cash, UPI & payment collections',
          icon: Icons.payments_outlined,
          route: '/reports/payments',
        ),
        _ReportItem(
          title: 'Customer Outstanding Report',
          description: 'Customer ledger dues & pending balances',
          icon: Icons.account_balance_wallet_outlined,
          route: '/reports/customer-outstanding',
        ),
      ],
    ),
    _ReportSection(
      title: 'Stock',
      items: [
        _ReportItem(
          title: 'Stock Report',
          description: 'Current raw material & finished product inventory',
          icon: Icons.inventory_2_outlined,
          route: '/reports/stock',
        ),
        _ReportItem(
          title: 'Stock Movement Report',
          description: 'Stock purchases, issuances & adjustments log',
          icon: Icons.swap_vert_outlined,
          route: '/reports/stock-movement',
        ),
        _ReportItem(
          title: 'Low Stock Report',
          description: 'Items at or below minimum reorder thresholds',
          icon: Icons.warning_amber_outlined,
          route: '/reports/low-stock',
        ),
      ],
    ),
    _ReportSection(
      title: 'Workers',
      items: [
        _ReportItem(
          title: 'Worker Material Report',
          description: 'Raw material issued to workers & pending stock',
          icon: Icons.assignment_outlined,
          route: '/reports/worker-material',
        ),
        _ReportItem(
          title: 'Worker Production Report',
          description: 'Finished product output & batch logs by worker',
          icon: Icons.precision_manufacturing_outlined,
          route: '/reports/worker-production',
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();

    // Filter sections and items client-side
    final filteredSections = _allSections.map((sec) {
      final matchingItems = sec.items.where((item) {
        if (query.isEmpty) return true;
        return item.title.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query);
      }).toList();
      return _ReportSection(title: sec.title, items: matchingItems);
    }).where((sec) => sec.items.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reports',
          style: AppTypography.headlineMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
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
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search reports',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                if (filteredSections.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            'No reports found matching "$_searchQuery"',
                            style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...filteredSections.map((section) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10, top: 8),
                          child: Text(
                            section.title.toUpperCase(),
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        if (isTablet)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: constraints.maxWidth >= 1000 ? 3 : 2,
                              mainAxisExtent: 94,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: section.items.length,
                            itemBuilder: (context, index) {
                              final item = section.items[index];
                              return _buildReportCard(item);
                            },
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: section.items.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = section.items[index];
                              return _buildReportCard(item);
                            },
                          ),
                        const SizedBox(height: 24),
                      ],
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportCard(_ReportItem item) {
    return InkWell(
      onTap: () => context.push(item.route),
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
