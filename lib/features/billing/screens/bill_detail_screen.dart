import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/phone_utils.dart';
import '../../../data/models/bill_model.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/providers.dart';
import '../../../services/pdf_service.dart';
import '../../../services/whatsapp_share_service.dart';

class BillDetailScreen extends ConsumerStatefulWidget {
  final String billId;

  const BillDetailScreen({
    super.key,
    required this.billId,
  });

  @override
  ConsumerState<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends ConsumerState<BillDetailScreen> {
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')} ${_months[dt.month - 1]} ${dt.year}';
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '';
    final dateStr = _formatDate(dt);
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$dateStr, $hour:$minute $period';
  }

  String _formatCurrency(double amount) {
    if (amount % 1 == 0) {
      return '₹${amount.toInt().toString().replaceAllMapped(
        RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))'),
        (m) => '${m[1]},',
      )}';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }

  void _showVoidDialog(BuildContext context, int numericId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final reason = reasonController.text.trim();
            final isValid = reason.isNotEmpty;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: const EdgeInsets.all(20),
              content: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.criticalBg,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.critical,
                            size: 26,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Void this bill?',
                      style: AppTypography.headlineMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This will reverse the stock and outstanding balance changes made by this bill. The bill will remain visible for your records but marked as voided. This cannot be undone.',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'REASON FOR VOIDING *',
                          style: AppTypography.labelSm.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          isValid ? '${reason.length} chars' : 'Required',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isValid ? AppColors.secondary : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: reasonController,
                      maxLines: 3,
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        hintText: 'e.g. Entered by mistake, wrong customer',
                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.all(12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.critical, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(Icons.info_outline, size: 14, color: AppColors.textMuted),
                        SizedBox(width: 4),
                        Text(
                          'Recorded in the ledger audit trail',
                          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: AppColors.borderMedium),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isValid
                                ? () async {
                                    final messenger = ScaffoldMessenger.of(context);
                                    Navigator.of(dialogContext).pop();
                                    try {
                                      final repo = ref.read(billingRepositoryProvider);
                                      await repo.voidBill(
                                        billId: numericId,
                                        reason: reasonController.text,
                                      );
                                      if (mounted) {
                                        ref.invalidate(billDetailProvider(numericId));
                                        ref.invalidate(billsStreamProvider);
                                        messenger.showSnackBar(
                                          const SnackBar(
                                            content: Text('Bill voided successfully'),
                                            backgroundColor: AppColors.critical,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(e.toString().replaceAll('Exception: ', '')),
                                            backgroundColor: AppColors.critical,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                : null,
                            icon: const Icon(Icons.delete_forever, size: 18),
                            label: const Text('Void Bill'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.critical,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showRecordPaymentDialog(
    BuildContext context,
    int numericId,
    double remainingBalance,
    String customerName,
  ) {
    final amountController = TextEditingController(text: remainingBalance.toStringAsFixed(2));
    final notesController = TextEditingController();
    String selectedMethod = 'Cash'; // Cash, UPI, Other
    DateTime paymentDate = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final enteredAmount = double.tryParse(amountController.text.trim()) ?? 0.0;
            final isOverpaying = enteredAmount > remainingBalance + 0.001;
            final applied = isOverpaying ? remainingBalance : enteredAmount;
            final excess = isOverpaying ? enteredAmount - remainingBalance : 0.0;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Icon(Icons.payments_outlined, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Record Payment',
                    style: AppTypography.headlineMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 380,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REMAINING BILL BALANCE: ₹${remainingBalance.toStringAsFixed(2)}',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Amount Field
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setDialogState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Payment Amount (₹) *',
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Overpayment Preview Notice
                      if (isOverpaying) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.warningBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.info_outline, size: 16, color: AppColors.warning),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Overpayment Notice',
                                    style: AppTypography.labelSm.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${applied.toStringAsFixed(2)} will be applied to this bill (marking it Fully Paid). The remaining ₹${excess.toStringAsFixed(2)} will be saved as advance credit for $customerName.',
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Payment Method Chips
                      Text(
                        'PAYMENT METHOD',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: ['Cash', 'UPI', 'Other'].map((method) {
                          final isSelected = selectedMethod == method;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2.0),
                              child: ChoiceChip(
                                label: Text(method),
                                selected: isSelected,
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                                onSelected: (_) {
                                  setDialogState(() {
                                    selectedMethod = method;
                                  });
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Date Selector
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: paymentDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              paymentDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Date: ${_formatDate(paymentDate)}',
                                style: AppTypography.bodyMd,
                              ),
                              const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Notes Field
                      TextField(
                        controller: notesController,
                        decoration: InputDecoration(
                          labelText: 'Notes (Optional)',
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final entered = double.tryParse(amountController.text) ?? 0.0;
                    if (entered <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid payment amount.')),
                      );
                      return;
                    }

                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.of(dialogContext).pop();
                    try {
                      final repo = ref.read(billingRepositoryProvider);
                      await repo.recordPaymentForBill(
                        billId: numericId,
                        amount: entered,
                        method: selectedMethod,
                        date: paymentDate,
                        notes: notesController.text,
                      );
                      if (mounted) {
                        ref.invalidate(billDetailProvider(numericId));
                        ref.invalidate(billsStreamProvider);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              isOverpaying
                                  ? 'Payment recorded! ₹${applied.toStringAsFixed(2)} applied to bill, ₹${excess.toStringAsFixed(2)} saved as advance credit.'
                                  : 'Payment recorded successfully!',
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(e.toString().replaceAll('Exception: ', '')),
                            backgroundColor: AppColors.critical,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Payment'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final numericId = int.tryParse(widget.billId) ?? 0;
    final detailAsync = ref.watch(billDetailProvider(numericId));

    return detailAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text('Bill #${widget.billId}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/billing'),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Bill Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/billing'),
          ),
        ),
        body: Center(child: Text('Error loading bill: $err')),
      ),
      data: (data) {
        if (data == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Bill Not Found'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/billing'),
              ),
            ),
            body: const Center(child: Text('Bill record not found.')),
          );
        }

        final bill = data.bill;
        final customer = data.customer;
        final items = data.items;
        final payments = data.payments;
        final isVoided = bill.isVoided;
        final hasValidPhone = toWhatsAppNumber(customer.mobile) != null;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              bill.billNumber,
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
            actions: [
              IconButton(
                icon: Icon(
                  Icons.chat_bubble_outline,
                  color: hasValidPhone ? const Color(0xFF25D366) : AppColors.textMuted,
                ),
                tooltip: hasValidPhone ? 'Share on WhatsApp' : 'No valid mobile number for WhatsApp',
                onPressed: hasValidPhone
                    ? () {
                        final profile = ref.read(businessProfileProvider).value;
                        WhatsAppShareService.shareBillOnWhatsApp(context, data, businessProfile: profile);
                      }
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.print_outlined),
                tooltip: 'Print Bill',
                onPressed: () async {
                  try {
                    final profile = ref.read(businessProfileProvider).value;
                    final pdfBytes = await PdfService.generateBillPdf(data, businessProfile: profile);
                    await Printing.layoutPdf(
                      onLayout: (format) async => pdfBytes,
                      name: 'Bill_${bill.billNumber}',
                    );
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Couldn't generate PDF — try again"),
                          backgroundColor: AppColors.critical,
                        ),
                      );
                    }
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: 'Share Bill',
                onPressed: () async {
                  try {
                    final profile = ref.read(businessProfileProvider).value;
                    final pdfBytes = await PdfService.generateBillPdf(data, businessProfile: profile);
                    final pdfFile = await PdfService.savePdfToTempFile(pdfBytes, bill.billNumber);
                    await Share.shareXFiles(
                      [XFile(pdfFile.path, mimeType: 'application/pdf')],
                      text: 'Invoice ${bill.billNumber} from ${profile?.name ?? AppConstants.shopName}',
                    );
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Couldn't generate PDF — try again"),
                          backgroundColor: AppColors.critical,
                        ),
                      );
                    }
                  }
                },
              ),
              if (!isVoided)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'void') {
                      _showVoidDialog(context, numericId);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'void',
                      child: Row(
                        children: [
                          Icon(Icons.block, color: AppColors.critical, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Void Bill',
                            style: TextStyle(color: AppColors.critical, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= AppConstants.tabletBreakpoint;

              return SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // VOIDED ALERT BANNER
                    if (isVoided) ...[
                      _buildVoidedBanner(bill),
                      const SizedBox(height: 16),
                    ],

                    // MAIN CONTENT WITH OPTIONAL WATERMARK STAMP
                    Stack(
                      children: [
                        if (isTablet)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    _buildHeaderCard(bill, isVoided),
                                    const SizedBox(height: 16),
                                    _buildCustomerCard(customer),
                                    const SizedBox(height: 16),
                                    _buildItemsTable(items, isVoided),
                                    if (bill.notes != null && bill.notes!.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      _buildNotesCard(bill.notes!),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    _buildTotalsCard(bill, customer, isVoided, context, numericId),
                                    if (payments.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      _buildPaymentHistoryCard(payments),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildHeaderCard(bill, isVoided),
                              const SizedBox(height: 16),
                              _buildCustomerCard(customer),
                              const SizedBox(height: 16),
                              _buildItemsTable(items, isVoided),
                              const SizedBox(height: 16),
                              _buildTotalsCard(bill, customer, isVoided, context, numericId),
                              if (payments.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                _buildPaymentHistoryCard(payments),
                              ],
                              if (bill.notes != null && bill.notes!.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                _buildNotesCard(bill.notes!),
                              ],
                            ],
                          ),

                        // WATERMARK STAMP OVERLAY IF VOIDED
                        if (isVoided)
                          Positioned(
                            right: isTablet ? 280 : 16,
                            top: 24,
                            child: IgnorePointer(
                              child: Transform.rotate(
                                angle: -0.2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.criticalBg.withValues(alpha: 0.9),
                                    border: Border.all(
                                      color: AppColors.critical,
                                      width: 2,
                                      style: BorderStyle.solid,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'VOIDED',
                                        style: AppTypography.headlineLg.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.critical,
                                          letterSpacing: 2.0,
                                        ),
                                      ),
                                      const Text(
                                        'NON-NEGOTIABLE',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.critical,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildVoidedBanner(BillModel bill) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.criticalBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.critical.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cancel, color: AppColors.critical, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Invoice Voided',
                      style: AppTypography.headlineMd.copyWith(
                        color: AppColors.critical,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.critical.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: const Text(
                        'INVALIDATED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.critical,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Voided on ${_formatDateTime(bill.voidedAt)}. Reason: ${bill.voidReason ?? "No reason specified."}',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BillModel bill, bool isVoided) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ShopManager',
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Row(
                children: [
                  if (bill.isWholesaleBill) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: const Text(
                        'WHOLESALE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  _buildStatusPill(bill),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.billNumber,
                    style: AppTypography.headlineLg.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      decoration: isVoided ? TextDecoration.lineThrough : null,
                      decorationColor: AppColors.critical,
                      decorationThickness: 2,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ISSUED ON',
                    style: AppTypography.labelSm.copyWith(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDateTime(bill.billDate),
                    style: AppTypography.bodySm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(BillModel bill) {
    if (bill.isVoided) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.criticalBg,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: const Text(
          'Voided',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.critical,
          ),
        ),
      );
    }

    Color bg;
    Color fg;
    String label;

    if (bill.isPaid) {
      bg = AppColors.successBg;
      fg = AppColors.success;
      label = 'Paid';
    } else if (bill.isPartial) {
      bg = AppColors.warningBg;
      fg = AppColors.warning;
      label = 'Partial';
    } else {
      bg = AppColors.criticalBg;
      fg = AppColors.critical;
      label = 'Unpaid';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildCustomerCard(CustomerEntity customer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.storefront, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 6),
              Text(
                'BILLED TO (CUSTOMER)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  customer.name,
                  style: AppTypography.headlineMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '+91 ${customer.mobile}',
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (customer.address != null && customer.address!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              customer.address!,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsTable(List<BillItemDetail> items, bool isVoided) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'PARTICULARS & QTY',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                ),
                Text(
                  'RATE & AMOUNT',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderLight),
            itemBuilder: (context, index) {
              final line = items[index];
              final qtyStr = line.quantity % 1 == 0
                  ? line.quantity.toInt().toString()
                  : line.quantity.toStringAsFixed(2);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
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
                                  line.itemName,
                                  style: AppTypography.bodyMd.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    decoration: isVoided ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ),
                              if (line.isOwn) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    'Our Product',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple[700],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Qty: $qtyStr ${line.unit}',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatCurrency(line.amount),
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            decoration: isVoided ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@ ₹${line.rate.toStringAsFixed(2)}',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        if (line.mrpRateAtSale != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'MRP ₹${line.mrpRateAtSale!.toStringAsFixed(2)}',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsCard(BillModel bill, CustomerEntity customer, bool isVoided, BuildContext context, int numericId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
              Text(_formatCurrency(bill.subtotal), style: AppTypography.bodyMd.copyWith(decoration: isVoided ? TextDecoration.lineThrough : null)),
            ],
          ),
          if (bill.discount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Discount', style: AppTypography.bodyMd.copyWith(color: AppColors.secondary)),
                Text('-${_formatCurrency(bill.discount)}', style: AppTypography.bodyMd.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold, decoration: isVoided ? TextDecoration.lineThrough : null)),
              ],
            ),
          ],
          if (bill.otherCharges > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Other Charges', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                Text(_formatCurrency(bill.otherCharges), style: AppTypography.bodyMd.copyWith(decoration: isVoided ? TextDecoration.lineThrough : null)),
              ],
            ),
          ],
          if (bill.gstEnabled) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Taxable Amount', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                Text(
                  _formatCurrency(bill.taxableAmount),
                  style: AppTypography.bodyMd.copyWith(decoration: isVoided ? TextDecoration.lineThrough : null),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GST (${bill.gstPercent != null && bill.gstPercent! % 1 == 0 ? bill.gstPercent!.toInt().toString() : (bill.gstPercent?.toStringAsFixed(1) ?? '0')}%)',
                  style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                ),
                Text(
                  _formatCurrency(bill.gstAmount),
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    decoration: isVoided ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderMedium),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total',
                style: AppTypography.headlineMd.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                _formatCurrency(bill.grandTotal),
                style: AppTypography.headlineMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isVoided ? AppColors.critical : AppColors.primary,
                  decoration: isVoided ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Previous Balance (at time of billing): ${describeBalance(bill.balances.previous)}',
              textAlign: TextAlign.center,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // PAID AND REMAINING BREAKDOWN
          if (isVoided) ...[
            if (bill.amountPaid > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Amount Paid', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                    Text(
                      '${_formatCurrency(bill.amountPaid)} (unchanged — reflects real payments received)',
                      style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Amount Paid', style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary)),
                Text(_formatCurrency(bill.amountPaid), style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold, color: AppColors.secondary)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: bill.remainingBalance > 0 ? AppColors.criticalBg : AppColors.successBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Remaining Balance',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: bill.remainingBalance > 0 ? AppColors.critical : AppColors.success,
                    ),
                  ),
                  Text(
                    bill.remainingBalance > 0
                        ? _formatCurrency(bill.remainingBalance)
                        : 'Fully Paid',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: bill.remainingBalance > 0 ? AppColors.critical : AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            if (bill.remainingBalance > 0) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showRecordPaymentDialog(context, numericId, bill.remainingBalance, customer.name),
                  icon: const Icon(Icons.payments_outlined, size: 18),
                  label: const Text('Record Payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryCard(List<PaymentEntity> payments) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'PAYMENT HISTORY (${payments.length})',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: payments.length,
            separatorBuilder: (_, _) => const Divider(height: 12, color: AppColors.borderLight),
            itemBuilder: (context, index) {
              final p = payments[index];
              IconData icon = Icons.money;
              if (p.method.toLowerCase() == 'upi') {
                icon = Icons.qr_code;
              } else if (p.method.toLowerCase() == 'other') {
                icon = Icons.credit_card;
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 16, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${p.method.toUpperCase()} Payment',
                            style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _formatDate(p.date),
                            style: AppTypography.bodySm.copyWith(color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    _formatCurrency(p.amount),
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(String notes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NOTES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            notes,
            style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
