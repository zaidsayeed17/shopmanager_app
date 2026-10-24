import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/worker_model.dart';
import '../../../data/repositories/providers.dart';

enum WorkerStatusFilter { all, active, inactive }

class WorkersScreen extends ConsumerStatefulWidget {
  const WorkersScreen({super.key});

  @override
  ConsumerState<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends ConsumerState<WorkersScreen> {
  final TextEditingController _searchController = TextEditingController();

  WorkerStatusFilter _selectedFilter = WorkerStatusFilter.all;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WorkerModel> _getFilteredAndSortedWorkers(List<WorkerModel> allWorkers) {
    var filtered = allWorkers.where((worker) {
      // 1. Search Query Filter (name, mobile, workType)
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = worker.name.toLowerCase().contains(query);
        final matchesMobile = worker.mobile?.contains(query) ?? false;
        final matchesWorkType = worker.workType?.toLowerCase().contains(query) ?? false;
        if (!matchesName && !matchesMobile && !matchesWorkType) {
          return false;
        }
      }

      // 2. Status Filter
      switch (_selectedFilter) {
        case WorkerStatusFilter.all:
          return true;
        case WorkerStatusFilter.active:
          return worker.isActive;
        case WorkerStatusFilter.inactive:
          return !worker.isActive;
      }
    }).toList();

    // Alphabetically sorted by name
    filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return filtered;
  }

  int _getActiveCount(List<WorkerModel> workers) => workers.where((w) => w.isActive).length;
  int _getInactiveCount(List<WorkerModel> workers) => workers.where((w) => !w.isActive).length;

  Color _getAvatarBg(int index) {
    const colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.info,
      AppColors.tertiary,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final workersAsync = ref.watch(workersStreamProvider);

    return Scaffold(
      body: workersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error loading workers: $err',
              style: const TextStyle(color: AppColors.critical),
            ),
          ),
        ),
        data: (allWorkers) {
          final isListEmpty = allWorkers.isEmpty;
          final filteredWorkers = _getFilteredAndSortedWorkers(allWorkers);

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
                                  contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                onPressed: () => context.go('/workers/add'),
                                icon: const Icon(Icons.person_add, size: 18),
                                label: const Text('+ Add Worker'),
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

                        // Heading and Filter Chips
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isTablet
                                  ? 'WORKER ROSTER (${allWorkers.length} total)'
                                  : 'WORKERS (${allWorkers.length})',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Row(
                              children: [
                                _buildFilterChip('All (${allWorkers.length})', WorkerStatusFilter.all),
                                const SizedBox(width: 6),
                                _buildFilterChip('Active (${_getActiveCount(allWorkers)})', WorkerStatusFilter.active),
                                const SizedBox(width: 6),
                                _buildFilterChip('Inactive (${_getInactiveCount(allWorkers)})', WorkerStatusFilter.inactive),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // List Content or Table
                        if (filteredWorkers.isEmpty)
                          _buildNoResultsState()
                        else if (isTablet)
                          _buildTabletTable(filteredWorkers)
                        else
                          _buildMobileList(filteredWorkers),
                      ],
                    ),
                  ),

                  // Mobile FAB
                  if (!isTablet)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton.extended(
                        onPressed: () => context.go('/workers/add'),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        icon: const Icon(Icons.person_add),
                        label: const Text('Add Worker'),
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

  Widget _buildFilterChip(String label, WorkerStatusFilter filter) {
    final isSelected = _selectedFilter == filter;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 11,
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

  Widget _buildMobileList(List<WorkerModel> workers) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: workers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final worker = workers[index];
        final avatarBg = _getAvatarBg(index);

        return Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.borderLight),
          ),
          child: InkWell(
            onTap: () => context.go('/workers/${worker.id}'),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: avatarBg,
                    child: Text(
                      worker.initials,
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
                        Text(
                          worker.name,
                          style: AppTypography.labelLg.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (worker.workType != null && worker.workType!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Work type: ${worker.workType}',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 12, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              worker.mobile != null && worker.mobile!.isNotEmpty
                                  ? '+91 ${worker.mobile}'
                                  : 'No mobile',
                              style: TextStyle(
                                fontSize: 11,
                                color: worker.mobile != null && worker.mobile!.isNotEmpty
                                    ? AppColors.textSecondary
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Pending pill or inactive badge
                  _buildPendingPill(worker),

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

  Widget _buildTabletTable(List<WorkerModel> workers) {
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
                Expanded(flex: 3, child: Text('NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('WORK TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('MOBILE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('PENDING MATERIAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Center(child: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)))),
                SizedBox(width: 48, child: Center(child: Text('ACTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)))),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: workers.length,
            separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderLight),
            itemBuilder: (context, index) {
              final worker = workers[index];
              final avatarBg = _getAvatarBg(index);

              return InkWell(
                onTap: () => context.go('/workers/${worker.id}'),
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
                                worker.initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                worker.name,
                                style: AppTypography.bodyMd.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
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
                          worker.workType ?? '—',
                          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          worker.mobile != null && worker.mobile!.isNotEmpty
                              ? '+91 ${worker.mobile}'
                              : '—',
                          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildPendingPill(worker),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: worker.isActive ? AppColors.successBg : AppColors.background,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              worker.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: worker.isActive ? AppColors.success : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        child: IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          tooltip: 'Edit Worker',
                          onPressed: () => context.go('/workers/edit/${worker.id}'),
                        ),
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

  Widget _buildPendingPill(WorkerModel worker) {
    if (!worker.isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: const Text(
          'Inactive',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    final pending = worker.pendingItemCount;
    if (pending > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.warningBg,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          '$pending item${pending == 1 ? '' : 's'} pending',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.tertiary,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: const Text(
        'Nothing pending',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppColors.textMuted,
        ),
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
                Icons.badge_outlined,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No workers yet',
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add the workers who process your raw material.',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/workers/add'),
              icon: const Icon(Icons.person_add),
              label: const Text('+ Add Your First Worker'),
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
            'No workers match your search',
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
