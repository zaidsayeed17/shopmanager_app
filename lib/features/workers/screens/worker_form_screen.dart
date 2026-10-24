import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/providers.dart';

class WorkerFormScreen extends ConsumerStatefulWidget {
  final String? workerId;

  const WorkerFormScreen({
    super.key,
    this.workerId,
  });

  @override
  ConsumerState<WorkerFormScreen> createState() => _WorkerFormScreenState();
}

class _WorkerFormScreenState extends ConsumerState<WorkerFormScreen> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _workTypeController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _defaultHourRateController = TextEditingController();
  final _defaultNagRateController = TextEditingController();

  DateTime? _joiningDate;
  String? _paymentType; // null, 'hour', 'piece', 'both'

  bool _isActive = true;
  bool _initialIsActive = true;
  int _pendingItemCount = 0;
  bool _showErrors = false;
  bool _dismissedErrorBanner = false;
  bool _isSaving = false;

  bool get isEditing => widget.workerId != null;

  static const List<String> _workTypeChips = [
    'Stitching',
    'Cutting',
    'Finishing',
    'Packing',
  ];

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final id = int.tryParse(widget.workerId!);
      if (id != null) {
        Future.microtask(() async {
          final existing = await ref.read(workerRepositoryProvider).getWorkerById(id);
          if (existing != null && mounted) {
            setState(() {
              _nameController.text = existing.name;
              _mobileController.text = existing.mobile ?? '';
              _workTypeController.text = existing.workType ?? '';
              _addressController.text = existing.address ?? '';
              _notesController.text = existing.notes ?? '';
              _joiningDate = existing.joiningDate;
              _paymentType = existing.paymentType;
              _defaultHourRateController.text =
                  existing.defaultHourRate != null ? existing.defaultHourRate!.toStringAsFixed(2) : '';
              _defaultNagRateController.text =
                  existing.defaultNagRate != null ? existing.defaultNagRate!.toStringAsFixed(2) : '';
              _isActive = existing.isActive;
              _initialIsActive = existing.isActive;
              _pendingItemCount = existing.pendingItemCount;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _workTypeController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _defaultHourRateController.dispose();
    _defaultNagRateController.dispose();
    super.dispose();
  }

  bool get _isNameValid => _nameController.text.trim().isNotEmpty;
  bool get _isMobileValid {
    final mob = _mobileController.text.trim();
    if (mob.isEmpty) return true;
    return RegExp(r'^\d{10}$').hasMatch(mob);
  }

  bool get _isHourRateValid {
    if (_paymentType != 'hour' && _paymentType != 'both') return true;
    final rate = double.tryParse(_defaultHourRateController.text.trim());
    return rate != null && rate > 0;
  }

  bool get _isNagRateValid {
    if (_paymentType != 'piece' && _paymentType != 'both') return true;
    final rate = double.tryParse(_defaultNagRateController.text.trim());
    return rate != null && rate > 0;
  }

  bool get _isFormValid =>
      _isNameValid && _isMobileValid && _isHourRateValid && _isNagRateValid;

  Future<void> _handleSave() async {
    setState(() {
      _showErrors = true;
      _dismissedErrorBanner = false;
    });

    if (!_isFormValid || _isSaving) {
      return;
    }

    final numericId = isEditing ? int.tryParse(widget.workerId!) : null;

    // Check if user is deactivating an active worker
    if (isEditing && _initialIsActive && !_isActive) {
      final confirm = await _showDeactivationDialog(_nameController.text.trim());
      if (confirm != true) {
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    final repo = ref.read(workerRepositoryProvider);

    final defaultHourRate = double.tryParse(_defaultHourRateController.text.trim());
    final defaultNagRate = double.tryParse(_defaultNagRateController.text.trim());

    try {
      if (isEditing && numericId != null) {
        await repo.updateWorker(
          id: numericId,
          name: _nameController.text,
          mobile: _mobileController.text,
          workType: _workTypeController.text,
          address: _addressController.text,
          notes: _notesController.text,
          isActive: _isActive,
          joiningDate: _joiningDate,
          paymentType: _paymentType,
          defaultHourRate: defaultHourRate,
          defaultNagRate: defaultNagRate,
        );
      } else {
        await repo.addWorker(
          name: _nameController.text,
          mobile: _mobileController.text,
          workType: _workTypeController.text,
          address: _addressController.text,
          notes: _notesController.text,
          joiningDate: _joiningDate,
          paymentType: _paymentType,
          defaultHourRate: defaultHourRate,
          defaultNagRate: defaultNagRate,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong saving this — your data wasn't changed. Try again."),
          backgroundColor: AppColors.critical,
        ),
      );
      return;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? 'Worker profile updated' : 'Worker saved'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );

    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/workers');
    }
  }

  Future<bool?> _showDeactivationDialog(String workerName) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Deactivate $workerName?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'They won\'t appear when assigning material. Their history is kept.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              if (_pendingItemCount > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warningBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_outlined, size: 18, color: AppColors.tertiary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This worker still holds $_pendingItemCount pending item${_pendingItemCount == 1 ? '' : 's'}.',
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.critical,
                foregroundColor: Colors.white,
              ),
              child: const Text('Deactivate'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedId = isEditing && widget.workerId != null
        ? 'Worker ID: W-${(int.tryParse(widget.workerId!) ?? 0).toString().padLeft(4, '0')}'
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Worker' : 'Add Worker'),
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
                          // Read-only Worker ID line on Edit form
                          if (formattedId != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Text(
                                formattedId,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Error Summary Banner
                          if (_showErrors && !_isFormValid && !_dismissedErrorBanner) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.criticalBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.critical.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.error,
                                    color: AppColors.critical,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Missing Information',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.critical,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (!_isNameValid)
                                          const Text('• Worker name is required',
                                              style: TextStyle(fontSize: 12, color: AppColors.critical)),
                                        if (!_isMobileValid)
                                          const Text('• Enter a valid 10-digit mobile number',
                                              style: TextStyle(fontSize: 12, color: AppColors.critical)),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _dismissedErrorBanner = true;
                                      });
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: AppColors.critical,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Active/Inactive Toggle (Edit Mode Only)
                          if (isEditing) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Worker Status',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        _isActive
                                            ? 'Active (Available for material issue)'
                                            : 'Inactive (Hidden from assignment lists)',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Switch(
                                    value: _isActive,
                                    activeThumbColor: AppColors.primary,
                                    onChanged: (val) {
                                      setState(() {
                                        _isActive = val;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Basic Details Section
                          _buildSectionHeader('WORKER DETAILS'),
                          const SizedBox(height: 8),

                          // Worker Name
                          _buildTextField(
                            controller: _nameController,
                            label: 'Worker Name *',
                            hint: 'e.g. Ramesh Singh',
                            prefixIcon: Icons.person_outline,
                            hasError: _showErrors && !_isNameValid,
                            errorText: 'Worker name is required',
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 12),

                          // Mobile Number
                          _buildTextField(
                            controller: _mobileController,
                            label: 'Mobile Number (Optional)',
                            hint: '10-digit mobile number',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            hasError: _showErrors && !_isMobileValid,
                            errorText: 'Enter a valid 10-digit mobile number',
                            helperText: 'Optional. Used to call or message the worker',
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 12),

                          // Joining Date (Optional)
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _joiningDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  _joiningDate = picked;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Joining Date (Optional)',
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
                                    _joiningDate != null
                                        ? '${_joiningDate!.day.toString().padLeft(2, '0')}/${_joiningDate!.month.toString().padLeft(2, '0')}/${_joiningDate!.year}'
                                        : 'Not set',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _joiningDate != null ? AppColors.textPrimary : AppColors.textMuted,
                                    ),
                                  ),
                                  if (_joiningDate != null)
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _joiningDate = null;
                                        });
                                      },
                                      child: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Work Type Field + Chips
                          _buildTextField(
                            controller: _workTypeController,
                            label: 'Work Type (Optional)',
                            hint: 'e.g. Stitching, Cutting, Finishing',
                            prefixIcon: Icons.work_outline,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: _workTypeChips.map((chip) {
                              final isSelected = _workTypeController.text.trim() == chip;
                              return ChoiceChip(
                                label: Text(chip),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _workTypeController.text = chip;
                                    });
                                  }
                                },
                                selectedColor: AppColors.activePillBg,
                                backgroundColor: AppColors.surface,
                                side: BorderSide(
                                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                                ),
                                labelStyle: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),

                          // Address Field
                          _buildTextField(
                            controller: _addressController,
                            label: 'Address (Optional)',
                            hint: 'Residential or local address',
                            prefixIcon: Icons.location_on_outlined,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 12),

                          // Notes Field
                          _buildTextField(
                            controller: _notesController,
                            label: 'Notes (Optional)',
                            hint: 'e.g. Shift preference, skills, Emergency contact',
                            prefixIcon: Icons.note_outlined,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 20),

                          // Wage & Payment Configuration Section
                          _buildSectionHeader('WAGE & PAYMENT CONFIGURATION'),
                          const SizedBox(height: 8),

                          const Text(
                            'Payment Type',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _buildPaymentTypeChip('Not Set', null),
                              _buildPaymentTypeChip('Hour Based', 'hour'),
                              _buildPaymentTypeChip('Nag / Piece Based', 'piece'),
                              _buildPaymentTypeChip('Both', 'both'),
                            ],
                          ),
                          const SizedBox(height: 12),

                          if (_paymentType == 'hour' || _paymentType == 'both') ...[
                            _buildTextField(
                              controller: _defaultHourRateController,
                              label: 'Default Hour Rate (₹) *',
                              hint: 'e.g. 100.00',
                              prefixIcon: Icons.access_time_outlined,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              hasError: _showErrors && !_isHourRateValid,
                              errorText: 'Enter a valid default hour rate (> 0)',
                              helperText: 'Saved default rate per hour for daily work entries',
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 12),
                          ],

                          if (_paymentType == 'piece' || _paymentType == 'both') ...[
                            _buildTextField(
                              controller: _defaultNagRateController,
                              label: 'Default Nag / Piece Rate (₹) *',
                              hint: 'e.g. 10.00',
                              prefixIcon: Icons.category_outlined,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              hasError: _showErrors && !_isNagRateValid,
                              errorText: 'Enter a valid default nag/piece rate (> 0)',
                              helperText: 'Saved default rate per piece for daily work entries',
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 12),
                          ],
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
                                context.go('/workers');
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
                            onPressed: _isSaving ? null : _handleSave,
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
                                : Text(isEditing ? 'Save Changes' : 'Save Worker'),
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

  Widget _buildPaymentTypeChip(String label, String? value) {
    final isSelected = _paymentType == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _paymentType = value;
          });
        }
      },
      selectedColor: AppColors.activePillBg,
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.borderLight,
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }
}
