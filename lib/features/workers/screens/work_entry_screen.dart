import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/worker_model.dart';
import '../../../data/repositories/providers.dart';

class WorkEntryScreen extends ConsumerStatefulWidget {
  final String workerId;

  const WorkEntryScreen({
    super.key,
    required this.workerId,
  });

  @override
  ConsumerState<WorkEntryScreen> createState() => _WorkEntryScreenState();
}

class _WorkEntryScreenState extends ConsumerState<WorkEntryScreen> {
  DateTime _date = DateTime.now();

  final _workDescriptionController = TextEditingController();
  final _hoursController = TextEditingController();
  final _hourRateController = TextEditingController();
  final _nagQtyController = TextEditingController();
  final _nagRateController = TextEditingController();
  final _advanceController = TextEditingController();
  final _notesController = TextEditingController();

  bool _initializedDefaults = false;
  bool _showErrors = false;
  bool _isSaving = false;

  int get numericWorkerId => int.tryParse(widget.workerId) ?? 0;

  @override
  void dispose() {
    _workDescriptionController.dispose();
    _hoursController.dispose();
    _hourRateController.dispose();
    _nagQtyController.dispose();
    _nagRateController.dispose();
    _advanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initDefaults(WorkerModel worker) {
    if (_initializedDefaults) return;
    _initializedDefaults = true;

    if (worker.defaultHourRate != null && worker.defaultHourRate! > 0) {
      _hourRateController.text = worker.defaultHourRate!.toStringAsFixed(2);
    }
    if (worker.defaultNagRate != null && worker.defaultNagRate! > 0) {
      _nagRateController.text = worker.defaultNagRate!.toStringAsFixed(2);
    }
  }

  double get _hours => double.tryParse(_hoursController.text.trim()) ?? 0.0;
  double get _hourRate => double.tryParse(_hourRateController.text.trim()) ?? 0.0;
  double get _nagQty => double.tryParse(_nagQtyController.text.trim()) ?? 0.0;
  double get _nagRate => double.tryParse(_nagRateController.text.trim()) ?? 0.0;
  double get _advance => double.tryParse(_advanceController.text.trim()) ?? 0.0;

  double _calcHourAmount(String? pType) {
    if (pType != 'hour' && pType != 'both') return 0.0;
    return (_hours * _hourRate * 100).roundToDouble() / 100.0;
  }

  double _calcNagAmount(String? pType) {
    if (pType != 'piece' && pType != 'both') return 0.0;
    return (_nagQty * _nagRate * 100).roundToDouble() / 100.0;
  }

  double _calcTotalAmount(String? pType) {
    final hAmount = _calcHourAmount(pType);
    final nAmount = _calcNagAmount(pType);
    return ((hAmount + nAmount) * 100).roundToDouble() / 100.0;
  }

  double _calcFinalPayable(String? pType) {
    final total = _calcTotalAmount(pType);
    final payable = total - _advance;
    return payable < 0 ? 0.0 : (payable * 100).roundToDouble() / 100.0;
  }

  bool _isHoursValid(String? pType) {
    if (pType != 'hour' && pType != 'both') return true;
    return _hours > 0;
  }

  bool _isHourRateValid(String? pType) {
    if (pType != 'hour' && pType != 'both') return true;
    return _hourRate > 0;
  }

  bool _isNagQtyValid(String? pType) {
    if (pType != 'piece' && pType != 'both') return true;
    return _nagQty > 0;
  }

  bool _isNagRateValid(String? pType) {
    if (pType != 'piece' && pType != 'both') return true;
    return _nagRate > 0;
  }

  bool _isAdvanceValid(String? pType) {
    if (_advance < 0) return false;
    final total = _calcTotalAmount(pType);
    return _advance <= total + 0.001;
  }

  bool _isFormValid(String? pType) {
    return _isHoursValid(pType) &&
        _isHourRateValid(pType) &&
        _isNagQtyValid(pType) &&
        _isNagRateValid(pType) &&
        _isAdvanceValid(pType);
  }

  Future<void> _handleSave(WorkerModel worker) async {
    setState(() {
      _showErrors = true;
    });

    final pType = worker.paymentType;
    if (!_isFormValid(pType) || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final repo = ref.read(workerWageRepositoryProvider);

    try {
      await repo.addWorkEntry(
        workerId: worker.id,
        date: _date,
        workDescription: _workDescriptionController.text,
        hours: (pType == 'hour' || pType == 'both') ? _hours : null,
        hourRate: (pType == 'hour' || pType == 'both') ? _hourRate : null,
        nagQty: (pType == 'piece' || pType == 'both') ? _nagQty : null,
        nagRate: (pType == 'piece' || pType == 'both') ? _nagRate : null,
        advance: _advance,
        notes: _notesController.text,
      );

      // Invalidate wage summary provider so worker detail updates immediately
      ref.invalidate(workerWageSummaryProvider(worker.id));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('ArgumentError: ', '')),
          backgroundColor: AppColors.critical,
        ),
      );
      return;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Work entry saved successfully'),
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

  @override
  Widget build(BuildContext context) {
    final workerAsync = ref.watch(workerByIdProvider(numericWorkerId));

    return workerAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Add Work Entry')),
        body: Center(child: Text('Error: $err')),
      ),
      data: (worker) {
        if (worker == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Add Work Entry')),
            body: const Center(child: Text('Worker not found')),
          );
        }

        _initDefaults(worker);
        final pType = worker.paymentType;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Add Work Entry'),
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
                              // 1. Worker Read-Only Summary Chip
                              _buildWorkerChip(worker),
                              const SizedBox(height: 16),

                              // 2. Date Picker
                              _buildDatePicker(context),
                              const SizedBox(height: 16),

                              // 3. Work Description (Optional)
                              _buildTextField(
                                controller: _workDescriptionController,
                                label: 'Work / Item Name (Optional)',
                                hint: 'e.g. Shirt Stitching, Cutting Batch #4',
                                prefixIcon: Icons.work_outline,
                              ),
                              const SizedBox(height: 16),

                              // 4. Hour-based fields
                              if (pType == 'hour' || pType == 'both') ...[
                                _buildSectionHeader('HOURLY WORK DETAILS'),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _hoursController,
                                        label: 'Hours Worked *',
                                        hint: 'e.g. 5 or 8.5',
                                        prefixIcon: Icons.access_time_outlined,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        hasError: _showErrors && !_isHoursValid(pType),
                                        errorText: 'Enter hours > 0',
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _hourRateController,
                                        label: 'Hour Rate (₹) *',
                                        hint: 'e.g. 100.00',
                                        prefixIcon: Icons.currency_rupee_outlined,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        hasError: _showErrors && !_isHourRateValid(pType),
                                        errorText: 'Enter rate > 0',
                                        helperText: 'Editable for rate override',
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Hour Amount: ₹${_calcHourAmount(pType).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // 5. Piece-based fields
                              if (pType == 'piece' || pType == 'both') ...[
                                _buildSectionHeader('NAG / PIECE WORK DETAILS'),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _nagQtyController,
                                        label: 'Nag / Piece Qty *',
                                        hint: 'e.g. 30',
                                        prefixIcon: Icons.category_outlined,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        hasError: _showErrors && !_isNagQtyValid(pType),
                                        errorText: 'Enter qty > 0',
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _nagRateController,
                                        label: 'Nag Rate (₹) *',
                                        hint: 'e.g. 10.00',
                                        prefixIcon: Icons.currency_rupee_outlined,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        hasError: _showErrors && !_isNagRateValid(pType),
                                        errorText: 'Enter rate > 0',
                                        helperText: 'Editable for rate override',
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Nag Amount: ₹${_calcNagAmount(pType).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // 6. Live Totals Card
                              _buildTotalsCard(pType),
                              const SizedBox(height: 16),

                              // 7. Advance Input
                              _buildTextField(
                                controller: _advanceController,
                                label: 'Advance Paid (₹) (Optional)',
                                hint: '0.00',
                                prefixIcon: Icons.payments_outlined,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                hasError: _showErrors && !_isAdvanceValid(pType),
                                errorText:
                                    'Advance (₹${_advance.toStringAsFixed(2)}) cannot exceed total amount earned (₹${_calcTotalAmount(pType).toStringAsFixed(2)}).',
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 16),

                              // 8. Notes
                              _buildTextField(
                                controller: _notesController,
                                label: 'Notes / Remarks (Optional)',
                                hint: 'Additional remarks about today\'s work',
                                prefixIcon: Icons.note_outlined,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bottom Action Bar
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
                              child: OutlinedButton(
                                onPressed: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.go('/workers/${worker.id}');
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: const BorderSide(color: AppColors.borderLight),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : () => _handleSave(worker),
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
                                    : const Text('Save Work Entry'),
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
    final typeStr = worker.paymentType == 'hour'
        ? 'Hour Based'
        : worker.paymentType == 'piece'
            ? 'Nag / Piece Based'
            : worker.paymentType == 'both'
                ? 'Both (Hour + Piece)'
                : 'Not Configured';

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
                  'Payment Type: $typeStr',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.info,
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
          labelText: 'Work Date *',
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.labelSm.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTotalsCard(String? pType) {
    final total = _calcTotalAmount(pType);
    final payable = _calcFinalPayable(pType);

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
                '₹${total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          if (_advance > 0) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Less Advance Paid',
                  style: TextStyle(fontSize: 13, color: AppColors.tertiary),
                ),
                Text(
                  '- ₹${_advance.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.tertiary),
                ),
              ],
            ),
          ],
          const Divider(height: 16, thickness: 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Final Payable',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Text(
                '₹${payable.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
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
