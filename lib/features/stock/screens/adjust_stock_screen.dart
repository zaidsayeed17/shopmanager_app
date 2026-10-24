import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/item_model.dart';
import '../../../data/repositories/providers.dart';

class AdjustStockScreen extends ConsumerStatefulWidget {
  final String itemId;

  const AdjustStockScreen({
    super.key,
    required this.itemId,
  });

  @override
  ConsumerState<AdjustStockScreen> createState() => _AdjustStockScreenState();
}

class _AdjustStockScreenState extends ConsumerState<AdjustStockScreen> {
  final _qtyController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isIncrease = true;
  String _selectedReason = 'Recount / Correction';
  DateTime _selectedDate = DateTime.now();
  bool _showErrors = false;
  bool _dismissedErrorBanner = false;
  bool _isSaving = false;

  static const List<String> _reasons = [
    'Recount / Correction',
    'Damaged',
    'Wastage',
    'Lost',
    'Other',
  ];

  @override
  void dispose() {
    _qtyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double? get _parsedQty =>
      _qtyController.text.trim().isEmpty ? null : double.tryParse(_qtyController.text.trim());
  bool get _isQtyValid => _parsedQty != null && _parsedQty! > 0;

  bool _isExceedingStock(double currentQty) {
    if (!_isIncrease && _parsedQty != null) {
      return _parsedQty! > currentQty;
    }
    return false;
  }

  bool _isNotesValidForReason() {
    if (_selectedReason == 'Other') {
      return _notesController.text.trim().isNotEmpty;
    }
    return true;
  }

  bool _isFormValid(double currentQty) {
    return _isQtyValid && !_isExceedingStock(currentQty) && _isNotesValidForReason();
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatQty(double qty) {
    return qty.toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 2);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSave(ItemModel item) async {
    setState(() {
      _showErrors = true;
      _dismissedErrorBanner = false;
    });

    if (!_isFormValid(item.currentQty) || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final stockRepo = ref.read(stockRepositoryProvider);
      await stockRepo.recordAdjustment(
        itemId: item.id,
        isIncrease: _isIncrease,
        quantity: _parsedQty!,
        reason: _selectedReason,
        date: _selectedDate,
        notes: _notesController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adjustment saved'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );

      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/stock/${item.id}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving adjustment: $e'),
          backgroundColor: AppColors.critical,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final numericId = int.tryParse(widget.itemId) ?? 0;
    final itemAsync = ref.watch(itemByIdProvider(numericId));

    return itemAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Adjust Stock'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/stock'),
          ),
        ),
        body: Center(child: Text('Error: $err')),
      ),
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Adjust Stock')),
            body: const Center(child: Text('Item not found')),
          );
        }

        final currentQty = item.currentQty;
        final isExceeding = _isExceedingStock(currentQty);
        final newQty = _isQtyValid
            ? (_isIncrease ? (currentQty + _parsedQty!) : (currentQty - _parsedQty!))
            : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Adjust Stock'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/stock/${item.id}');
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
                              // Error Summary Banner
                              if (_showErrors && !_isFormValid(currentQty) && !_dismissedErrorBanner) ...[
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
                                            if (!_isQtyValid)
                                              const Text('• Enter a valid quantity greater than 0',
                                                  style: TextStyle(fontSize: 12, color: AppColors.critical)),
                                            if (isExceeding)
                                              Text(
                                                  '• Only ${_formatQty(currentQty)} ${item.unit} in stock. An adjustment can\'t take stock below zero.',
                                                  style: const TextStyle(fontSize: 12, color: AppColors.critical)),
                                            if (!_isNotesValidForReason())
                                              const Text('• Notes are required when reason is "Other"',
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

                              // Read-only Item Summary Chip
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.inventory_2_outlined,
                                          color: AppColors.primary, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: AppTypography.labelLg.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${item.isRawMaterial ? 'Raw Material' : 'Finished Product'} • Current Stock: ${_formatQty(currentQty)} ${item.unit}',
                                            style: AppTypography.bodySm.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Adjustment Type Toggle
                              _buildSectionHeader('ADJUSTMENT TYPE'),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isIncrease = true;
                                          });
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 150),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            color: _isIncrease ? AppColors.success : Colors.transparent,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Increase (+)',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: _isIncrease ? FontWeight.bold : FontWeight.w500,
                                              color: _isIncrease ? Colors.white : AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isIncrease = false;
                                          });
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 150),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            color: !_isIncrease ? AppColors.critical : Colors.transparent,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Decrease (−)',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: !_isIncrease ? FontWeight.bold : FontWeight.w500,
                                              color: !_isIncrease ? Colors.white : AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Quantity Field
                              _buildSectionHeader('QUANTITY & REASON'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _qtyController,
                                label: 'Adjustment Quantity *',
                                hint: '0',
                                prefixIcon: _isIncrease ? Icons.add_circle_outline : Icons.remove_circle_outline,
                                suffixText: item.unit,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                hasError: (_showErrors && !_isQtyValid) || isExceeding,
                                errorText: isExceeding
                                    ? 'Only ${_formatQty(currentQty)} ${item.unit} in stock. An adjustment can\'t take stock below zero.'
                                    : 'Quantity must be greater than 0',
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 16),

                              // Reason Chips Selector
                              Text(
                                'Reason *',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: _reasons.map((reason) {
                                  final isSelected = _selectedReason == reason;
                                  return ChoiceChip(
                                    label: Text(reason),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _selectedReason = reason;
                                        });
                                      }
                                    },
                                    selectedColor: AppColors.activePillBg,
                                    backgroundColor: AppColors.surface,
                                    side: BorderSide(
                                      color: isSelected ? AppColors.primary : AppColors.borderLight,
                                      width: isSelected ? 1.5 : 1.0,
                                    ),
                                    labelStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),

                              // Date Picker
                              InkWell(
                                onTap: _pickDate,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.borderLight),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today_outlined,
                                              size: 18, color: AppColors.textMuted),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Adjustment Date',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: AppColors.textMuted,
                                                ),
                                              ),
                                              Text(
                                                _formatDate(_selectedDate),
                                                style: AppTypography.bodyMd.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Icon(Icons.edit, size: 16, color: AppColors.primary),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Notes Field
                              _buildTextField(
                                controller: _notesController,
                                label: _selectedReason == 'Other' ? 'Notes (Required for "Other") *' : 'Notes / Explanation (Optional)',
                                hint: 'Provide details for this adjustment',
                                prefixIcon: Icons.note_outlined,
                                maxLines: 2,
                                hasError: _showErrors && !_isNotesValidForReason(),
                                errorText: 'Notes are required when reason is "Other"',
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 20),

                              // Live Preview Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isExceeding
                                      ? AppColors.criticalBg
                                      : (_isFormValid(currentQty) ? AppColors.activePillBg : AppColors.background),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isExceeding
                                        ? AppColors.critical.withValues(alpha: 0.5)
                                        : (_isFormValid(currentQty) ? AppColors.activePillBorder : AppColors.borderLight),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ADJUSTMENT PREVIEW',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                        color: isExceeding ? AppColors.critical : AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Stock after adjustment:',
                                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                        ),
                                        Text(
                                          (newQty != null && !isExceeding)
                                              ? '${_formatQty(currentQty)} → ${_formatQty(newQty)} ${item.unit}'
                                              : (isExceeding ? 'Exceeds Stock' : '--'),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isExceeding ? AppColors.critical : AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isExceeding) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        'Only ${_formatQty(currentQty)} ${item.unit} in stock. An adjustment can\'t take stock below zero.',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.critical,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Pinned Bottom Action Bar
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
                                    context.go('/stock/${item.id}');
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
                                onPressed: (_isFormValid(currentQty) && !_isSaving)
                                    ? () => _handleSave(item)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isIncrease ? AppColors.success : AppColors.critical,
                                  disabledBackgroundColor: AppColors.borderLight,
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
                                    : const Text('Save Adjustment'),
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
    String? suffixText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool hasError = false,
    String? errorText,
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
            suffixText: suffixText,
            suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
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
        ],
      ],
    );
  }
}
