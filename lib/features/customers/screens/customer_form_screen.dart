import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/providers.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  final String? customerId;

  const CustomerFormScreen({
    super.key,
    this.customerId,
  });

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstinController = TextEditingController();
  final _tradeNameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isWholesale = false;
  bool _isActive = true;
  bool _isGstExpanded = false;
  bool _showErrors = false;
  bool _dismissedErrorBanner = false;
  bool _isSaving = false;

  bool get isEditing => widget.customerId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final id = int.tryParse(widget.customerId!);
      if (id != null) {
        Future.microtask(() async {
          final existing = await ref.read(customerRepositoryProvider).getCustomerById(id);
          if (existing != null && mounted) {
            setState(() {
              _nameController.text = existing.name;
              _mobileController.text = existing.mobile;
              _addressController.text = existing.address ?? '';
              _gstinController.text = existing.gstin ?? '';
              _balanceController.text = existing.openingBalance > 0
                  ? existing.openingBalance.toStringAsFixed(0)
                  : '';
              _notesController.text = existing.notes ?? '';
              _isWholesale = existing.isWholesale;
              _isActive = existing.isActive;

              if (existing.gstin != null && existing.gstin!.isNotEmpty) {
                _isGstExpanded = true;
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
    _mobileController.dispose();
    _addressController.dispose();
    _gstinController.dispose();
    _tradeNameController.dispose();
    _balanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickContact() async {
    try {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null) {
        final name = contact.displayName;
        String mobile = '';
        if (contact.phones.isNotEmpty) {
          final raw = contact.phones.first.number;
          mobile = raw.replaceAll(RegExp(r'\D'), '');
          if (mobile.length > 10) {
            mobile = mobile.substring(mobile.length - 10);
          }
        }
        setState(() {
          if (name.trim().isNotEmpty) {
            _nameController.text = name.trim();
          }
          if (mobile.trim().isNotEmpty) {
            _mobileController.text = mobile.trim();
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not import contact: $e')),
      );
    }
  }

  bool get _isNameValid => _nameController.text.trim().isNotEmpty;
  bool get _isMobileValid =>
      RegExp(r'^\d{10}$').hasMatch(_mobileController.text.trim());

  Future<void> _handleSave({bool ignoreMobileWarning = false}) async {
    setState(() {
      _showErrors = true;
      _dismissedErrorBanner = false;
    });

    if (!_isNameValid || !_isMobileValid || _isSaving) {
      return;
    }

    final repo = ref.read(customerRepositoryProvider);
    final currentId = isEditing ? int.tryParse(widget.customerId!) : null;

    // 1. Case-insensitive Duplicate Name Check (Hard Block)
    final isNameDuplicate = await repo.customerNameExists(_nameController.text, excludeId: currentId);
    if (isNameDuplicate) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A customer with this name already exists. Please use a unique name.'),
          backgroundColor: AppColors.critical,
        ),
      );
      return;
    }

    // 2. Duplicate Mobile Check (Soft Warning)
    if (!ignoreMobileWarning) {
      final existingWithMobile = await repo.findCustomerByMobile(_mobileController.text, excludeId: currentId);
      if (existingWithMobile != null) {
        if (!mounted) return;
        final shouldProceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Duplicate Mobile Number'),
            content: Text(
              'A customer with this mobile number already exists (${existingWithMobile.name}). Continue anyway?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Continue Anyway'),
              ),
            ],
          ),
        );

        if (shouldProceed != true) {
          return;
        }
      }
    }

    setState(() {
      _isSaving = true;
    });

    final openingBal = double.tryParse(_balanceController.text.trim()) ?? 0.0;

    try {
      if (isEditing) {
        if (currentId != null) {
          await repo.updateCustomer(
            id: currentId,
            name: _nameController.text,
            mobile: _mobileController.text,
            address: _addressController.text,
            gstin: _gstinController.text,
            openingBalance: openingBal,
            notes: _notesController.text,
            isWholesale: _isWholesale,
            isActive: _isActive,
          );
        }
      } else {
        await repo.addCustomer(
          name: _nameController.text,
          mobile: _mobileController.text,
          address: _addressController.text,
          gstin: _gstinController.text,
          openingBalance: openingBal,
          notes: _notesController.text,
          isWholesale: _isWholesale,
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
        content: Text(isEditing
            ? 'Customer profile updated'
            : 'New customer added successfully'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );

    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/customers');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Customer' : 'Add Customer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/customers');
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
                          if (_showErrors &&
                              (!_isNameValid || !_isMobileValid) &&
                              !_dismissedErrorBanner) ...[
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
                                          'Please fix the following errors before saving:',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.critical,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (!_isNameValid)
                                          const Text(
                                            '• Customer name is required',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.critical,
                                            ),
                                          ),
                                        if (!_isMobileValid)
                                          const Text(
                                            '• Enter a valid 10-digit mobile number',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.critical,
                                            ),
                                          ),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
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
                                        'Customer Account Status',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        _isActive
                                            ? 'Active (Visible in transaction pickers)'
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
                                      final id = int.tryParse(widget.customerId!);
                                      if (id != null) {
                                        ref
                                            .read(customerRepositoryProvider)
                                            .setCustomerActive(id, val);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Basic Information Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionHeader('BASIC INFORMATION'),
                              TextButton.icon(
                                onPressed: _pickContact,
                                icon: const Icon(Icons.contacts, size: 16, color: AppColors.primary),
                                label: const Text(
                                  'Import from Contacts',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _nameController,
                            label: 'Customer Name *',
                            hint: 'e.g. Rajesh Kumar (Sri Krishna Traders)',
                            prefixIcon: Icons.person_outline,
                            hasError: _showErrors && !_isNameValid,
                            errorText: 'Customer name is required',
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _mobileController,
                            label: 'Mobile Number *',
                            hint: '10-digit mobile number',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            hasError: _showErrors && !_isMobileValid,
                            errorText: 'Enter a valid 10-digit mobile number',
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _addressController,
                            label: 'Address (Optional)',
                            hint: 'Shop / Factory address',
                            prefixIcon: Icons.location_on_outlined,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 20),

                          // Financial Setup Section
                          _buildSectionHeader('FINANCIAL SETUP'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _balanceController,
                            label: 'Opening Balance (₹)',
                            hint: '0',
                            prefixIcon: Icons.currency_rupee,
                            keyboardType: TextInputType.number,
                            helperText:
                                'Positive value = Customer owes you money. Leave 0 for new accounts.',
                          ),
                          const SizedBox(height: 20),

                          // GST & Business Details Collapsible Section
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isGstExpanded = !_isGstExpanded;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.business_outlined,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'GSTIN & Business Details',
                                        style: AppTypography.labelLg.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    _isGstExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: AppColors.textMuted,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_isGstExpanded) ...[
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _gstinController,
                              label: 'GSTIN',
                              hint: 'e.g. 24AABCS1429B1Z',
                              prefixIcon: Icons.receipt_long_outlined,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _tradeNameController,
                              label: 'Trade / Firm Name',
                              hint: 'e.g. Sri Krishna Traders',
                              prefixIcon: Icons.store_outlined,
                            ),
                          ],
                          const SizedBox(height: 20),

                          // Account Classification Section
                          _buildSectionHeader('ACCOUNT CLASSIFICATION'),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isWholesale ? AppColors.activePillBg : AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _isWholesale ? AppColors.primary : AppColors.borderLight,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.storefront_outlined,
                                          size: 20,
                                          color: _isWholesale ? AppColors.primary : AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Wholesale Customer',
                                          style: AppTypography.bodyMd.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Switch(
                                      value: _isWholesale,
                                      onChanged: (val) {
                                        setState(() {
                                          _isWholesale = val;
                                        });
                                      },
                                      activeThumbColor: AppColors.primary,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Wholesale customers can have a manually adjusted rate per item on each bill, separate from the normal MRP.',
                                  style: AppTypography.bodySm.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Notes Section
                          _buildSectionHeader('ADDITIONAL NOTES'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _notesController,
                            label: 'Notes / Payment Terms',
                            hint: 'e.g. Preferred dispatch via tempo, Saturday payment terms',
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
                                context.go('/customers');
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
                                : Text(isEditing
                                    ? 'Save Changes'
                                    : 'Create Customer'),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(prefixIcon, color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
