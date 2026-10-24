import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';
import '../../data/repositories/providers.dart';
import '../../data/repositories/business_profile_repository.dart';

class NavItem {
  final String title;
  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String subtitle;

  const NavItem({
    required this.title,
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.subtitle,
  });
}

class AppShell extends ConsumerWidget {
  final Widget child;
  final String location;

  const AppShell({
    super.key,
    required this.child,
    required this.location,
  });

  static const List<NavItem> navItems = [
    NavItem(
      title: 'Dashboard',
      route: '/dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      subtitle: 'Overview & production flow',
    ),
    NavItem(
      title: 'Customers',
      route: '/customers',
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      subtitle: 'Client directory & order history',
    ),
    NavItem(
      title: 'Billing',
      route: '/billing',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      subtitle: 'Invoices, payments & balances',
    ),
    NavItem(
      title: 'Stock',
      route: '/stock',
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
      subtitle: 'Raw materials & finished goods',
    ),
    NavItem(
      title: 'Workers',
      route: '/workers',
      icon: Icons.engineering_outlined,
      activeIcon: Icons.engineering,
      subtitle: 'Staff assignments & attendance',
    ),
    NavItem(
      title: 'Products',
      route: '/products',
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront,
      subtitle: 'Selling products & pricing',
    ),
    NavItem(
      title: 'Reports',
      route: '/reports',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
      subtitle: 'Production yields, margins & sales charts',
    ),
    NavItem(
      title: 'Settings',
      route: '/settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      subtitle: 'Workshop tax rates, units & permissions',
    ),
  ];

  NavItem get _currentNavItem {
    return navItems.firstWhere(
      (item) => location.startsWith(item.route),
      orElse: () => navItems.first,
    );
  }

  void _showProfileDialog(BuildContext context, BusinessProfile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                profile.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    profile.hasMobile ? 'Ph: ${profile.mobile}' : AppConstants.shopSubtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (profile.hasAddress) ...[
              Text(
                profile.address,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
            ],
            const Divider(color: AppColors.borderLight),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.badge_outlined, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Role: ${AppConstants.userRole}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.store_outlined, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                const Text(
                  'Status: Active',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final moreItems = navItems.skip(5).toList();

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderMedium,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Header title
                Text(
                  'MORE TOOLS & SETTINGS',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 8),

                for (final item in moreItems) ...[
                  _buildBottomSheetRow(
                    context,
                    item: item,
                    isActive: location.startsWith(item.route),
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 4),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetRow(
    BuildContext context, {
    required NavItem item,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        context.go(item.route);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.activePillBg : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.activePillBorder : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.borderLight,
                ),
              ),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                color: isActive ? Colors.white : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isActive ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(businessProfileProvider);
    final profile = profileAsync.value ?? const BusinessProfile(name: AppConstants.shopName, mobile: '', address: '');

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= AppConstants.tabletBreakpoint;

        if (isTablet) {
          return _buildTabletLayout(context, profile);
        } else {
          return _buildMobileLayout(context, profile);
        }
      },
    );
  }

  // Mobile Layout: Top App Bar + Child + 6-item Bottom Navigation Bar
  Widget _buildMobileLayout(BuildContext context, BusinessProfile profile) {
    final activeItem = _currentNavItem;
    final isMoreActive = navItems.skip(5).any((item) => location.startsWith(item.route));

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.borderLight, width: 1),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Title & Subtitle Badge
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.storefront,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                activeItem.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.headlineLgMobile.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.activePillBg,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  profile.name.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Business Profile Button
                  InkWell(
                    onTap: () => _showProfileDialog(context, profile),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderLight),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              profile.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: child,
      bottomNavigationBar: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.borderLight, width: 1),
          ),
        ),
        child: Row(
          children: [
            // First 5 primary nav items
            for (int i = 0; i < 5; i++)
              Expanded(
                child: _buildMobileNavItem(
                  context,
                  item: navItems[i],
                  isActive: location.startsWith(navItems[i].route),
                ),
              ),
            // 6th "More" item
            Expanded(
              child: _buildMobileMoreItem(
                context,
                isActive: isMoreActive,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileNavItem(
    BuildContext context, {
    required NavItem item,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () => context.go(item.route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              color: isActive ? AppColors.activePillBg : Colors.transparent,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Icon(
              isActive ? item.activeIcon : item.icon,
              size: 20,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileMoreItem(
    BuildContext context, {
    required bool isActive,
  }) {
    return InkWell(
      onTap: () => _showMoreBottomSheet(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              color: isActive ? AppColors.activePillBg : Colors.transparent,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Icon(
              isActive ? Icons.widgets : Icons.widgets_outlined,
              size: 20,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'More',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Tablet Layout: Persistent Left Navigation Rail (92px) + Top App Bar + Child
  Widget _buildTabletLayout(BuildContext context, BusinessProfile profile) {
    final activeItem = _currentNavItem;

    return Scaffold(
      body: Row(
        children: [
          // Left Vertical Navigation Rail (92px wide)
          Container(
            width: 92,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                right: BorderSide(color: AppColors.borderLight, width: 1),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Brand Header
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.storefront,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'ShopMgr',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 8),

                // All 7 Navigation Items
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: navItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final item = navItems[index];
                      final isActive = location.startsWith(item.route);
                      return _buildTabletNavItem(
                        context,
                        item: item,
                        isActive: isActive,
                      );
                    },
                  ),
                ),

                // Bottom Version Pill
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: const Text(
                    'v1.0.0',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Viewport Area
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      bottom: BorderSide(color: AppColors.borderLight, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Active Section Title & Description
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              activeItem.title,
                              style: AppTypography.headlineLg.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: Text(
                                  activeItem.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // User & Business Profile Action
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                profile.name,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Logged in as ${AppConstants.userRole}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _showProfileDialog(context, profile),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                border: Border.all(color: AppColors.borderLight),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      profile.initials,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Child Screen Content
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletNavItem(
    BuildContext context, {
    required NavItem item,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () => context.go(item.route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: isActive ? AppColors.activePillBg : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(color: AppColors.activePillBorder.withValues(alpha: 0.7))
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Active left indicator bar
            if (isActive)
              Positioned(
                left: 0,
                top: 12,
                bottom: 12,
                child: Container(
                  width: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
                  ),
                ),
              ),

            // Icon & Label
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isActive ? item.activeIcon : item.icon,
                  size: 20,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    color: isActive ? AppColors.primary : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
