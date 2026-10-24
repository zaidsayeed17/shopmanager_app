import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/providers.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/recent_bills_card.dart';
import '../widgets/stock_overview_widget.dart';
import '../widgets/todays_snapshot_grid.dart';
import '../widgets/worker_status_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final freshInstallAsync = ref.watch(isFreshInstallProvider);
    final isEmptyState = freshInstallAsync.value ?? false;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= AppConstants.tabletBreakpoint;

          if (isTablet) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardHeader(isEmptyState: isEmptyState),
                  const SizedBox(height: 20),
                  TodaysSnapshotGrid(isTablet: true, isEmptyState: isEmptyState),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: StockOverviewWidget(isEmptyState: isEmptyState),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: WorkerStatusCard(isEmptyState: isEmptyState),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  RecentBillsCard(isEmptyState: isEmptyState),
                ],
              ),
            );
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardHeader(isEmptyState: isEmptyState),
                  const SizedBox(height: 16),
                  TodaysSnapshotGrid(isTablet: false, isEmptyState: isEmptyState),
                  const SizedBox(height: 16),
                  StockOverviewWidget(isEmptyState: isEmptyState),
                  const SizedBox(height: 16),
                  WorkerStatusCard(isEmptyState: isEmptyState),
                  const SizedBox(height: 16),
                  RecentBillsCard(isEmptyState: isEmptyState),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
