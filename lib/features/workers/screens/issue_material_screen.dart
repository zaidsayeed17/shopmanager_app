import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/item_model.dart';
import '../../../data/models/worker_model.dart';
import '../../../data/repositories/providers.dart';
import '../../../data/repositories/worker_issue_repository.dart';

class IssueMaterialScreen extends ConsumerStatefulWidget {
  final String workerId;

  const IssueMaterialScreen({
    super.key,
    required this.workerId,
  });

  @override
  ConsumerState<IssueMaterialScreen> createState() => _IssueMaterialScreenState();
}

class _MaterialIssueLineEntry {
  final ItemModel item;
  final TextEditingController controller;
  String? errorText;

  _MaterialIssueLineEntry({
    required this.item,
    required this.controller,
  });
}

class _IssueMaterialScreenState extends ConsumerState<IssueMaterialScreen> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _notesController = TextEditingController();
  final List<_MaterialIssueLineEntry> _lines = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    for (final line in _lines) {
      line.controller.dispose();
    }
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    return isToday ? 'Today, $dateStr' : dateStr;
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addMaterialLine(ItemModel item) {
    final controller = TextEditingController();
    controller.addListener(() {
      setState(() {
        _validateLines(showErrors: false);
      });
    });
    setState(() {
      _lines.add(_MaterialIssueLineEntry(item: item, controller: controller));
    });
  }

  void _removeLine(int index) {
    setState(() {
      _lines[index].controller.dispose();
      _lines.removeAt(index);
      _validateLines(showErrors: false);
    });
  }

  bool _validateLines({bool showErrors = true}) {
    bool allValid = true;
    for (final line in _lines) {
      final valStr = line.controller.text.trim();
      final val = double.tryParse(valStr);
      if (valStr.isEmpty || val == null || val <= 0) {
        if (showErrors) {
          line.errorText = 'Enter a quantity (must be greater than 0)';
        }
        allValid = false;
      } else {
        line.errorText = null;
      }
    }
    return allValid;
  }

  double get _totalUnitsIssued {
    double total = 0;
    for (final line in _lines) {
      final val = double.tryParse(line.controller.text.trim());
      if (val != null && val > 0) {
        total += val;
      }
    }
    return total;
  }

  int get _warningCount {
    int count = 0;
    for (final line in _lines) {
      final val = double.tryParse(line.controller.text.trim());
      if (val != null && val > line.item.currentQty) {
        count++;
      }
    }
    return count;
  }

  bool get _hasInvalidLine {
    if (_lines.isEmpty) return true;
    for (final line in _lines) {
      final valStr = line.controller.text.trim();
      final val = double.tryParse(valStr);
      if (valStr.isEmpty || val == null || val <= 0) {
        return true;
      }
    }
    return false;
  }

  Future<void> _onSave(WorkerModel worker) async {
    final isValid = _validateLines(showErrors: true);
    if (!isValid || _lines.isEmpty) {
      setState(() {});
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final issueLines = _lines.map((l) {
        final qty = double.parse(l.controller.text.trim());
        return IssueLine(itemId: l.item.id, quantity: qty);
      }).toList();

      final issueRepo = ref.read(workerIssueRepositoryProvider);
      await issueRepo.issueMaterials(
        workerId: worker.id,
        date: _selectedDate,
        lines: issueLines,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      // Refresh providers
      ref.invalidate(workersStreamProvider);
      ref.invalidate(workerByIdProvider(worker.id));
      ref.invalidate(itemsStreamProvider);
      ref.invalidate(activeRawMaterialsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Issued ${_lines.length} material(s) to ${worker.name} successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/workers');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error issuing materials: $e'),
            backgroundColor: AppColors.critical,
          ),
        );
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _openMaterialPicker(List<ItemModel> rawMaterials) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        return _MaterialPickerSheet(
          rawMaterials: rawMaterials,
          alreadySelectedIds: _lines.map((l) => l.item.id).toSet(),
          onSelect: (item) {
            Navigator.pop(ctx);
            _addMaterialLine(item);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final numericId = int.tryParse(widget.workerId) ?? 0;
    final workerAsync = ref.watch(workerByIdProvider(numericId));
    final rawMaterialsAsync = ref.watch(activeRawMaterialsProvider);

    return workerAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Issue Material')),
        body: Center(child: Text('Error: $err')),
      ),
      data: (worker) {
        if (worker == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Issue Material')),
            body: const Center(child: Text('Worker not found')),
          );
        }

        final rawMaterials = rawMaterialsAsync.value ?? [];
        final isTablet = MediaQuery.of(context).size.width >= 600;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Issue Material',
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
                  context.go('/workers');
                }
              },
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Grid / Cards for Worker & Issue Date
                          if (isTablet)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildWorkerCard(worker),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 1,
                                  child: _buildDateCard(),
                                ),
                              ],
                            )
                          else ...[
                            _buildWorkerCard(worker),
                            const SizedBox(height: 16),
                            _buildDateCard(),
                          ],

                          const SizedBox(height: 20),

                          // Materials to Issue Section
                          _buildMaterialsSection(rawMaterials, isTablet),

                          const SizedBox(height: 20),

                          // Notes & Summary Preview Section
                          if (isTablet)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildNotesCard()),
                                const SizedBox(width: 16),
                                Expanded(child: _buildSummaryCard()),
                              ],
                            )
                          else ...[
                            _buildNotesCard(),
                            const SizedBox(height: 16),
                            _buildSummaryCard(),
                          ],

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Sticky Action Bar
              _buildBottomActionBar(worker),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkerCard(WorkerModel worker) {
    final initials = worker.name.isNotEmpty
        ? worker.name.trim().split(' ').map((e) => e[0]).take(2).join('').toUpperCase()
        : 'W';

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: AppTypography.bodyLg.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
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
                      Flexible(
                        child: Text(
                          worker.name,
                          style: AppTypography.bodyLg.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Text(
                          worker.formattedWorkerId,
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${worker.workType ?? 'General Worker'}${worker.mobile != null && worker.mobile!.isNotEmpty ? ' • +91 ${worker.mobile}' : ''}',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Text(
                'WORKER',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateCard() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ISSUE DATE',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.borderMedium),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _formatDate(_selectedDate),
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsSection(List<ItemModel> rawMaterials, bool isTablet) {
    final warningCount = _warningCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Materials to Issue',
                  style: AppTypography.headlineMd.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_lines.isNotEmpty)
                  Text(
                    warningCount > 0
                        ? '$warningCount item(s) exceed available stock'
                        : '${_lines.length} material(s) configured for handover',
                    style: AppTypography.bodySm.copyWith(
                      color: warningCount > 0 ? AppColors.warning : AppColors.textSecondary,
                      fontWeight: warningCount > 0 ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _openMaterialPicker(rawMaterials),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('+ Add Material'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_lines.isEmpty)
          _buildEmptyMaterialsCard(rawMaterials)
        else if (isTablet)
          _buildTabletMaterialsTable()
        else
          _buildMobileMaterialsList(),
      ],
    );
  }

  Widget _buildEmptyMaterialsCard(List<ItemModel> rawMaterials) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.borderMedium,
          style: BorderStyle.solid,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No materials added yet',
            style: AppTypography.bodyLg.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add raw materials (fabric, rib, thread, elastic) to record physical handover to this worker.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _openMaterialPicker(rawMaterials),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('+ Add Material'),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileMaterialsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _lines.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final line = _lines[index];
        final item = line.item;
        final qtyVal = double.tryParse(line.controller.text.trim()) ?? 0;
        final exceedsStock = qtyVal > item.currentQty;
        final hasError = line.errorText != null;

        Color cardBorderColor = AppColors.borderLight;
        Color cardBgColor = AppColors.surface;

        if (hasError) {
          cardBorderColor = AppColors.critical;
          cardBgColor = AppColors.criticalBg.withValues(alpha: 0.2);
        } else if (exceedsStock) {
          cardBorderColor = AppColors.warning;
          cardBgColor = AppColors.warningBg.withValues(alpha: 0.3);
        }

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cardBorderColor, width: (hasError || exceedsStock) ? 1.5 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.name,
                                style: AppTypography.bodyLg.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (item.category != null && item.category!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: Text(
                                  item.category!,
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                            children: [
                              const TextSpan(text: 'Available: '),
                              TextSpan(
                                text: '${item.currentQty} ${item.unit}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: item.currentQty <= 0 ? AppColors.critical : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.textMuted),
                    onPressed: () => _removeLine(index),
                    tooltip: 'Remove material',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.borderLight),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quantity to issue:',
                    style: AppTypography.bodySm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    child: TextField(
                      controller: line.controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.right,
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color: hasError
                            ? AppColors.critical
                            : (exceedsStock ? AppColors.warning : AppColors.textPrimary),
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        suffixIcon: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: const BoxDecoration(
                            color: AppColors.background,
                            border: Border(left: BorderSide(color: AppColors.borderMedium)),
                          ),
                          child: Text(
                            item.unit,
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: hasError
                                ? AppColors.critical
                                : (exceedsStock ? AppColors.warning : AppColors.primary),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Inline Warning / Error message
              if (hasError) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.error_outline, size: 16, color: AppColors.critical),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        line.errorText!,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.critical,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (exceedsStock) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warningBg,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Only ${item.currentQty} ${item.unit} available in system. You can still proceed, but stock will become ${(item.currentQty - qtyVal).toStringAsFixed(1)} ${item.unit}.',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabletMaterialsTable() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.background,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'RAW MATERIAL ITEM',
                    style: AppTypography.labelSm.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'AVAILABLE STOCK',
                    style: AppTypography.labelSm.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: Text(
                    'QUANTITY TO ISSUE',
                    textAlign: TextAlign.right,
                    style: AppTypography.labelSm.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 50),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _lines.length,
            separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderLight),
            itemBuilder: (context, index) {
              final line = _lines[index];
              final item = line.item;
              final qtyVal = double.tryParse(line.controller.text.trim()) ?? 0;
              final exceedsStock = qtyVal > item.currentQty;
              final hasError = line.errorText != null;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (item.category != null && item.category!.isNotEmpty)
                            Text(
                              item.category!,
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          if (hasError)
                            Text(
                              line.errorText!,
                              style: AppTypography.bodySm.copyWith(color: AppColors.critical),
                            )
                          else if (exceedsStock)
                            Text(
                              'Warning: Exceeds stock by ${(qtyVal - item.currentQty).toStringAsFixed(1)} ${item.unit}',
                              style: AppTypography.bodySm.copyWith(color: AppColors.warning),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${item.currentQty} ${item.unit}',
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.bold,
                          color: item.currentQty <= 0 ? AppColors.critical : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: TextField(
                        controller: line.controller,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.right,
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.bold,
                          color: hasError
                              ? AppColors.critical
                              : (exceedsStock ? AppColors.warning : AppColors.textPrimary),
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          suffixIcon: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            decoration: const BoxDecoration(
                              color: AppColors.background,
                              border: Border(left: BorderSide(color: AppColors.borderMedium)),
                            ),
                            child: Text(
                              item.unit,
                              style: AppTypography.bodySm.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.textMuted),
                      onPressed: () => _removeLine(index),
                      tooltip: 'Remove material',
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'NOTES ',
                  style: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '(OPTIONAL)',
                  style: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.normal,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: AppTypography.bodyMd,
              decoration: const InputDecoration(
                hintText: 'e.g. For Tracksuit Batch #88, Lot 4...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final hasError = _lines.isNotEmpty && _hasInvalidLine;
    final warningCount = _warningCount;
    final totalUnits = _totalUnitsIssued;

    Color cardBg = AppColors.activePillBg;
    Color cardBorder = AppColors.activePillBorder;
    Color textColor = AppColors.primary;
    IconData iconData = Icons.check_circle_outline;
    String badgeText = 'Ready';
    Color badgeBg = AppColors.successBg;
    Color badgeTextColor = AppColors.success;
    String mainText = '${_lines.length} material(s) • Total ${totalUnits.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} units issued';
    String subText = 'Stock will be deducted immediately upon saving';

    if (_lines.isEmpty) {
      cardBg = AppColors.background;
      cardBorder = AppColors.borderMedium;
      textColor = AppColors.textSecondary;
      iconData = Icons.info_outline;
      badgeText = 'Empty';
      badgeBg = AppColors.background;
      badgeTextColor = AppColors.textMuted;
      mainText = '0 materials • 0 units';
      subText = 'Add materials above to configure handover';
    } else if (hasError) {
      cardBg = AppColors.criticalBg.withValues(alpha: 0.5);
      cardBorder = AppColors.critical;
      textColor = AppColors.critical;
      iconData = Icons.error_outline;
      badgeText = 'Incomplete';
      badgeBg = AppColors.criticalBg;
      badgeTextColor = AppColors.critical;
      mainText = 'Fix missing/invalid quantities to enable saving';
      subText = 'All material lines must have quantity > 0';
    } else if (warningCount > 0) {
      cardBg = AppColors.warningBg.withValues(alpha: 0.6);
      cardBorder = AppColors.warning;
      textColor = AppColors.warning;
      iconData = Icons.warning_amber_rounded;
      badgeText = 'Proceed OK';
      badgeBg = AppColors.warningBg;
      badgeTextColor = AppColors.warning;
      subText = 'Warning: $warningCount material(s) exceed available stock';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: textColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        mainText,
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: badgeTextColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        badgeText,
                        style: AppTypography.labelSm.copyWith(
                          color: badgeTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subText,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(WorkerModel worker) {
    final isDisabled = _isSaving || _lines.isEmpty || _hasInvalidLine;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: _isSaving
                    ? null
                    : () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/workers');
                        }
                      },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: isDisabled ? null : () => _onSave(worker),
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check, size: 18),
                label: Text(_isSaving ? 'Saving...' : 'Save & Issue'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  disabledBackgroundColor: AppColors.borderMedium,
                  disabledForegroundColor: AppColors.textMuted,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialPickerSheet extends StatefulWidget {
  final List<ItemModel> rawMaterials;
  final Set<int> alreadySelectedIds;
  final ValueChanged<ItemModel> onSelect;

  const _MaterialPickerSheet({
    required this.rawMaterials,
    required this.alreadySelectedIds,
    required this.onSelect,
  });

  @override
  State<_MaterialPickerSheet> createState() => _MaterialPickerSheetState();
}

class _MaterialPickerSheetState extends State<_MaterialPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.rawMaterials.where((item) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.trim().toLowerCase();
      final matchName = item.name.toLowerCase().contains(q);
      final matchCat = item.category?.toLowerCase().contains(q) ?? false;
      return matchName || matchCat;
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Raw Material',
                  style: AppTypography.headlineMd.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search raw materials by name or category...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'No raw materials match "$_searchQuery"'
                              : 'No active raw materials found.\nAdd raw materials in the Stock section first.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderLight),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final isAdded = widget.alreadySelectedIds.contains(item.id);

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          title: Text(
                            item.name,
                            style: AppTypography.bodyLg.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isAdded ? AppColors.textMuted : AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            '${item.category ?? 'Uncategorized'} • Available: ${item.currentQty} ${item.unit}',
                            style: AppTypography.bodySm.copyWith(
                              color: isAdded ? AppColors.textMuted : AppColors.textSecondary,
                            ),
                          ),
                          trailing: isAdded
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.borderLight),
                                  ),
                                  child: Text(
                                    'Added',
                                    style: AppTypography.labelSm.copyWith(color: AppColors.textMuted),
                                  ),
                                )
                              : const Icon(Icons.add_circle_outline, color: AppColors.primary),
                          enabled: !isAdded,
                          onTap: isAdded ? null : () => widget.onSelect(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
