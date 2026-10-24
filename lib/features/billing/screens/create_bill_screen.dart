import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/payment_method_utils.dart';
import '../../../data/models/bill_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/billable_product_model.dart';
import '../../../data/repositories/providers.dart';
import '../widgets/billing_product_picker_dialog.dart';

class CreateBillScreen extends ConsumerStatefulWidget {
  final String? initialCustomerId;

  const CreateBillScreen({
    super.key,
    this.initialCustomerId,
  });

  @override
  ConsumerState<CreateBillScreen> createState() => _CreateBillScreenState();
}

class _CreateBillItemLine {
  final BillableProduct product;
  final TextEditingController qtyController;
  final TextEditingController rateController;
  final FocusNode focusNode;
  bool manuallyEditedRate = false;

  _CreateBillItemLine({
    required this.product,
    required this.qtyController,
    required this.rateController,
    required this.focusNode,
  });

  double get quantity => double.tryParse(qtyController.text.trim()) ?? 0.0;
  double get rate => double.tryParse(rateController.text.trim()) ?? 0.0;
  double get amount => (quantity * rate * 100).roundToDouble() / 100.0;
  bool get exceedsStock => product.isStock && quantity > product.currentQty;
  bool get hasError => qtyController.text.trim().isEmpty || quantity <= 0 || rate < 0;
}

class _CreateBillScreenState extends ConsumerState<CreateBillScreen> {
  Customer? _selectedCustomer;
  bool _initializedCustomer = false;
  DateTime _selectedDate = DateTime.now();

  final List<_CreateBillItemLine> _lines = [];

  bool _showDiscountInput = false;
  final TextEditingController _discountController = TextEditingController(text: '0');
  bool _showOtherChargesInput = false;
  final TextEditingController _otherChargesController = TextEditingController(text: '0');

  bool _gstEnabled = false;
  final TextEditingController _gstPercentController = TextEditingController(text: '18');

  final TextEditingController _amountReceivedController = TextEditingController(text: '0');
  final TextEditingController _advanceToApplyController = TextEditingController(text: '0');
  String _paymentMethod = 'cash'; // 'cash', 'upi', 'other'

  final TextEditingController _notesController = TextEditingController();

  bool _hasAttemptedSave = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _discountController.addListener(_onTotalChanged);
    _otherChargesController.addListener(_onTotalChanged);
    _gstPercentController.addListener(_onTotalChanged);
    _advanceToApplyController.addListener(_onTotalChanged);
    _amountReceivedController.addListener(_onTotalChanged);
  }

  @override
  void dispose() {
    _discountController.dispose();
    _otherChargesController.dispose();
    _gstPercentController.dispose();
    _advanceToApplyController.dispose();
    _amountReceivedController.dispose();
    _notesController.dispose();
    for (final line in _lines) {
      line.qtyController.dispose();
      line.rateController.dispose();
      line.focusNode.dispose();
    }
    super.dispose();
  }

  void _onTotalChanged() {
    setState(() {});
  }

  void _initCustomerIfNeeded(List<Customer> customers) {
    if (_initializedCustomer) return;
    _initializedCustomer = true;

    if (widget.initialCustomerId != null) {
      final id = int.tryParse(widget.initialCustomerId!);
      if (id != null) {
        for (final c in customers) {
          if (c.id == id) {
            _selectedCustomer = c;
            break;
          }
        }
      }
    }
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

  void _addProductLine(BillableProduct product) {
    // Check for duplicate product (same source and id)
    final existingIndex = _lines.indexWhere(
      (l) => l.product.source == product.source && l.product.id == product.id,
    );
    if (existingIndex != -1) {
      // Focus existing line
      _lines[existingIndex].focusNode.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} is already in the bill. Focused quantity line.'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final isWholesale = _selectedCustomer?.isWholesale ?? false;
    final initialRate = product.priceForCustomer(isWholesale);

    final qtyCtrl = TextEditingController(text: '1');
    final rateCtrl = TextEditingController(
      text: initialRate.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), ''),
    );
    final focusNode = FocusNode();

    qtyCtrl.addListener(_onTotalChanged);
    rateCtrl.addListener(_onTotalChanged);

    setState(() {
      _lines.add(
        _CreateBillItemLine(
          product: product,
          qtyController: qtyCtrl,
          rateController: rateCtrl,
          focusNode: focusNode,
        ),
      );
    });
  }

  void _onCustomerChanged(Customer customer) {
    setState(() {
      _selectedCustomer = customer;
      final isWholesale = customer.isWholesale;
      for (final line in _lines) {
        if (!line.manuallyEditedRate) {
          final newRate = line.product.priceForCustomer(isWholesale);
          line.rateController.text = newRate.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
        }
      }
    });
  }

  void _removeLine(int index) {
    setState(() {
      _lines[index].qtyController.dispose();
      _lines[index].rateController.dispose();
      _lines[index].focusNode.dispose();
      _lines.removeAt(index);
    });
  }

  double get _subtotal {
    double sum = 0.0;
    for (final line in _lines) {
      sum += line.amount;
    }
    return (sum * 100).roundToDouble() / 100.0;
  }

  double get _discount => double.tryParse(_discountController.text.trim()) ?? 0.0;
  double get _otherCharges => double.tryParse(_otherChargesController.text.trim()) ?? 0.0;
  double get _taxableAmount => ((_subtotal - _discount + _otherCharges) * 100).roundToDouble() / 100.0;

  double get _gstPercent => double.tryParse(_gstPercentController.text.trim()) ?? 0.0;
  double get _gstAmount => _gstEnabled
      ? ((_taxableAmount * _gstPercent / 100.0) * 100).roundToDouble() / 100.0
      : 0.0;

  double get _grandTotal => ((_taxableAmount + _gstAmount) * 100).roundToDouble() / 100.0;
  double get _advanceToApply => double.tryParse(_advanceToApplyController.text.trim()) ?? 0.0;
  double get _netPayable => ((_grandTotal - _advanceToApply) * 100).roundToDouble() / 100.0;
  double get _amountReceived => double.tryParse(_amountReceivedController.text.trim()) ?? 0.0;
  double get _remainingBalance => ((_netPayable - _amountReceived) * 100).roundToDouble() / 100.0;

  bool get _amountReceivedExceedsGrandTotal => _amountReceived > _netPayable + 0.001;

  bool get _hasItemError => _lines.any((l) => l.hasError);

  bool get _isGstValid => !_gstEnabled || (_gstPercent > 0 && _gstPercent <= 100);

  bool get _isFormValid {
    if (_selectedCustomer == null) return false;
    if (_lines.isEmpty) return false;
    if (_hasItemError) return false;
    if (_discount < 0 || _otherCharges < 0 || _advanceToApply < 0) return false;
    if (!_isGstValid) return false;
    if (_amountReceived < 0 || _amountReceivedExceedsGrandTotal) return false;
    return true;
  }

  Future<void> _onSave() async {
    if (_isSaving) return;

    setState(() {
      _hasAttemptedSave = true;
    });

    if (!_isFormValid) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final billLines = _lines
          .map((l) => BillLine(
                itemId: l.product.isStock ? l.product.id : null,
                sellingProductId: l.product.isOwn ? l.product.id : null,
                productName: l.product.name,
                unit: l.product.unit,
                quantity: l.quantity,
                rate: l.rate,
                mrpRateAtSale: l.product.retailPrice,
              ))
          .toList();

      final repo = ref.read(billingRepositoryProvider);
      final billNum = await repo.saveBill(
        customerId: _selectedCustomer!.id,
        billDate: _selectedDate,
        lines: billLines,
        discount: _discount,
        otherCharges: _otherCharges,
        gstEnabled: _gstEnabled,
        gstPercent: _gstEnabled ? _gstPercent : null,
        advanceToApply: _advanceToApply,
        amountReceived: _amountReceived,
        paymentMethod: _amountReceived > 0 ? _paymentMethod : null,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      // Invalidate Riverpod providers for real-time refresh
      ref.invalidate(billsStreamProvider);
      ref.invalidate(itemsStreamProvider);
      ref.invalidate(customersStreamProvider);
      if (_selectedCustomer != null) {
        ref.invalidate(customerLedgerSummaryProvider(_selectedCustomer!.id));
        ref.invalidate(customerAdvanceBalanceProvider(_selectedCustomer!.id));
        ref.invalidate(customerByIdProvider(_selectedCustomer!.id));
      }
      ref.invalidate(nextBillNumberProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bill $billNum saved successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/billing');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving bill: $e'),
            backgroundColor: AppColors.critical,
          ),
        );
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _openCustomerPickerSheet(List<Customer> customers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        return _CustomerPickerSheet(
          customers: customers.where((c) => c.isActive).toList(),
          onSelect: (customer) {
            Navigator.pop(ctx);
            _onCustomerChanged(customer);
          },
        );
      },
    );
  }

  void _openProductPicker() {
    BillingProductPickerDialog.show(
      context,
      isWholesaleCustomer: _selectedCustomer?.isWholesale ?? false,
      onProductSelected: (product) {
        _addProductLine(product);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersStreamProvider);
    final customers = customersAsync.value ?? [];

    _initCustomerIfNeeded(customers);

    final ledgerSummaryAsync = _selectedCustomer != null
        ? ref.watch(customerLedgerSummaryProvider(_selectedCustomer!.id))
        : null;
    final previousOutstanding = ledgerSummaryAsync?.value ?? (_selectedCustomer?.openingBalance ?? 0.0);

    final advanceBalanceAsync = _selectedCustomer != null
        ? ref.watch(customerAdvanceBalanceProvider(_selectedCustomer!.id))
        : null;
    final advanceBalance = advanceBalanceAsync?.value ?? 0.0;

    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Bill',
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
              context.go('/billing');
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
                      // Customer & Date Section
                      if (isTablet)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _buildCustomerCard(customers, previousOutstanding)),
                            const SizedBox(width: 16),
                            Expanded(flex: 1, child: _buildDateCard()),
                          ],
                        )
                      else ...[
                        _buildCustomerCard(customers, previousOutstanding),
                        const SizedBox(height: 16),
                        _buildDateCard(),
                      ],

                      const SizedBox(height: 20),

                      // Items Section & Totals/Payment Layout
                      if (isTablet)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _buildItemsSection(isTablet)),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  _buildTotalsCard(previousOutstanding, advanceBalance),
                                  const SizedBox(height: 16),
                                  _buildPaymentSection(),
                                  const SizedBox(height: 16),
                                  _buildNotesSection(),
                                ],
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _buildItemsSection(isTablet),
                        const SizedBox(height: 20),
                        _buildTotalsCard(previousOutstanding, advanceBalance),
                        const SizedBox(height: 16),
                        _buildPaymentSection(),
                        const SizedBox(height: 16),
                        _buildNotesSection(),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Action Bar
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(List<Customer> customers, double previousOutstanding) {
    if (_selectedCustomer == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _hasAttemptedSave ? AppColors.critical : AppColors.borderMedium,
            width: _hasAttemptedSave ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Customer Details',
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text('*', style: TextStyle(color: AppColors.critical, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _openCustomerPickerSheet(customers),
              icon: const Icon(Icons.person_add_alt_1, size: 18),
              label: const Text('Select Customer'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            if (_hasAttemptedSave && _selectedCustomer == null) ...[
              const SizedBox(height: 8),
              Text(
                'Please select a customer for this bill',
                style: AppTypography.bodySm.copyWith(color: AppColors.critical),
              ),
            ],
          ],
        ),
      );
    }

    final cust = _selectedCustomer!;
    final hasDue = previousOutstanding > 0.005;
    final hasAdvance = previousOutstanding < -0.005;

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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              alignment: Alignment.center,
              child: Text(
                cust.initials,
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
                          cust.name,
                          style: AppTypography.bodyLg.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.initialCustomerId == null) ...[
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _openCustomerPickerSheet(customers),
                          child: Text(
                            'Change',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '+91 ${cust.mobile}',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (cust.isWholesale) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            'WHOLESALE',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: hasDue
                              ? AppColors.warningBg
                              : (hasAdvance ? AppColors.infoBg : AppColors.successBg),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          hasDue
                              ? 'Previous Due: ₹${previousOutstanding.toStringAsFixed(2)}'
                              : (hasAdvance
                                  ? 'Advance Credit: ₹${(-previousOutstanding).toStringAsFixed(2)}'
                                  : 'No Outstanding'),
                          style: AppTypography.labelSm.copyWith(
                            color: hasDue
                                ? AppColors.warning
                                : (hasAdvance ? AppColors.info : AppColors.success),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateCard() {
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
              'BILL DATE',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.background,
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
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Items',
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _openProductPicker,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('+ Add Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_lines.isEmpty)
          _buildEmptyItemsCard()
        else
          _buildMobileItemsList(),
      ],
    );
  }

  Widget _buildEmptyItemsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _hasAttemptedSave ? AppColors.critical : AppColors.borderMedium,
          width: _hasAttemptedSave ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 36,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'No items added to this bill',
            style: AppTypography.bodyLg.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add products or raw materials to record the sale.',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _openProductPicker,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('+ Add Item'),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileItemsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _lines.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final line = _lines[index];
        final product = line.product;
        final hasError = line.hasError;
        final exceedsStock = line.exceedsStock;

        Color cardBorderColor = AppColors.borderLight;
        Color cardBgColor = AppColors.surface;

        if (hasError) {
          cardBorderColor = AppColors.critical;
          cardBgColor = AppColors.criticalBg.withValues(alpha: 0.2);
        } else if (exceedsStock) {
          cardBorderColor = AppColors.warning;
          cardBgColor = AppColors.warningBg.withValues(alpha: 0.3);
        }

        return Container(
          key: ValueKey('item_line_${product.source.name}_${product.id}'),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cardBorderColor, width: (hasError || exceedsStock) ? 1.5 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                product.name,
                                style: AppTypography.bodyLg.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
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
                                style: AppTypography.labelSm.copyWith(
                                  color: product.isOwn ? Colors.purple[700] : AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.isStock
                              ? 'Available: ${product.currentQty} ${product.unit}'
                              : 'Unlimited stock',
                          style: AppTypography.bodySm.copyWith(
                            color: product.isStock && product.currentQty <= 0
                                ? AppColors.critical
                                : AppColors.textSecondary,
                            fontWeight: product.isStock && product.currentQty <= 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.textMuted),
                    onPressed: () => _removeLine(index),
                    tooltip: 'Remove item',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.borderLight),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Qty',
                          style: AppTypography.bodySm.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          focusNode: line.focusNode,
                          controller: line.qtyController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            border: const OutlineInputBorder(),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                product.unit,
                                style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                              ),
                            ),
                            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Builder(
                          builder: (context) {
                            final isWholesale = _selectedCustomer?.isWholesale ?? false;
                            final mrpStr = product.retailPrice.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      isWholesale ? 'Wholesale Rate (₹)' : 'Rate (₹)',
                                      style: AppTypography.bodySm.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isWholesale ? AppColors.primary : AppColors.textSecondary,
                                      ),
                                    ),
                                    if (isWholesale && product.retailPrice > 0) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        'MRP ₹$mrpStr',
                                        style: AppTypography.labelSm.copyWith(
                                          color: AppColors.textMuted,
                                          decoration: TextDecoration.lineThrough,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: line.rateController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          onChanged: (_) {
                            line.manuallyEditedRate = true;
                            _onTotalChanged();
                          },
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Amount',
                          style: AppTypography.bodySm.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${line.amount.toStringAsFixed(2)}',
                          style: AppTypography.bodyLg.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Stock Warning Notice (Informational only, save stays enabled)
              if (product.isStock && exceedsStock && !hasError) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warningBg,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.warning),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Only ${product.currentQty} ${product.unit} available — proceeding will oversell this item by ${(line.quantity - product.currentQty).toStringAsFixed(1)} ${product.unit}.',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (hasError) ...[
                const SizedBox(height: 8),
                Text(
                  'Quantity must be greater than 0',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.critical,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalsCard(double previousOutstanding, double advanceBalance) {
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
              'Bill Summary',
              style: AppTypography.bodyLg.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: AppTypography.bodyMd),
                Text('₹${_subtotal.toStringAsFixed(2)}', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),

            // Discount Toggle/Input
            if (!_showDiscountInput && _discount == 0)
              InkWell(
                onTap: () => setState(() => _showDiscountInput = true),
                child: Text(
                  '+ Add discount',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: Text('Discount (₹)', style: AppTypography.bodyMd),
                  ),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _discountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.right,
                      style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),

            // Other Charges Toggle/Input
            if (!_showOtherChargesInput && _otherCharges == 0)
              InkWell(
                onTap: () => setState(() => _showOtherChargesInput = true),
                child: Text(
                  '+ Add other charges',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: Text('Other Charges (₹)', style: AppTypography.bodyMd),
                  ),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _otherChargesController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.right,
                      style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 12),

            // GST Toggle & Section
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _gstEnabled ? AppColors.infoBg : AppColors.background,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _gstEnabled ? AppColors.info.withValues(alpha: 0.3) : AppColors.borderLight,
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
                          const Icon(Icons.receipt_long, size: 18, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'Apply GST to this bill',
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _gstEnabled,
                        onChanged: (val) {
                          setState(() {
                            _gstEnabled = val;
                          });
                        },
                        activeThumbColor: AppColors.primary,
                      ),
                    ],
                  ),
                  if (_gstEnabled) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'GST Slab:',
                          style: AppTypography.bodySm.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [5, 12, 18, 28].map((slab) {
                                final isSelected = _gstPercent == slab.toDouble();
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ChoiceChip(
                                    label: Text('$slab%'),
                                    selected: isSelected,
                                    onSelected: (_) {
                                      setState(() {
                                        _gstPercentController.text = slab.toString();
                                      });
                                    },
                                    selectedColor: AppColors.primary,
                                    labelStyle: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.textPrimary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'GST Rate (%)',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 90,
                          child: TextField(
                            controller: _gstPercentController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.right,
                            style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              isDense: true,
                              suffixText: '%',
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_hasAttemptedSave && !_isGstValid) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Please enter a valid GST percentage (1 - 100%)',
                        style: AppTypography.bodySm.copyWith(color: AppColors.critical),
                      ),
                    ],
                  ],
                ],
              ),
            ),

            const Divider(height: 20, color: AppColors.borderLight),

            if (_gstEnabled) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Taxable Amount', style: AppTypography.bodyMd),
                  Text('₹${_taxableAmount.toStringAsFixed(2)}', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'GST (${_gstPercent % 1 == 0 ? _gstPercent.toInt().toString() : _gstPercent.toStringAsFixed(1)}%)',
                    style: AppTypography.bodyMd,
                  ),
                  Text(
                    '₹${_gstAmount.toStringAsFixed(2)}',
                    style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _gstEnabled ? 'Grand Total (GST Incl.)' : 'Grand Total',
                  style: AppTypography.headlineMd.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₹${_grandTotal.toStringAsFixed(2)}',
                  style: AppTypography.headlineMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            if (_selectedCustomer != null && advanceBalance > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.infoBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Available Advance Credit:',
                          style: AppTypography.labelSm.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.info,
                          ),
                        ),
                        Text(
                          '₹${advanceBalance.toStringAsFixed(2)}',
                          style: AppTypography.bodyLg.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _advanceToApplyController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              labelText: 'Apply Advance (₹)',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final maxApplicable = advanceBalance < _grandTotal ? advanceBalance : _grandTotal;
                            _advanceToApplyController.text = maxApplicable.toStringAsFixed(2);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          ),
                          child: const Text('Apply Max', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    if (_advanceToApply > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Net Payable After Advance:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(
                            '₹${_netPayable.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],

            if (_selectedCustomer != null) ...[
              const SizedBox(height: 8),
              Text(
                previousOutstanding < -0.005
                    ? 'Customer\'s available advance credit: ₹${(-previousOutstanding).toStringAsFixed(2)} (not included in this bill\'s total)'
                    : 'Customer\'s existing outstanding: ₹${previousOutstanding.toStringAsFixed(2)} (not included in this bill\'s total)',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    final isOverpaid = _amountReceivedExceedsGrandTotal;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: isOverpaid ? AppColors.critical : AppColors.borderLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment',
              style: AppTypography.bodyLg.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'Amount Received Now (₹)',
              style: AppTypography.bodySm.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _amountReceivedController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.bold,
                color: isOverpaid ? AppColors.critical : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: const OutlineInputBorder(),
                errorText: isOverpaid
                    ? 'Amount received cannot exceed the bill total (₹${_grandTotal.toStringAsFixed(2)})'
                    : null,
              ),
            ),
            const SizedBox(height: 12),

            // Payment Method chips (Cash / UPI / Other)
            Text(
              'Payment Method',
              style: AppTypography.bodySm.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: PaymentMethodUtils.allowedMethods.map((m) {
                  final key = PaymentMethodUtils.toKey(m);
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      avatar: Icon(
                        PaymentMethodUtils.getIcon(key),
                        size: 16,
                        color: _paymentMethod == key ? Colors.white : AppColors.textPrimary,
                      ),
                      label: Text(m),
                      selected: _paymentMethod == key,
                      onSelected: _amountReceived > 0
                          ? (selected) {
                              if (selected) {
                                setState(() {
                                  _paymentMethod = key;
                                });
                              }
                            }
                          : null,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _paymentMethod == key ? Colors.white : AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Live Remaining Balance indicator
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _remainingBalance <= 0 ? AppColors.successBg : AppColors.criticalBg.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _remainingBalance <= 0 ? AppColors.success : AppColors.critical.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Remaining Balance:',
                    style: AppTypography.bodySm.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _remainingBalance <= 0 ? AppColors.success : AppColors.critical,
                    ),
                  ),
                  Text(
                    _remainingBalance <= 0
                        ? 'Fully Paid'
                        : '₹${_remainingBalance.toStringAsFixed(2)}',
                    style: AppTypography.bodyLg.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _remainingBalance <= 0 ? AppColors.success : AppColors.critical,
                    ),
                  ),
                ],
              ),
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
                hintText: 'e.g. Delivered via tempo, PO reference...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    final isValid = _isFormValid;
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
                          context.go('/billing');
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
                onPressed: isDisabled ? null : _onSave,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check, size: 18),
                label: Text(_isSaving ? 'Saving...' : 'Save Bill'),
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

class _CustomerPickerSheet extends StatefulWidget {
  final List<Customer> customers;
  final ValueChanged<Customer> onSelect;

  const _CustomerPickerSheet({
    required this.customers,
    required this.onSelect,
  });

  @override
  State<_CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<_CustomerPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.customers.where((c) {
      if (_query.trim().isEmpty) return true;
      final q = _query.trim().toLowerCase();
      return c.name.toLowerCase().contains(q) || c.mobile.contains(q);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Customer',
                  style: AppTypography.headlineMd.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search customer by name or mobile...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          _query.isNotEmpty
                              ? 'No customers match "$_query"'
                              : 'No active customers found.',
                          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderLight),
                      itemBuilder: (context, index) {
                        final c = filtered[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          title: Text(
                            c.name,
                            style: AppTypography.bodyLg.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '+91 ${c.mobile}',
                            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                          onTap: () => widget.onSelect(c),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
