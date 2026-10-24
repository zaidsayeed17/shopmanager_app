import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/providers.dart';

class ItemFormScreen extends ConsumerStatefulWidget {
  final String? itemId;
  final String? initialType;

  const ItemFormScreen({
    super.key,
    this.itemId,
    this.initialType,
  });

  @override
  ConsumerState<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends ConsumerState<ItemFormScreen> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _skuController = TextEditingController();
  final _unitController = TextEditingController();
  final _openingQtyController = TextEditingController();
  final _purchaseRateController = TextEditingController();
  final _sellingRateController = TextEditingController();
  final _wholesaleRateController = TextEditingController();
  final _minStockController = TextEditingController();
  final _supplierInfoController = TextEditingController();

  String _type = 'raw_material'; // 'raw_material', 'finished_product', or 'ready_stock'
  bool _isActive = true;
  bool _initialIsActive = true;
  bool _isSupplierExpanded = false;
  bool _showErrors = false;
  bool _dismissedErrorBanner = false;
  bool _isSaving = false;
  String? _duplicateNameError;

  bool get isEditing => widget.itemId != null;

  static const List<String> _unitChips = [
    'kg',
    'pcs',
    'meters',
    'rolls',
    'spools',
    'box',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null && widget.initialType!.isNotEmpty) {
      _type = widget.initialType!;
    }
    if (isEditing) {
      final id = int.tryParse(widget.itemId!);
      if (id != null) {
        Future.microtask(() async {
          final existing = await ref.read(itemRepositoryProvider).getItemById(id);
          if (existing != null && mounted) {
            setState(() {
              _nameController.text = existing.name;
              _categoryController.text = existing.category ?? '';
              _skuController.text = existing.sku ?? '';
              _type = existing.type;
              _unitController.text = existing.unit;
              _openingQtyController.text = existing.openingQty.toStringAsFixed(
                  existing.openingQty.truncateToDouble() == existing.openingQty ? 0 : 2);
              _purchaseRateController.text = existing.purchaseRate > 0
                  ? existing.purchaseRate.toStringAsFixed(
                      existing.purchaseRate.truncateToDouble() == existing.purchaseRate ? 0 : 2)
                  : '';
              _sellingRateController.text = existing.sellingRate > 0
                  ? existing.sellingRate.toStringAsFixed(
                      existing.sellingRate.truncateToDouble() == existing.sellingRate ? 0 : 2)
                  : '';
              _wholesaleRateController.text = (existing.wholesaleRate != null && existing.wholesaleRate! > 0)
                  ? existing.wholesaleRate!.toStringAsFixed(
                      existing.wholesaleRate!.truncateToDouble() == existing.wholesaleRate ? 0 : 2)
                  : '';
              _minStockController.text = existing.minStockLevel > 0
                  ? existing.minStockLevel.toStringAsFixed(
                      existing.minStockLevel.truncateToDouble() == existing.minStockLevel ? 0 : 2)
                  : '';
              _supplierInfoController.text = existing.supplierInfo ?? '';
              _isActive = existing.isActive;
              _initialIsActive = existing.isActive;

              if (existing.supplierInfo != null && existing.supplierInfo!.isNotEmpty) {
                _isSupplierExpanded = true;
              }
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _skuController.dispose();
    _unitController.dispose();
    _openingQtyController.dispose();
    _purchaseRateController.dispose();
    _sellingRateController.dispose();
    _wholesaleRateController.dispose();
    _minStockController.dispose();
    _supplierInfoController.dispose();
    super.dispose();
  }

  bool get _isNameValid => _nameController.text.trim().isNotEmpty;
  bool get _isUnitValid => _unitController.text.trim().isNotEmpty;

  double? get _parsedOpeningQty =>
      _openingQtyController.text.trim().isEmpty ? 0.0 : double.tryParse(_openingQtyController.text.trim());
  bool get _isOpeningQtyValid => _parsedOpeningQty != null && _parsedOpeningQty! >= 0;

  double? get _parsedPurchaseRate =>
      _purchaseRateController.text.trim().isEmpty ? 0.0 : double.tryParse(_purchaseRateController.text.trim());
  bool get _isPurchaseRateValid => _parsedPurchaseRate != null && _parsedPurchaseRate! >= 0;

  double? get _parsedSellingRate =>
      _sellingRateController.text.trim().isEmpty ? 0.0 : double.tryParse(_sellingRateController.text.trim());
  bool get _isSellingRateValid => _parsedSellingRate != null && _parsedSellingRate! >= 0;

  double? get _parsedWholesaleRate =>
      _wholesaleRateController.text.trim().isEmpty ? null : double.tryParse(_wholesaleRateController.text.trim());
  bool get _isWholesaleRateValid => _parsedWholesaleRate == null || _parsedWholesaleRate! >= 0;

  double? get _parsedMinStock =>
      _minStockController.text.trim().isEmpty ? 0.0 : double.tryParse(_minStockController.text.trim());
  bool get _isMinStockValid => _parsedMinStock != null && _parsedMinStock! >= 0;

  bool get _isFormValid =>
      _isNameValid &&
      _isUnitValid &&
      _isOpeningQtyValid &&
      _isPurchaseRateValid &&
      _isSellingRateValid &&
      _isWholesaleRateValid &&
      _isMinStockValid &&
      _duplicateNameError == null;

  Future<bool?> _showDeactivationDialog(String itemName) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Deactivate $itemName?'),
          content: const Text(
            'It won\'t appear when creating bills or issuing material. Its stock history is kept.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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

  Future<void> _handleSave() async {
    setState(() {
      _showErrors = true;
      _dismissedErrorBanner = false;
      _duplicateNameError = null;
    });

    if (!_isNameValid ||
        !_isUnitValid ||
        !_isOpeningQtyValid ||
        !_isPurchaseRateValid ||
        !_isSellingRateValid ||
        !_isWholesaleRateValid ||
        !_isMinStockValid ||
        _isSaving) {
      return;
    }

    final repo = ref.read(itemRepositoryProvider);
    final numericId = isEditing ? int.tryParse(widget.itemId!) : null;

    // Check duplicate name
    final nameExists = await repo.itemNameExists(
      _nameController.text,
      excludeId: numericId,
    );

    if (nameExists) {
      setState(() {
        _duplicateNameError = 'An item with this name already exists';
      });
      return;
    }

    // Check if deactivating active item
    if (isEditing && _initialIsActive && !_isActive) {
      final confirm = await _showDeactivationDialog(_nameController.text.trim());
      if (confirm != true) {
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (isEditing && numericId != null) {
        await repo.updateItem(
          id: numericId,
          name: _nameController.text,
          category: _categoryController.text,
          sku: _skuController.text,
          type: _type,
          unit: _unitController.text,
          purchaseRate: _parsedPurchaseRate ?? 0.0,
          sellingRate: _parsedSellingRate ?? 0.0,
          wholesaleRate: _parsedWholesaleRate,
          clearWholesaleRate: _parsedWholesaleRate == null,
          minStockLevel: _parsedMinStock ?? 0.0,
          supplierInfo: _supplierInfoController.text,
          isActive: _isActive,
        );
      } else {
        await repo.addItem(
          name: _nameController.text,
          category: _categoryController.text,
          sku: _skuController.text,
          type: _type,
          unit: _unitController.text,
          purchaseRate: _parsedPurchaseRate ?? 0.0,
          sellingRate: _parsedSellingRate ?? 0.0,
          wholesaleRate: _parsedWholesaleRate,
          openingQty: _parsedOpeningQty ?? 0.0,
          minStockLevel: _parsedMinStock ?? 0.0,
          supplierInfo: _supplierInfoController.text,
          isActive: _isActive,
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
        content: Text(isEditing ? 'Item profile updated' : 'Item saved'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );

    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/stock');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Item' : 'Add Item'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/stock');
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
                                        if (!_isNameValid)
                                          const Text('• Item name is required',
                                              style: TextStyle(fontSize: 12, color: AppColors.critical)),
                                        if (_duplicateNameError != null)
                                          Text('• $_duplicateNameError',
                                              style: const TextStyle(fontSize: 12, color: AppColors.critical)),
                                        if (!_isUnitValid)
                                          const Text('• Unit of measurement is required',
                                              style: TextStyle(fontSize: 12, color: AppColors.critical)),
                                        if (!_isOpeningQtyValid)
                                          const Text('• Enter a valid opening quantity',
                                              style: TextStyle(fontSize: 12, color: AppColors.critical)),
                                        if (!_isPurchaseRateValid)
                                          const Text('• Purchase rate cannot be negative',
                                              style: TextStyle(fontSize: 12, color: AppColors.critical)),
                                        if (!_isSellingRateValid)
                                          const Text('• Selling rate cannot be negative',
                                              style: TextStyle(fontSize: 12, color: AppColors.critical)),
                                        if (!_isMinStockValid)
                                          const Text('• Minimum stock level cannot be negative',
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
                                        'Item Status',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        _isActive
                                            ? 'Active (Visible in inventory and billing)'
                                            : 'Inactive (Hidden from dropdowns)',
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

                          // Segmented Item Type Selector
                          _buildSectionHeader('ITEM TYPE'),
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
                                        _type = 'raw_material';
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _type == 'raw_material' ? AppColors.secondary : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Raw Material',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: _type == 'raw_material' ? FontWeight.bold : FontWeight.w500,
                                          color: _type == 'raw_material' ? Colors.white : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _type = 'finished_product';
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _type == 'finished_product' ? AppColors.primary : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Finished Product',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: _type == 'finished_product' ? FontWeight.bold : FontWeight.w500,
                                          color: _type == 'finished_product' ? Colors.white : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Basic Details
                          _buildSectionHeader('BASIC DETAILS'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _nameController,
                            label: 'Item Name *',
                            hint: 'e.g. White Cement 50kg or MS Flange 2 inch',
                            prefixIcon: Icons.label_outlined,
                            hasError: (_showErrors && !_isNameValid) || _duplicateNameError != null,
                            errorText: _duplicateNameError ?? 'Item name is required',
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _categoryController,
                            label: 'Category (Optional)',
                            hint: 'e.g. Raw Material, Hardware, Electrical',
                            prefixIcon: Icons.category_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _skuController,
                            label: 'Product Code / SKU (Optional)',
                            hint: 'e.g. SKU-1001 or BAR-8901',
                            prefixIcon: Icons.qr_code_scanner_outlined,
                          ),
                          const SizedBox(height: 12),

                          // Unit Selection with Chips
                          _buildTextField(
                            controller: _unitController,
                            label: 'Unit of Measurement *',
                            hint: 'e.g. kg, pcs, meters',
                            prefixIcon: Icons.straighten_outlined,
                            hasError: _showErrors && !_isUnitValid,
                            errorText: 'Unit of measurement is required',
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: _unitChips.map((chip) {
                              final isSelected = _unitController.text.trim() == chip;
                              return ChoiceChip(
                                label: Text(chip),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _unitController.text = chip;
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
                          const SizedBox(height: 20),

                          // Inventory & Rates Section
                          _buildSectionHeader('INVENTORY & PRICING'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _openingQtyController,
                            label: 'Opening Quantity',
                            hint: '0',
                            prefixIcon: Icons.inventory_2_outlined,
                            keyboardType: TextInputType.number,
                            enabled: !isEditing,
                            hasError: _showErrors && !_isOpeningQtyValid,
                            errorText: 'Enter a valid opening quantity',
                            helperText: isEditing
                                ? "Opening quantity can't be changed here. Use stock adjustments to correct stock."
                                : 'Current quantity you already have in stock',
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _purchaseRateController,
                                  label: 'Purchase Rate (₹)',
                                  hint: '0.00',
                                  prefixIcon: Icons.currency_rupee,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  hasError: _showErrors && !_isPurchaseRateValid,
                                  errorText: 'Rate can\'t be negative',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: _sellingRateController,
                                  label: 'Selling Rate (₹)',
                                  hint: '0.00',
                                  prefixIcon: Icons.currency_rupee,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  hasError: _showErrors && !_isSellingRateValid,
                                  errorText: 'Rate can\'t be negative',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _wholesaleRateController,
                            label: 'Wholesale Rate (₹)',
                            hint: '0.00',
                            prefixIcon: Icons.currency_rupee,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            hasError: _showErrors && !_isWholesaleRateValid,
                            errorText: 'Rate can\'t be negative',
                            helperText: 'Optional. Leave blank to use the selling rate for wholesale customers.',
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _minStockController,
                            label: 'Minimum Stock Level (Optional)',
                            hint: '0',
                            prefixIcon: Icons.warning_amber_outlined,
                            keyboardType: TextInputType.number,
                            hasError: _showErrors && !_isMinStockValid,
                            errorText: 'Minimum stock level cannot be negative',
                            helperText: 'Get a low-stock warning when quantity drops to or below this',
                          ),
                          const SizedBox(height: 20),

                          // Collapsible Supplier Section
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isSupplierExpanded = !_isSupplierExpanded;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                      const Icon(
                                        Icons.local_shipping_outlined,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Supplier Details',
                                        style: AppTypography.labelLg.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    _isSupplierExpanded ? Icons.expand_less : Icons.expand_more,
                                    color: AppColors.textMuted,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_isSupplierExpanded) ...[
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _supplierInfoController,
                              label: 'Supplier Info / Vendor Name',
                              hint: 'e.g. UltraTech Dealer, Ahmedabad',
                              prefixIcon: Icons.store_outlined,
                              maxLines: 2,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Pinned Bottom Bar
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
                                context.go('/stock');
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
                                : Text(isEditing ? 'Save Changes' : 'Save Item'),
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
    bool enabled = true,
    bool hasError = false,
    String? errorText,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(prefixIcon, color: enabled ? AppColors.textMuted : AppColors.borderMedium),
            filled: true,
            fillColor: enabled ? AppColors.surface : AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError ? AppColors.critical : AppColors.borderLight,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderLight),
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
            style: TextStyle(
              fontSize: 11,
              color: enabled ? AppColors.textMuted : AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
