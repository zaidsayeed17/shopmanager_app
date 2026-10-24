import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/item_model.dart';
import '../../../data/models/worker_model.dart';
import '../../../data/repositories/providers.dart';

class CuttingEntryScreen extends ConsumerStatefulWidget {
  final String workerId;

  const CuttingEntryScreen({
    super.key,
    required this.workerId,
  });

  @override
  ConsumerState<CuttingEntryScreen> createState() => _CuttingEntryScreenState();
}

class _CuttingEntryScreenState extends ConsumerState<CuttingEntryScreen> {
  DateTime _date = DateTime.now();

  ItemModel? _selectedItem;
  final _qtyController = TextEditingController();
  final _rateController = TextEditingController();
  final _remarkController = TextEditingController();

  bool _showErrors = false;
  bool _isSaving = false;

  int get numericWorkerId => int.tryParse(widget.workerId) ?? 0;

  @override
  void dispose() {
    _qtyController.dispose();
    _rateController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  double get _quantity => double.tryParse(_qtyController.text.trim()) ?? 0.0;
  double get _rate => double.tryParse(_rateController.text.trim()) ?? 0.0;

  double get _totalAmount => ((_quantity * _rate) * 100).roundToDouble() / 100.0;

  bool get _isItemValid => _selectedItem != null;
  bool get _isQtyValid => _quantity > 0;
  bool get _isRateValid => _rate > 0;

  bool get _isFormValid => _isItemValid && _isQtyValid && _isRateValid;

  bool get _isOverselling {
    if (_selectedItem == null || _quantity <= 0) return false;
    return _quantity > _selectedItem!.currentQty;
  }

  Future<bool> _submitForm(WorkerModel worker) async {
    setState(() {
      _showErrors = true;
    });

    if (!_isFormValid || _isSaving) {
      return false;
    }

    setState(() {
      _isSaving = true;
    });

    final repo = ref.read(workerCuttingRepositoryProvider);

    try {
      await repo.addCuttingEntry(
        workerId: worker.id,
        itemId: _selectedItem!.id,
        date: _date,
        quantity: _quantity,
        rate: _rate,
        remark: _remarkController.text,
      );

      // Invalidate stock and cutting summaries for instant UI reflow
      ref.invalidate(itemsStreamProvider);
      ref.invalidate(workerTodaysCuttingSummaryProvider(worker.id));
      ref.invalidate(workerCuttingEntriesStreamProvider(worker.id));
      return true;
    } catch (e) {
      if (!mounted) return false;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('ArgumentError: ', '')),
          backgroundColor: AppColors.critical,
        ),
      );
      return false;
    }
  }

  Future<void> _handleSaveAndDone(WorkerModel worker) async {
    final success = await _submitForm(worker);
    if (!success || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cutting entry saved successfully'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );

    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/workers/${worker.id}');
    }
  }

  Future<void> _handleSaveAndAddAnother(WorkerModel worker) async {
    final success = await _submitForm(worker);
    if (!success || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Cutting entry saved (${_selectedItem?.name} × ${_quantity % 1 == 0 ? _quantity.toInt() : _quantity}). Add another below.',
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );

    setState(() {
      _isSaving = false;
      _showErrors = false;
      _qtyController.clear();
      _remarkController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final workerAsync = ref.watch(workerByIdProvider(numericWorkerId));

    return workerAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Worker Cutting Entry')),
        body: Center(child: Text('Error: $err')),
      ),
      data: (worker) {
        if (worker == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Worker Cutting Entry')),
            body: const Center(child: Text('Worker not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Worker Cutting Entry'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/workers/${worker.id}');
                }
              },
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= AppConstants.tabletBreakpoint;
              final contentPadding = isTablet ? 24.0 : 16.0;

              return Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 600 : double.infinity,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(contentPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Worker Summary Chip
                              _buildWorkerChip(worker),
                              const SizedBox(height: 16),

                              // 2. Date Picker
                              _buildDatePicker(context),
                              const SizedBox(height: 16),

                              // 3. Colour Picker (Raw Material Items)
                              _buildColourPicker(),
                              const SizedBox(height: 16),

                              // 4. Quantity (Nag) & Rate (₹)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _qtyController,
                                      label: 'Cutting Qty (Nag) *',
                                      hint: 'e.g. 50',
                                      prefixIcon: Icons.format_list_numbered_outlined,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(decimal: true),
                                      hasError: _showErrors && !_isQtyValid,
                                      errorText: 'Enter quantity > 0',
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _rateController,
                                      label: 'Rate per Nag (₹) *',
                                      hint: 'e.g. 10.00',
                                      prefixIcon: Icons.currency_rupee_outlined,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(decimal: true),
                                      hasError: _showErrors && !_isRateValid,
                                      errorText: 'Enter rate > 0',
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // 5. Live Computed Total Amount & Oversell Warning
                              _buildTotalAndWarningCard(),
                              const SizedBox(height: 16),

                              // 6. Remark
                              _buildTextField(
                                controller: _remarkController,
                                label: 'Remark (Optional)',
                                hint: 'e.g. Batch #12, Table A',
                                prefixIcon: Icons.note_outlined,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bottom Action Bar (Save & Add Another / Save)
                      Container(
                        padding: EdgeInsets.all(contentPadding),
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          border: Border(
                            top: BorderSide(color: AppColors.borderLight),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed:
                                    _isSaving ? null : () => _handleSaveAndAddAnother(worker),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Save & Add Another'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: const BorderSide(color: AppColors.primary),
                                  foregroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : () => _handleSaveAndDone(worker),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Save Entry'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildWorkerChip(WorkerModel worker) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.activePillBg,
            child: Text(
              worker.initials,
              style: const TextStyle(
                fontSize: 14,
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
                    Text(
                      worker.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Text(
                        worker.formattedWorkerId,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Worker Cutting Entry',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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

  Widget _buildDatePicker(BuildContext context) {
    final dateStr =
        '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}';

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _date,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            _date = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Cutting Date *',
          prefixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.textMuted),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateStr,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
            const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildColourPicker() {
    final rawMaterialsAsync = ref.watch(activeRawMaterialsProvider);

    return rawMaterialsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error loading colours: $e'),
      data: (items) {
        if (_selectedItem == null && items.isNotEmpty) {
          // Pre-select first item if available
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _selectedItem == null) {
              setState(() {
                _selectedItem = items.first;
                if (_selectedItem!.purchaseRate > 0 && _rateController.text.isEmpty) {
                  _rateController.text = _selectedItem!.purchaseRate.toStringAsFixed(2);
                }
              });
            }
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<ItemModel>(
              value: _selectedItem,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Colour / Material *',
                hintText: 'Select colour',
                prefixIcon: const Icon(Icons.palette_outlined, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _showErrors && !_isItemValid ? AppColors.critical : AppColors.borderLight,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              items: items.map((item) {
                return DropdownMenuItem<ItemModel>(
                  value: item,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Stock: ${item.currentQty % 1 == 0 ? item.currentQty.toInt() : item.currentQty.toStringAsFixed(1)} ${item.unit}',
                        style: TextStyle(
                          fontSize: 12,
                          color: item.currentQty <= 0 ? AppColors.critical : AppColors.textSecondary,
                          fontWeight: item.currentQty <= 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedItem = val;
                    if (val.purchaseRate > 0 && _rateController.text.isEmpty) {
                      _rateController.text = val.purchaseRate.toStringAsFixed(2);
                    }
                  });
                }
              },
            ),
            if (_showErrors && !_isItemValid) ...[
              const SizedBox(height: 4),
              const Text(
                'Please select a colour / material',
                style: TextStyle(fontSize: 11, color: AppColors.critical),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTotalAndWarningCard() {
    final stockVal = _selectedItem?.currentQty ?? 0.0;
    final unitStr = _selectedItem?.unit ?? 'nag';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount Earned',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              Text(
                '₹${_totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (_isOverselling) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warningBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_outlined, size: 18, color: AppColors.tertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Only ${stockVal % 1 == 0 ? stockVal.toInt() : stockVal.toStringAsFixed(1)} $unitStr available — proceeding will oversell this colour.',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.tertiary,
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
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool hasError = false,
    String? errorText,
    String? helperText,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(prefixIcon, color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError ? AppColors.critical : AppColors.borderLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError ? AppColors.critical : AppColors.primary,
                width: 2,
              ),
            ),
          ),
        ),
        if (hasError && errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.critical,
            ),
          ),
        ] else if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}
