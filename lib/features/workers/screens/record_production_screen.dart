import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/item_model.dart';
import '../../../data/models/worker_model.dart';
import '../../../data/repositories/production_repository.dart';
import '../../../data/repositories/providers.dart';

class RecordProductionScreen extends ConsumerStatefulWidget {
  final String workerId;

  const RecordProductionScreen({
    super.key,
    required this.workerId,
  });

  @override
  ConsumerState<RecordProductionScreen> createState() => _RecordProductionScreenState();
}

class _InputLineUiState {
  final PendingMaterialForWorker pending;
  bool isIncluded;
  final TextEditingController qtyUsedController;
  bool returnLeftover;

  _InputLineUiState({
    required this.pending,
    required this.isIncluded,
    required this.qtyUsedController,
    this.returnLeftover = true,
  });
}

class _RecordProductionScreenState extends ConsumerState<RecordProductionScreen> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _batchRefController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _outputQtyController = TextEditingController();

  int? _selectedOutputItemId;
  List<_InputLineUiState> _lines = [];
  bool _initializedLines = false;
  bool _hasAttemptedSave = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _batchRefController.dispose();
    _notesController.dispose();
    _outputQtyController.dispose();
    for (final line in _lines) {
      line.qtyUsedController.dispose();
    }
    super.dispose();
  }

  void _initLines(List<PendingMaterialForWorker> pendingList) {
    if (_initializedLines) return;
    _lines = pendingList.map((p) {
      final controller = TextEditingController(
        text: p.remainingPendingQuantity.toStringAsFixed(3).replaceAll(RegExp(r'\.?0+$'), ''),
      );
      controller.addListener(() {
        setState(() {});
      });
      return _InputLineUiState(
        pending: p,
        isIncluded: true,
        qtyUsedController: controller,
        returnLeftover: true,
      );
    }).toList();
    _initializedLines = true;
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
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String? _getLineError(_InputLineUiState line) {
    if (!line.isIncluded) return null;
    final valStr = line.qtyUsedController.text.trim();
    final val = double.tryParse(valStr);
    if (valStr.isEmpty || val == null || val <= 0) {
      return 'Enter a quantity used greater than 0';
    }
    if (val > line.pending.remainingPendingQuantity + 0.0001) {
      return 'Only ${line.pending.remainingPendingQuantity} ${line.pending.item.unit} pending for this worker. Reduce the quantity to ${line.pending.remainingPendingQuantity} ${line.pending.item.unit} or lower to proceed.';
    }
    return null;
  }

  String? _getOutputQtyError() {
    final valStr = _outputQtyController.text.trim();
    final val = double.tryParse(valStr);
    if (valStr.isEmpty || val == null || val <= 0) {
      return 'Please enter a valid quantity produced greater than 0';
    }
    return null;
  }

  String? _getValidationSummary(List<ItemModel> finishedProducts) {
    final includedLines = _lines.where((l) => l.isIncluded).toList();
    if (includedLines.isEmpty) {
      return 'Select at least one raw material input to record production.';
    }
    for (final line in includedLines) {
      final err = _getLineError(line);
      if (err != null) {
        return 'One or more raw materials exceed pending quantity or have invalid quantities.';
      }
    }
    if (_selectedOutputItemId == null || _selectedOutputItemId! <= 0) {
      return 'Please select a finished output product.';
    }
    if (_getOutputQtyError() != null) {
      return 'Please enter a valid quantity produced.';
    }
    return null;
  }

  bool _isFormValid(List<ItemModel> finishedProducts) {
    return _getValidationSummary(finishedProducts) == null;
  }

  Future<void> _onSave(WorkerModel worker, List<ItemModel> finishedProducts) async {
    setState(() {
      _hasAttemptedSave = true;
    });

    final summaryErr = _getValidationSummary(finishedProducts);
    if (summaryErr != null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final inputLines = <ProductionInputLine>[];
      for (final line in _lines) {
        if (!line.isIncluded) continue;
        final qUsed = double.parse(line.qtyUsedController.text.trim());
        final leftover = line.pending.remainingPendingQuantity - qUsed;
        final qRet = (leftover > 0 && line.returnLeftover) ? leftover : 0.0;
        inputLines.add(
          ProductionInputLine(
            itemId: line.pending.itemId,
            quantityUsed: qUsed,
            quantityReturned: qRet,
          ),
        );
      }

      final repo = ref.read(productionRepositoryProvider);
      await repo.recordProduction(
        workerId: worker.id,
        date: _selectedDate,
        batchRef: _batchRefController.text.trim().isEmpty ? null : _batchRefController.text.trim(),
        inputs: inputLines,
        outputItemId: _selectedOutputItemId!,
        outputQty: double.parse(_outputQtyController.text.trim()),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      // Invalidate providers for real-time UI refresh
      ref.invalidate(workersStreamProvider);
      ref.invalidate(workerByIdProvider(worker.id));
      ref.invalidate(itemsStreamProvider);
      ref.invalidate(finishedProductsProvider);
      ref.invalidate(pendingMaterialsForWorkerProvider(worker.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Production recorded successfully'),
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
            content: Text('Error saving production: $e'),
            backgroundColor: AppColors.critical,
          ),
        );
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final numericId = int.tryParse(widget.workerId) ?? 0;
    final workerAsync = ref.watch(workerByIdProvider(numericId));
    final pendingAsync = ref.watch(pendingMaterialsForWorkerProvider(numericId));
    final finishedProductsAsync = ref.watch(finishedProductsProvider);

    return workerAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Record Production')),
        body: Center(child: Text('Error: $err')),
      ),
      data: (worker) {
        if (worker == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Record Production')),
            body: const Center(child: Text('Worker not found')),
          );
        }

        return pendingAsync.when(
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (err, stack) => Scaffold(
            appBar: AppBar(title: const Text('Record Production')),
            body: Center(child: Text('Error: $err')),
          ),
          data: (pendingList) {
            _initLines(pendingList);
            final finishedProducts = finishedProductsAsync.value ?? [];
            final isTablet = MediaQuery.of(context).size.width >= 768;

            return Scaffold(
              appBar: AppBar(
                title: Text(
                  'Record Production',
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
                          constraints: const BoxConstraints(maxWidth: 950),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Conditional Error Banner (only shows when save attempted & form invalid)
                              if (_hasAttemptedSave && !_isFormValid(finishedProducts)) ...[
                                _buildTopErrorBanner(finishedProducts),
                                const SizedBox(height: 16),
                              ],

                              // Worker Summary Chip
                              _buildWorkerChip(worker, pendingList.length),
                              const SizedBox(height: 16),

                              if (pendingList.isEmpty)
                                _buildZeroPendingMessage(context)
                              else ...[
                                // Date & Batch Reference
                                if (isTablet)
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: _buildDateInput()),
                                      const SizedBox(width: 16),
                                      Expanded(child: _buildBatchRefInput()),
                                    ],
                                  )
                                else ...[
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: _buildDateInput()),
                                      const SizedBox(width: 12),
                                      Expanded(child: _buildBatchRefInput()),
                                    ],
                                  ),
                                ],

                                const SizedBox(height: 20),

                                // Raw Materials Used Section
                                _buildRawMaterialsSection(isTablet),

                                const SizedBox(height: 20),

                                // Finished Product Section
                                if (isTablet)
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: _buildFinishedProductSection(finishedProducts)),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            _buildNotesSection(),
                                            const SizedBox(height: 16),
                                            _buildSummaryPreviewCard(finishedProducts),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                else ...[
                                  _buildFinishedProductSection(finishedProducts),
                                  const SizedBox(height: 16),
                                  _buildNotesSection(),
                                  const SizedBox(height: 16),
                                  _buildSummaryPreviewCard(finishedProducts),
                                ],

                                const SizedBox(height: 24),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (pendingList.isNotEmpty)
                    _buildBottomActionBar(worker, finishedProducts),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTopErrorBanner(List<ItemModel> finishedProducts) {
    final summary = _getValidationSummary(finishedProducts) ?? 'Please fix the errors below.';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.criticalBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.critical.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 20, color: AppColors.critical),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTypography.bodySm.copyWith(color: AppColors.critical),
                children: [
                  const TextSpan(
                    text: 'Cannot save production: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: summary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerChip(WorkerModel worker, int pendingCount) {
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
              width: 42,
              height: 42,
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
                          'Worker ID: ${worker.formattedWorkerId}',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    worker.workType ?? 'General Worker',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: pendingCount > 0 ? AppColors.activePillBg : AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: pendingCount > 0 ? AppColors.activePillBorder : AppColors.borderLight,
                ),
              ),
              child: Text(
                pendingCount > 0 ? '$pendingCount Pending Material${pendingCount > 1 ? 's' : ''}' : 'No Pending Materials',
                style: AppTypography.labelSm.copyWith(
                  color: pendingCount > 0 ? AppColors.secondary : AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZeroPendingMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_outlined,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            'This worker has no pending material right now.',
            textAlign: TextAlign.center,
            style: AppTypography.headlineMd.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Issue raw materials to this worker before recording production.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/workers');
              }
            },
            child: const Text('Back to Worker Details'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Production Date ',
              style: AppTypography.bodySm.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text('*', style: TextStyle(color: AppColors.critical, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBatchRefInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Batch Reference',
          style: AppTypography.bodySm.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _batchRefController,
          style: AppTypography.bodyMd,
          decoration: const InputDecoration(
            hintText: 'e.g. Batch #24-B',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildRawMaterialsSection(bool isTablet) {
    final activeCount = _lines.where((l) => l.isIncluded).length;
    final overLimitCount = _lines.where((l) => l.isIncluded && _getLineError(l) != null).length;

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Raw Materials Used',
                      style: AppTypography.headlineMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'From this worker\'s pending material',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  overLimitCount > 0
                      ? '$overLimitCount Over-limit error'
                      : '$activeCount selected',
                  style: AppTypography.labelSm.copyWith(
                    color: overLimitCount > 0 ? AppColors.critical : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (isTablet)
              _buildTabletMaterialsTable()
            else
              _buildMobileMaterialsList(),
          ],
        ),
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
        final pending = line.pending;
        final errorText = _getLineError(line);
        final hasError = errorText != null;

        final qtyVal = double.tryParse(line.qtyUsedController.text.trim()) ?? 0;
        final isPartial = line.isIncluded && qtyVal > 0 && qtyVal < pending.remainingPendingQuantity;
        final leftover = pending.remainingPendingQuantity - qtyVal;

        Color cardBorderColor = AppColors.borderLight;
        Color cardBgColor = AppColors.surface;

        if (hasError) {
          cardBorderColor = AppColors.critical;
          cardBgColor = AppColors.criticalBg.withValues(alpha: 0.3);
        } else if (isPartial) {
          cardBorderColor = AppColors.primary.withValues(alpha: 0.4);
          cardBgColor = AppColors.activePillBg.withValues(alpha: 0.4);
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cardBorderColor, width: hasError ? 1.5 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: line.isIncluded,
                    onChanged: (val) {
                      setState(() {
                        line.isIncluded = val ?? false;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pending.item.name,
                          style: AppTypography.bodyLg.copyWith(
                            fontWeight: FontWeight.bold,
                            color: line.isIncluded ? AppColors.textPrimary : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                            children: [
                              const TextSpan(text: 'Pending with worker: '),
                              TextSpan(
                                text: '${pending.remainingPendingQuantity} ${pending.item.unit}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: hasError ? AppColors.critical : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: hasError ? AppColors.criticalBg : AppColors.background,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: hasError ? AppColors.critical : AppColors.borderLight,
                      ),
                    ),
                    child: Text(
                      hasError
                          ? 'EXCEEDED'
                          : (isPartial
                              ? '${qtyVal.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} of ${pending.remainingPendingQuantity} ${pending.item.unit} used'
                              : 'Issued ${_formatDate(pending.issueDate)}'),
                      style: AppTypography.labelSm.copyWith(
                        color: hasError ? AppColors.critical : AppColors.textSecondary,
                        fontWeight: hasError ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),

              if (line.isIncluded) ...[
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Qty Used:',
                          style: AppTypography.bodySm.copyWith(
                            fontWeight: FontWeight.bold,
                            color: hasError ? AppColors.critical : AppColors.textSecondary,
                          ),
                        ),
                        if (isPartial)
                          Text(
                            '${leftover.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} ${pending.item.unit} remaining',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(
                      width: 140,
                      child: TextField(
                        controller: line.qtyUsedController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.right,
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.bold,
                          color: hasError ? AppColors.critical : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          suffixIcon: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: const BoxDecoration(
                              color: AppColors.background,
                              border: Border(left: BorderSide(color: AppColors.borderMedium)),
                            ),
                            child: Text(
                              pending.item.unit,
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
                  ],
                ),

                if (hasError) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.critical.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error, size: 16, color: AppColors.critical),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            errorText,
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.critical,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (isPartial) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.successBg.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              line.returnLeftover = !line.returnLeftover;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.replay, size: 16, color: AppColors.success),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Return leftover (${leftover.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} ${pending.item.unit}) to stock',
                                    style: AppTypography.bodySm.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: line.returnLeftover,
                                onChanged: (val) {
                                  setState(() {
                                    line.returnLeftover = val;
                                  });
                                },
                                activeThumbColor: AppColors.success,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          line.returnLeftover
                              ? '✓ ${leftover.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} ${pending.item.unit} will be added back to raw shop stock immediately. Worker\'s pending balance will close to 0 ${pending.item.unit}.'
                              : '${leftover.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} ${pending.item.unit} will remain pending with worker.',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabletMaterialsTable() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          color: AppColors.background,
          child: Row(
            children: [
              const SizedBox(width: 40),
              Expanded(
                flex: 3,
                child: Text(
                  'MATERIAL NAME',
                  style: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'PENDING WITH WORKER',
                  style: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(
                width: 150,
                child: Text(
                  'QTY USED',
                  textAlign: TextAlign.right,
                  style: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 200),
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
            final pending = line.pending;
            final errorText = _getLineError(line);
            final hasError = errorText != null;
            final qtyVal = double.tryParse(line.qtyUsedController.text.trim()) ?? 0;
            final isPartial = line.isIncluded && qtyVal > 0 && qtyVal < pending.remainingPendingQuantity;
            final leftover = pending.remainingPendingQuantity - qtyVal;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Checkbox(
                          value: line.isIncluded,
                          onChanged: (val) {
                            setState(() {
                              line.isIncluded = val ?? false;
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          pending.item.name,
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.bold,
                            color: line.isIncluded ? AppColors.textPrimary : AppColors.textMuted,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${pending.remainingPendingQuantity} ${pending.item.unit}',
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.bold,
                            color: hasError ? AppColors.critical : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: TextField(
                          enabled: line.isIncluded,
                          controller: line.qtyUsedController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.right,
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.bold,
                            color: hasError ? AppColors.critical : AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            suffixIcon: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              decoration: const BoxDecoration(
                                color: AppColors.background,
                                border: Border(left: BorderSide(color: AppColors.borderMedium)),
                              ),
                              child: Text(
                                pending.item.unit,
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
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 184,
                        child: isPartial && line.isIncluded
                            ? Row(
                                children: [
                                  Checkbox(
                                    value: line.returnLeftover,
                                    onChanged: (val) {
                                      setState(() {
                                        line.returnLeftover = val ?? false;
                                      });
                                    },
                                    activeColor: AppColors.success,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Return ${leftover.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} ${pending.item.unit}',
                                      style: AppTypography.labelSm.copyWith(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),

                  if (hasError)
                    Padding(
                      padding: const EdgeInsets.only(left: 40, top: 4),
                      child: Text(
                        errorText,
                        style: AppTypography.bodySm.copyWith(color: AppColors.critical),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFinishedProductSection(List<ItemModel> finishedProducts) {
    ItemModel? selectedItem;
    if (_selectedOutputItemId != null) {
      for (final item in finishedProducts) {
        if (item.id == _selectedOutputItemId) {
          selectedItem = item;
          break;
        }
      }
    }

    final showOutputErr = _hasAttemptedSave && _getOutputQtyError() != null;
    final showItemErr = _hasAttemptedSave && (_selectedOutputItemId == null || _selectedOutputItemId! <= 0);

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
              'Finished Product',
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Text(
                  'Output Item ',
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text('*', style: TextStyle(color: AppColors.critical, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),

            if (finishedProducts.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'No finished product items found in stock. Please add finished products in the Stock module first.',
                  style: AppTypography.bodySm.copyWith(color: AppColors.warning),
                ),
              ),
            ] else ...[
              DropdownButtonFormField<int>(
                initialValue: _selectedOutputItemId,
                hint: const Text('Select output finished product...'),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: const OutlineInputBorder(),
                  errorText: showItemErr ? 'Please select an output item' : null,
                ),
                items: finishedProducts.map((item) {
                  return DropdownMenuItem<int>(
                    value: item.id,
                    child: Text(
                      '${item.name}${item.category != null ? ' (${item.category})' : ''}',
                      style: AppTypography.bodyMd,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedOutputItemId = val;
                  });
                },
              ),
            ],

            const SizedBox(height: 14),

            Row(
              children: [
                Text(
                  'Quantity Produced ',
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text('*', style: TextStyle(color: AppColors.critical, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _outputQtyController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. 45',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: const OutlineInputBorder(),
                      errorText: showOutputErr ? _getOutputQtyError() : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.borderMedium),
                  ),
                  child: Text(
                    selectedItem != null ? selectedItem.unit : 'pcs',
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
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
              maxLines: 2,
              style: AppTypography.bodyMd,
              decoration: const InputDecoration(
                hintText: 'Inspection remarks, lot nuances, defects...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryPreviewCard(List<ItemModel> finishedProducts) {
    final includedLines = _lines.where((l) => l.isIncluded).toList();
    final isValid = _isFormValid(finishedProducts);

    ItemModel? outputItem;
    if (_selectedOutputItemId != null) {
      for (final item in finishedProducts) {
        if (item.id == _selectedOutputItemId) {
          outputItem = item;
          break;
        }
      }
    }

    final outQtyVal = double.tryParse(_outputQtyController.text.trim()) ?? 0;
    final outQtyStr = outQtyVal.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
    final itemNameStr = outputItem != null ? outputItem.name : 'product';
    final itemUnitStr = outputItem != null ? outputItem.unit : 'pcs';

    double totalReturned = 0;
    for (final line in includedLines) {
      final qUsed = double.tryParse(line.qtyUsedController.text.trim()) ?? 0;
      final leftover = line.pending.remainingPendingQuantity - qUsed;
      if (leftover > 0 && line.returnLeftover) {
        totalReturned += leftover;
      }
    }

    final returnedStr = totalReturned > 0
        ? ' • Returning ${totalReturned.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} unit to stock'
        : '';

    final summaryText = 'Closing ${includedLines.length} material(s)$returnedStr • Producing $outQtyStr $itemUnitStr $itemNameStr';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isValid ? AppColors.activePillBg : AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isValid ? AppColors.activePillBorder : AppColors.borderMedium,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle_outline : Icons.info_outline,
            color: isValid ? AppColors.primary : AppColors.textMuted,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Production Summary',
                  style: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  summaryText,
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(WorkerModel worker, List<ItemModel> finishedProducts) {
    final isValid = _isFormValid(finishedProducts);
    final isDisabled = _isSaving || !isValid;

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
                onPressed: isDisabled ? null : () => _onSave(worker, finishedProducts),
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.precision_manufacturing_outlined, size: 18),
                label: Text(_isSaving ? 'Saving...' : 'Save Production'),
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
