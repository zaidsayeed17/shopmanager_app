import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/item_model.dart';
import '../../../data/repositories/providers.dart';

class PurchaseFormScreen extends ConsumerStatefulWidget {
  final String itemId;

  const PurchaseFormScreen({
    super.key,
    required this.itemId,
  });

  @override
  ConsumerState<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends ConsumerState<PurchaseFormScreen> {
  final _qtyController = TextEditingController();
  final _rateController = TextEditingController();
  final _supplierController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _updateSavedRate = true;
  bool _showErrors = false;
  bool _dismissedErrorBanner = false;
  bool _isSaving = false;
  bool _isInitialized = false;

  @override
  void dispose() {
    _qtyController.dispose();
    _rateController.dispose();
    _supplierController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double? get _parsedQty =>
      _qtyController.text.trim().isEmpty ? null : double.tryParse(_qtyController.text.trim());
  bool get _isQtyValid => _parsedQty != null && _parsedQty! > 0;

  double? get _parsedRate =>
      _rateController.text.trim().isEmpty ? null : double.tryParse(_rateController.text.trim());
  bool get _isRateValid => _parsedRate != null && _parsedRate! >= 0;

  bool get _isFormValid => _isQtyValid && _isRateValid;

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

    if (!_isFormValid || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final stockRepo = ref.read(stockRepositoryProvider);
      await stockRepo.recordPurchase(
        itemId: item.id,
        quantity: _parsedQty!,
        unitRate: _parsedRate!,
        date: _selectedDate,
        supplier: _supplierController.text,
        notes: _notesController.text,
        updateItemRate: _updateSavedRate,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase saved'),
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
          content: Text('Error saving purchase: $e'),
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
          title: const Text('Add Stock'),
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
            appBar: AppBar(title: const Text('Add Stock')),
            body: const Center(child: Text('Item not found')),
          );
        }

        // Initialize controllers once with item data
        if (!_isInitialized) {
          _rateController.text = item.purchaseRate > 0 ? _formatQty(item.purchaseRate) : '';
          _supplierController.text = item.supplierInfo ?? '';
          _isInitialized = true;
        }

        final currentQty = item.currentQty;
        final newQty = _isQtyValid ? (currentQty + _parsedQty!) : null;
        final totalCost = (_isQtyValid && _isRateValid) ? (_parsedQty! * _parsedRate!) : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Add Stock'),
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
                                            if (!_isQtyValid)
                                              const Text('• Enter a valid quantity greater than 0',
                                                  style: TextStyle(fontSize: 12, color: AppColors.critical)),
                                            if (!_isRateValid)
                                              const Text('• Enter a valid purchase rate (>= 0)',
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

                              // Purchase Details Section
                              _buildSectionHeader('PURCHASE DETAILS'),
                              const SizedBox(height: 8),

                              // Quantity Field
                              _buildTextField(
                                controller: _qtyController,
                                label: 'Quantity Purchased *',
                                hint: '0',
                                prefixIcon: Icons.add_circle_outline,
                                suffixText: item.unit,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                hasError: _showErrors && !_isQtyValid,
                                errorText: 'Quantity must be greater than 0',
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 12),

                              // Purchase Rate Field
                              _buildTextField(
                                controller: _rateController,
                                label: 'Purchase Rate per unit (₹) *',
                                hint: '0.00',
                                prefixIcon: Icons.currency_rupee,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                hasError: _showErrors && !_isRateValid,
                                errorText: 'Purchase rate cannot be negative',
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 4),

                              // Checkbox to update saved purchase rate
                              CheckboxListTile(
                                value: _updateSavedRate,
                                onChanged: (val) {
                                  setState(() {
                                    _updateSavedRate = val ?? true;
                                  });
                                },
                                title: const Text(
                                  'Update this item\'s saved purchase rate',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                controlAffinity: ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              ),
                              const SizedBox(height: 12),

                              // Date Selector
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
                                                'Purchase Date',
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

                              // Supplier Field
                              _buildTextField(
                                controller: _supplierController,
                                label: 'Supplier / Vendor (Optional)',
                                hint: 'e.g. Sri Krishna Suppliers',
                                prefixIcon: Icons.store_outlined,
                              ),
                              const SizedBox(height: 12),

                              // Notes Field
                              _buildTextField(
                                controller: _notesController,
                                label: 'Notes / Invoice Ref (Optional)',
                                hint: 'e.g. Invoice #INV-891 or Cash Purchase',
                                prefixIcon: Icons.note_outlined,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 20),

                              // Live Preview Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _isFormValid ? AppColors.activePillBg : AppColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _isFormValid ? AppColors.activePillBorder : AppColors.borderLight,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'PURCHASE PREVIEW',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Stock after purchase:',
                                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                        ),
                                        Text(
                                          newQty != null
                                              ? '${_formatQty(currentQty)} → ${_formatQty(newQty)} ${item.unit}'
                                              : '--',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Purchase total amount:',
                                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                        ),
                                        Text(
                                          totalCost != null
                                              ? '₹ ${_formatQty(totalCost)}'
                                              : '--',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.success,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (!_isQtyValid) ...[
                                      const SizedBox(height: 6),
                                      const Row(
                                        children: [
                                          Icon(Icons.info_outline, size: 14, color: AppColors.tertiary),
                                          SizedBox(width: 4),
                                          Text(
                                            'Needs quantity to compute preview',
                                            style: TextStyle(fontSize: 11, color: AppColors.tertiary),
                                          ),
                                        ],
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
                                onPressed: (_isFormValid && !_isSaving)
                                    ? () => _handleSave(item)
                                    : null,
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
                                    : const Text('Save Purchase'),
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
