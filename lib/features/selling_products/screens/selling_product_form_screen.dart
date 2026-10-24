import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/providers.dart';

class SellingProductFormScreen extends ConsumerStatefulWidget {
  final String? productId;

  const SellingProductFormScreen({super.key, this.productId});

  @override
  ConsumerState<SellingProductFormScreen> createState() => _SellingProductFormScreenState();
}

class _SellingProductFormScreenState extends ConsumerState<SellingProductFormScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController(); // Retail price
  final _wholesalePriceController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isActive = true;
  bool _showErrors = false;
  bool _isSaving = false;

  bool get isEditing => widget.productId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final id = int.tryParse(widget.productId!);
      if (id != null) {
        Future.microtask(() async {
          final existing = await ref.read(sellingProductRepositoryProvider).getProductById(id);
          if (existing != null && mounted) {
            setState(() {
              _nameController.text = existing.name;
              _priceController.text = existing.price.toStringAsFixed(
                  existing.price.truncateToDouble() == existing.price ? 0 : 2);
              _wholesalePriceController.text = existing.wholesalePrice != null
                  ? existing.wholesalePrice!.toStringAsFixed(
                      existing.wholesalePrice!.truncateToDouble() == existing.wholesalePrice ? 0 : 2)
                  : '';
              _descriptionController.text = existing.description ?? '';
              _isActive = existing.isActive;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _wholesalePriceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isNameValid => _nameController.text.trim().isNotEmpty;

  double? get _parsedPrice => double.tryParse(_priceController.text.trim());
  bool get _isPriceValid => _parsedPrice != null && _parsedPrice! > 0;

  double? get _parsedWholesalePrice =>
      _wholesalePriceController.text.trim().isEmpty ? null : double.tryParse(_wholesalePriceController.text.trim());
  bool get _isWholesalePriceValid => _parsedWholesalePrice == null || _parsedWholesalePrice! > 0;

  bool get _isWholesaleHigherThanRetail =>
      _parsedPrice != null &&
      _parsedWholesalePrice != null &&
      _parsedWholesalePrice! > _parsedPrice!;

  bool get _isFormValid => _isNameValid && _isPriceValid && _isWholesalePriceValid;

  Future<void> _handleSave() async {
    setState(() {
      _showErrors = true;
    });

    if (!_isFormValid || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repo = ref.read(sellingProductRepositoryProvider);
      final numericId = isEditing ? int.tryParse(widget.productId!) : null;

      if (isEditing && numericId != null) {
        await repo.updateProduct(
          id: numericId,
          name: _nameController.text,
          price: _parsedPrice!,
          wholesalePrice: _parsedWholesalePrice,
          description: _descriptionController.text,
          isActive: _isActive,
        );
      } else {
        await repo.addProduct(
          name: _nameController.text,
          price: _parsedPrice!,
          wholesalePrice: _parsedWholesalePrice,
          description: _descriptionController.text,
          isActive: _isActive,
        );
      }

      ref.invalidate(sellingProductsStreamProvider);
      ref.invalidate(activeSellingProductsStreamProvider);
      ref.invalidate(billableProductsStreamProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Product updated successfully' : 'Product added successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save product: $e'),
          backgroundColor: AppColors.critical,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Selling Product' : 'Add Selling Product'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _handleSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check, size: 18),
              label: Text(isEditing ? 'Save Changes' : 'Add Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= AppConstants.tabletBreakpoint;
          final padding = isTablet ? 24.0 : 16.0;

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: isTablet ? 600 : double.infinity),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info Header Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.all_inclusive, color: AppColors.primary, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Products you make yourself — unlimited, no stock tracking.',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Form container
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Product Name
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Product Name *',
                              hintText: 'e.g. Custom T-Shirt Printing, Premium Kurti',
                              prefixIcon: const Icon(Icons.shopping_bag_outlined),
                              errorText: _showErrors && !_isNameValid ? 'Product name is required' : null,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Retail Price & Wholesale Price
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _priceController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    labelText: 'Retail Price (₹) *',
                                    hintText: '0.00',
                                    prefixIcon: const Icon(Icons.currency_rupee),
                                    errorText: _showErrors && !_isPriceValid ? 'Enter a valid price > 0' : null,
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: _wholesalePriceController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    labelText: 'Wholesale Price (₹)',
                                    hintText: 'Optional',
                                    helperText: 'Leave blank to charge wholesale customers the retail price.',
                                    helperMaxLines: 2,
                                    prefixIcon: const Icon(Icons.storefront_outlined),
                                    errorText: _showErrors && !_isWholesalePriceValid ? 'Must be > 0' : null,
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Non-blocking hint if wholesale > retail
                          if (_isWholesaleHigherThanRetail) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.tertiary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline, size: 18, color: AppColors.tertiary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Wholesale price is higher than retail — is that intended?',
                                      style: AppTypography.bodySm.copyWith(
                                        color: AppColors.tertiary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),

                          // Description
                          TextField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Description (Optional)',
                              hintText: 'Notes, variations, or manufacturing details...',
                              prefixIcon: Icon(Icons.notes_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Active Status switch
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Active for Billing', style: TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: const Text('Inactive products will not appear in Create Bill or Quick Sale'),
                            value: _isActive,
                            onChanged: (val) {
                              setState(() {
                                _isActive = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
