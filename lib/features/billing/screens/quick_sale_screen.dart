import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/payment_method_utils.dart';
import '../../../data/models/bill_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/billable_product_model.dart';
import '../../../data/repositories/providers.dart';
import '../../../services/pdf_service.dart';
import '../../../services/whatsapp_share_service.dart';
import '../widgets/billing_product_picker_dialog.dart';

enum QuickSaleCustomerMode { walkIn, existing, newCustomer }

class QuickSaleLineItem {
  final BillableProduct product;
  double quantity;
  double rate;
  bool manuallyEditedRate;

  QuickSaleLineItem({
    required this.product,
    this.quantity = 1.0,
    required this.rate,
    this.manuallyEditedRate = false,
  });

  double get amount => (quantity * rate * 100).round() / 100.0;
}

class QuickSaleScreen extends ConsumerStatefulWidget {
  const QuickSaleScreen({super.key});

  @override
  ConsumerState<QuickSaleScreen> createState() => _QuickSaleScreenState();
}

class _QuickSaleScreenState extends ConsumerState<QuickSaleScreen> {
  final _searchController = TextEditingController();
  final _discountController = TextEditingController();
  final _gstPercentController = TextEditingController();
  final _amountReceivedController = TextEditingController();
  final _notesController = TextEditingController();

  // Inline Quick-Add Customer Controllers
  final _newCustNameController = TextEditingController();
  final _newCustMobileController = TextEditingController();

  QuickSaleCustomerMode _customerMode = QuickSaleCustomerMode.walkIn;
  Customer? _selectedCustomer;

  List<QuickSaleLineItem> _lineItems = [];
  List<BillableProduct> _searchResults = [];
  bool _isSearching = false;

  bool _gstEnabled = false;

  String _paymentMethod = 'Cash'; // Cash, UPI, Bank, Card, Credit, Other

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _gstPercentController.text = '18';
  }

  void _repriceUneditedLines() {
    final isWholesale = _customerMode == QuickSaleCustomerMode.existing && (_selectedCustomer?.isWholesale ?? false);
    for (final line in _lineItems) {
      if (!line.manuallyEditedRate) {
        line.rate = line.product.priceForCustomer(isWholesale);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _discountController.dispose();
    _gstPercentController.dispose();
    _amountReceivedController.dispose();
    _notesController.dispose();
    _newCustNameController.dispose();
    _newCustMobileController.dispose();
    super.dispose();
  }

  double get _subtotal {
    double total = 0.0;
    for (final line in _lineItems) {
      total += line.amount;
    }
    return (total * 100).round() / 100.0;
  }

  double get _discount => double.tryParse(_discountController.text.trim()) ?? 0.0;

  double get _taxableAmount {
    final sub = _subtotal;
    final disc = _discount;
    final taxable = sub - disc;
    return taxable < 0 ? 0.0 : (taxable * 100).round() / 100.0;
  }

  double get _gstAmount {
    if (!_gstEnabled) return 0.0;
    final percent = double.tryParse(_gstPercentController.text.trim()) ?? 0.0;
    return (_taxableAmount * percent / 100.0 * 100).round() / 100.0;
  }

  double get _grandTotal {
    return ((_taxableAmount + _gstAmount) * 100).roundToDouble() / 100.0;
  }

  double get _effectiveAmountReceived {
    if (_customerMode == QuickSaleCustomerMode.walkIn) {
      return _grandTotal;
    }
    if (_paymentMethod == 'Credit') {
      return 0.0;
    }
    final entered = double.tryParse(_amountReceivedController.text.trim()) ?? 0.0;
    return entered;
  }

  double get _advanceToApply => 0.0;

  BillPaymentStatus get _statusPreview {
    if (_customerMode == QuickSaleCustomerMode.walkIn) {
      return BillPaymentStatus.paid;
    }
    final totalPaid = _advanceToApply + _effectiveAmountReceived;
    final remaining = _grandTotal - totalPaid;
    return computeBillStatus(
      status: 'active',
      remainingBalance: remaining < 0 ? 0.0 : remaining,
      grandTotal: _grandTotal,
      amountPaid: totalPaid,
    );
  }

  void _onSearchChanged(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    setState(() {
      _isSearching = true;
    });
    final itemRepo = ref.read(itemRepositoryProvider);
    final sellingRepo = ref.read(sellingProductRepositoryProvider);

    final itemResults = await itemRepo.searchItems(q);
    final sellingResults = await sellingRepo.searchProducts(q);

    if (mounted) {
      final combined = <BillableProduct>[
        ...sellingResults.where((p) => p.isActive).map(BillableProduct.fromSellingProduct),
        ...itemResults.where((i) => i.isActive).map(BillableProduct.fromItem),
      ];
      setState(() {
        _searchResults = combined;
        _isSearching = false;
      });
    }
  }

  void _addProductToCart(BillableProduct product) {
    final isWholesale = _customerMode == QuickSaleCustomerMode.existing && (_selectedCustomer?.isWholesale ?? false);
    final unitPrice = product.priceForCustomer(isWholesale);

    setState(() {
      final index = _lineItems.indexWhere(
        (l) => l.product.source == product.source && l.product.id == product.id,
      );
      if (index >= 0) {
        _lineItems[index].quantity += 1.0;
      } else {
        _lineItems.add(QuickSaleLineItem(
          product: product,
          quantity: 1.0,
          rate: unitPrice,
          manuallyEditedRate: false,
        ));
      }
      _searchController.clear();
      _searchResults = [];
    });
  }

  Future<void> _handleInlineCreateCustomer() async {
    final name = _newCustNameController.text.trim();
    final mobile = _newCustMobileController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer name is required')),
      );
      return;
    }

    if (mobile.isNotEmpty && !RegExp(r'^\d{10}$').hasMatch(mobile)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit mobile number')),
      );
      return;
    }

    final custRepo = ref.read(customerRepositoryProvider);
    try {
      final newId = await custRepo.addCustomer(
        name: name,
        mobile: mobile,
      );
      final newCust = await custRepo.getCustomerById(newId);
      if (newCust != null && mounted) {
        setState(() {
          _selectedCustomer = newCust;
          _customerMode = QuickSaleCustomerMode.existing;
          _newCustNameController.clear();
          _newCustMobileController.clear();
          _repriceUneditedLines();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer "${newCust.name}" created and attached!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '').replaceAll('ArgumentError: ', '')),
            backgroundColor: AppColors.critical,
          ),
        );
      }
    }
  }

  Future<void> _handleCompleteSale() async {
    if (_lineItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one product to complete sale.')),
      );
      return;
    }

    for (final line in _lineItems) {
      if (line.quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quantity for ${line.product.name} must be greater than zero.')),
        );
        return;
      }
    }

    if (_customerMode == QuickSaleCustomerMode.existing && _selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an existing customer or switch to Walk-in.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repo = ref.read(billingRepositoryProvider);
      final customerId = _customerMode == QuickSaleCustomerMode.existing ? _selectedCustomer?.id : null;

      final lines = _lineItems.map((l) => BillLine(
        itemId: l.product.isStock ? l.product.id : null,
        sellingProductId: l.product.isOwn ? l.product.id : null,
        productName: l.product.name,
        unit: l.product.unit,
        quantity: l.quantity,
        rate: l.rate,
        mrpRateAtSale: l.product.retailPrice,
      )).toList();

      final generatedNum = await repo.saveBill(
        saleChannel: 'quick_sale',
        customerId: customerId,
        billDate: DateTime.now(),
        lines: lines,
        discount: _discount,
        gstEnabled: _gstEnabled,
        gstPercent: _gstEnabled ? (double.tryParse(_gstPercentController.text.trim()) ?? 18.0) : null,
        advanceToApply: _advanceToApply,
        amountReceived: _effectiveAmountReceived,
        paymentMethod: PaymentMethodUtils.toKey(_paymentMethod),
        notes: _notesController.text,
      );

      ref.invalidate(todaysQuickSaleSummaryProvider);
      ref.invalidate(todaysSalesSummaryProvider);
      ref.invalidate(billsStreamProvider);

      if (!mounted) return;

      // Show Success Dialog with direct next actions
      _showSuccessDialog(generatedNum);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '').replaceAll('ArgumentError: ', '')),
          backgroundColor: AppColors.critical,
        ),
      );
    }
  }

  void _showSuccessDialog(String billNumber) async {
    final billingRepo = ref.read(billingRepositoryProvider);
    final bills = await billingRepo.getQuickSales(statusFilter: 'all');
    final savedBillModel = bills.firstWhere((b) => b.billNumber == billNumber, orElse: () => bills.first);
    final billDetailData = await billingRepo.getBillDetail(savedBillModel.id);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        final profile = ref.read(businessProfileProvider).value;
        final isWalkIn = savedBillModel.isWalkIn;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.successBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: AppColors.success, size: 28),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Sale Complete!',
                    style: AppTypography.headlineMd.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    billNumber,
                    style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Paid: ₹${savedBillModel.grandTotal.toStringAsFixed(2)} (${savedBillModel.customerName})',
                style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              const Text(
                'What would you like to do next?',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(dialogCtx).pop();
                    context.go('/quick-sale/history');
                  },
                  icon: const Icon(Icons.history, size: 16),
                  label: const Text('History'),
                ),
                if (billDetailData != null) ...[
                  IconButton(
                    icon: const Icon(Icons.print, color: AppColors.primary),
                    tooltip: 'Print Receipt',
                    onPressed: () async {
                      try {
                        final pdfBytes = await PdfService.generateBillPdf(billDetailData, businessProfile: profile);
                        await Printing.layoutPdf(
                          onLayout: (_) async => pdfBytes,
                          name: 'Receipt_${savedBillModel.billNumber}',
                        );
                      } catch (_) {}
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: AppColors.primary),
                    tooltip: 'Share PDF',
                    onPressed: () async {
                      try {
                        final pdfBytes = await PdfService.generateBillPdf(billDetailData, businessProfile: profile);
                        final pdfFile = await PdfService.savePdfToTempFile(pdfBytes, savedBillModel.billNumber);
                        await Share.shareXFiles([XFile(pdfFile.path, mimeType: 'application/pdf')]);
                      } catch (_) {}
                    },
                  ),
                  if (!isWalkIn)
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF25D366)),
                      tooltip: 'WhatsApp Receipt',
                      onPressed: () {
                        WhatsAppShareService.shareBillOnWhatsApp(context, billDetailData, businessProfile: profile);
                      },
                    ),
                ],
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(dialogCtx).pop();
                    setState(() {
                      _lineItems = [];
                      _discountController.clear();
                      _notesController.clear();
                      _amountReceivedController.clear();
                      _customerMode = QuickSaleCustomerMode.walkIn;
                      _selectedCustomer = null;
                      _isSaving = false;
                    });
                  },
                  icon: const Icon(Icons.flash_on),
                  label: const Text('New Quick Sale'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.accentSecondaryBg,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accentSecondary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'QUICK SALE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Direct Selling',
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/billing');
            }
          },
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/quick-sale/history'),
            icon: const Icon(Icons.history, size: 18),
            label: const Text('QS History'),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= AppConstants.tabletBreakpoint;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CUSTOMER SECTION
                      _buildCustomerSection(customersAsync),
                      const SizedBox(height: 16),

                      // PRODUCT SEARCH & PICKER
                      _buildProductSearchSection(),
                      const SizedBox(height: 16),

                      // LINE ITEMS CART LIST
                      if (_lineItems.isNotEmpty) ...[
                        _buildLineItemsList(),
                        const SizedBox(height: 16),
                      ],

                      // DISCOUNT & GST SECTION
                      _buildDiscountGstSection(),
                      const SizedBox(height: 16),

                      // PAYMENT SECTION
                      _buildPaymentSection(),
                      const SizedBox(height: 16),

                      // LIVE TOTALS & STATUS PREVIEW
                      _buildTotalsPreviewCard(),
                    ],
                  ),
                ),
              ),

              // PINNED BOTTOM BAR
              _buildBottomBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCustomerSection(AsyncValue<List<Customer>> customersAsync) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CUSTOMER SELECTION',
                  style: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (_customerMode == QuickSaleCustomerMode.existing && _selectedCustomer != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Selected: ${_selectedCustomer!.name}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      if (_selectedCustomer!.isWholesale) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'WHOLESALE',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // 3 Customer Options Segmented Buttons
            Row(
              children: [
                Expanded(
                  child: _buildCustomerChoiceChip(
                    label: 'Walk-in (No Customer)',
                    icon: Icons.directions_walk,
                    isSelected: _customerMode == QuickSaleCustomerMode.walkIn,
                    onTap: () {
                      setState(() {
                        _customerMode = QuickSaleCustomerMode.walkIn;
                        _selectedCustomer = null;
                        _repriceUneditedLines();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildCustomerChoiceChip(
                    label: 'Select Customer',
                    icon: Icons.person_search,
                    isSelected: _customerMode == QuickSaleCustomerMode.existing,
                    onTap: () {
                      setState(() {
                        _customerMode = QuickSaleCustomerMode.existing;
                        _repriceUneditedLines();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildCustomerChoiceChip(
                    label: '+ New Customer',
                    icon: Icons.person_add_alt_1,
                    isSelected: _customerMode == QuickSaleCustomerMode.newCustomer,
                    onTap: () {
                      setState(() {
                        _customerMode = QuickSaleCustomerMode.newCustomer;
                        _selectedCustomer = null;
                        _repriceUneditedLines();
                      });
                    },
                  ),
                ),
              ],
            ),

            // Mode-specific Customer Input Bodies
            if (_customerMode == QuickSaleCustomerMode.existing) ...[
              const SizedBox(height: 12),
              customersAsync.when(
                data: (customers) {
                  return DropdownButtonFormField<Customer>(
                    value: _selectedCustomer,
                    hint: const Text('Search / Select Existing Customer'),
                    isExpanded: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                    items: customers.map((c) {
                      return DropdownMenuItem<Customer>(
                        value: c,
                        child: Text('${c.name} (${c.mobile})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCustomer = val;
                        _repriceUneditedLines();
                      });
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text('Error loading customers: $e', style: const TextStyle(color: AppColors.critical)),
              ),
            ],

            if (_customerMode == QuickSaleCustomerMode.newCustomer) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QUICK ADD NEW CUSTOMER',
                      style: AppTypography.labelSm.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newCustNameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name *',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: AppColors.surface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _newCustMobileController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            decoration: InputDecoration(
                              labelText: 'Mobile Number',
                              counterText: '',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: AppColors.surface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _handleInlineCreateCustomer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                          child: const Text('Add & Attach'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerChoiceChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentSecondary : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.accentSecondary : AppColors.borderLight,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSearchSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'FAST PRODUCT SEARCH',
                  style: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    BillingProductPickerDialog.show(
                      context,
                      isWholesaleCustomer: _customerMode == QuickSaleCustomerMode.existing && (_selectedCustomer?.isWholesale ?? false),
                      onProductSelected: (p) => _addProductToCart(p),
                    );
                  },
                  icon: const Icon(Icons.grid_view, size: 16),
                  label: const Text('Browse Products'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search stock items or manufactured products...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            if (_isSearching) ...[
              const SizedBox(height: 8),
              const LinearProgressIndicator(),
            ],

            if (_searchResults.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 240),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderMedium),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.borderLight),
                  itemBuilder: (context, idx) {
                    final product = _searchResults[idx];
                    final isWholesale = _customerMode == QuickSaleCustomerMode.existing && (_selectedCustomer?.isWholesale ?? false);
                    final price = product.priceForCustomer(isWholesale);

                    return ListTile(
                      dense: true,
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: product.isOwn
                                  ? Colors.purple.withValues(alpha: 0.1)
                                  : AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: product.isOwn
                                    ? Colors.purple.withValues(alpha: 0.3)
                                    : AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              product.isOwn ? 'Our Product' : 'Stock',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: product.isOwn ? Colors.purple[700] : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        '${product.category ?? "General"} • ${isWholesale ? "Wholesale" : "Rate"}: ₹${price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            product.isStock
                                ? '${product.currentQty % 1 == 0 ? product.currentQty.toInt() : product.currentQty.toStringAsFixed(1)} ${product.unit}'
                                : 'Unlimited',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: product.isStock && product.currentQty <= 0
                                  ? AppColors.critical
                                  : AppColors.success,
                            ),
                          ),
                          const Text('+ Add', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      onTap: () => _addProductToCart(product),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLineItemsList() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SELECTED PRODUCTS (${_lineItems.length})',
                  style: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Subtotal: ₹${_subtotal.toStringAsFixed(2)}',
                  style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _lineItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final line = _lineItems[index];
                final product = line.product;
                final isOverStock = product.isStock && line.quantity > product.currentQty;

                return Container(
                  key: ValueKey('qs_line_${product.source.name}_${product.id}'),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isOverStock ? AppColors.warningBg : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isOverStock ? AppColors.warning : AppColors.borderLight,
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
                              Text(
                                product.name,
                                style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: product.isOwn
                                      ? Colors.purple.withValues(alpha: 0.1)
                                      : AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: product.isOwn
                                        ? Colors.purple.withValues(alpha: 0.3)
                                        : AppColors.primary.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  product.isOwn ? 'Our Product' : 'Stock',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: product.isOwn ? Colors.purple[700] : AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.critical),
                            onPressed: () {
                              setState(() {
                                _lineItems.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          // Quantity Control
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Qty (${product.unit})', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                const SizedBox(height: 2),
                                TextFormField(
                                  initialValue: line.quantity % 1 == 0 ? line.quantity.toInt().toString() : line.quantity.toString(),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                    filled: true,
                                    fillColor: AppColors.surface,
                                  ),
                                  onChanged: (val) {
                                    final parsed = double.tryParse(val.trim());
                                    if (parsed != null && parsed >= 0) {
                                      setState(() {
                                        line.quantity = parsed;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Rate Control
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Builder(
                                  builder: (context) {
                                    final isWholesale = _customerMode == QuickSaleCustomerMode.existing && (_selectedCustomer?.isWholesale ?? false);
                                    final mrpStr = product.retailPrice.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isWholesale ? 'Wholesale Rate' : 'Rate (₹)',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isWholesale ? FontWeight.bold : FontWeight.normal,
                                            color: isWholesale ? AppColors.primary : AppColors.textSecondary,
                                          ),
                                        ),
                                        if (isWholesale && product.retailPrice > 0)
                                          Text(
                                            'MRP ₹$mrpStr',
                                            style: const TextStyle(
                                              fontSize: 9,
                                              color: AppColors.textMuted,
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 2),
                                TextFormField(
                                  initialValue: line.rate % 1 == 0 ? line.rate.toInt().toString() : line.rate.toStringAsFixed(2),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                    filled: true,
                                    fillColor: AppColors.surface,
                                  ),
                                  onChanged: (val) {
                                    final parsed = double.tryParse(val.trim());
                                    if (parsed != null && parsed >= 0) {
                                      setState(() {
                                        line.rate = parsed;
                                        line.manuallyEditedRate = true;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Line Amount Display
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Amount', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                const SizedBox(height: 6),
                                Text(
                                  '₹${line.amount.toStringAsFixed(2)}',
                                  style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (isOverStock) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.warning),
                            const SizedBox(width: 4),
                            Text(
                              'Warning: Stock quantity is ${product.currentQty} ${product.unit}. Sale will reduce stock below 0.',
                              style: const TextStyle(fontSize: 10, color: AppColors.warning, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountGstSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DISCOUNT & GST',
              style: AppTypography.labelSm.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _discountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Discount (₹)',
                      hintText: '0.00',
                      prefixIcon: const Icon(Icons.discount_outlined, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Enable GST', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        Switch(
                          value: _gstEnabled,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) {
                            setState(() {
                              _gstEnabled = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (_gstEnabled) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _gstPercentController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'GST Rate (%)',
                        hintText: '18',
                        prefixIcon: const Icon(Icons.percent, size: 18),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: AppColors.background,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [5.0, 12.0, 18.0, 28.0].map((rate) {
                          final isSelected = (double.tryParse(_gstPercentController.text.trim()) ?? 0.0) == rate;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text('${rate.toInt()}%'),
                              selected: isSelected,
                              onSelected: (_) {
                                setState(() {
                                  _gstPercentController.text = rate.toInt().toString();
                                });
                              },
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    final isWalkIn = _customerMode == QuickSaleCustomerMode.walkIn;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PAYMENT METHOD & COLLECTION',
              style: AppTypography.labelSm.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            // Payment Method Choice Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: PaymentMethodUtils.allowedMethods.map((method) {
                  final isCreditOption = method == 'Credit';
                  final isDisabled = isWalkIn && isCreditOption;
                  final isSelected = _paymentMethod == method;
                  final icon = PaymentMethodUtils.getIcon(method);

                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : (isDisabled ? AppColors.textMuted : AppColors.primary)),
                      label: Text(method),
                      selected: isSelected,
                      disabledColor: AppColors.background,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : (isDisabled ? AppColors.textMuted : AppColors.textPrimary),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                      onSelected: isDisabled
                          ? null
                          : (_) {
                              setState(() {
                                _paymentMethod = method;
                                if (method == 'Credit') {
                                  _amountReceivedController.text = '0';
                                }
                              });
                            },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            if (isWalkIn) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.infoBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Walk-in sales require full payment upon sale. Credit and partial balances are disabled.',
                        style: TextStyle(fontSize: 11, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_paymentMethod == 'Credit') ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.request_quote, size: 16, color: AppColors.warning),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Credit Sale: Amount Received is set to ₹0.00. The full bill amount will be added to the customer\'s outstanding ledger.',
                        style: TextStyle(fontSize: 11, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              TextField(
                controller: _amountReceivedController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Amount Received (₹)',
                  hintText: _grandTotal.toStringAsFixed(2),
                  prefixIcon: const Icon(Icons.payments_outlined, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: AppColors.background,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTotalsPreviewCard() {
    final status = _statusPreview;
    Color statusBg;
    Color statusFg;
    switch (status) {
      case BillPaymentStatus.paid:
        statusBg = AppColors.successBg;
        statusFg = AppColors.success;
        break;
      case BillPaymentStatus.partial:
        statusBg = AppColors.warningBg;
        statusFg = AppColors.warning;
        break;
      case BillPaymentStatus.unpaid:
      case BillPaymentStatus.voided:
        statusBg = AppColors.criticalBg;
        statusFg = AppColors.critical;
        break;
    }

    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'BILL TOTALS SUMMARY',
                  style: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(9999)),
                  child: Text(
                    status.label.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusFg),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            _buildSummaryRow('Subtotal', '₹${_subtotal.toStringAsFixed(2)}'),
            if (_discount > 0) _buildSummaryRow('Discount', '-₹${_discount.toStringAsFixed(2)}', isHighlight: true),
            if (_gstEnabled) ...[
              _buildSummaryRow('Taxable Amount', '₹${_taxableAmount.toStringAsFixed(2)}'),
              _buildSummaryRow('GST (${_gstPercentController.text.trim()}%)', '₹${_gstAmount.toStringAsFixed(2)}'),
            ],
            const Divider(height: 16),
            _buildSummaryRow('Grand Total (Final)', '₹${_grandTotal.toStringAsFixed(2)}', isBold: true, fontSize: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isHighlight = false, double fontSize = 13}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isHighlight ? AppColors.success : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isHighlight ? AppColors.success : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isValid = _lineItems.isNotEmpty && !_isSaving;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/billing');
                }
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.borderLight),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: isValid ? _handleCompleteSale : null,
              icon: _isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.flash_on),
              label: Text(_isSaving ? 'Processing...' : 'Complete Quick Sale (₹${_grandTotal.toStringAsFixed(2)})'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentSecondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
