import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/payment_method_utils.dart';
import '../../../data/repositories/providers.dart';
import '../customers_placeholder_data.dart';

class OutstandingBalanceCard extends ConsumerWidget {
  final Customer customer;
  final CustomerFinancialSummary summary;

  const OutstandingBalanceCard({
    super.key,
    required this.customer,
    required this.summary,
  });

  void _showRecordAdvanceDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    String selectedMethod = 'Cash';
    DateTime depositDate = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, color: AppColors.info),
                  const SizedBox(width: 8),
                  Text(
                    'Record Advance / Deposit',
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
                        'CUSTOMER: ${customer.name.toUpperCase()}',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Advance Deposit Amount (₹) *',
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
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
                        children: PaymentMethodUtils.allowedMethods.map((method) {
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
                      const SizedBox(height: 14),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: depositDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              depositDate = picked;
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
                                'Date: ${depositDate.day}/${depositDate.month}/${depositDate.year}',
                                style: AppTypography.bodyMd,
                              ),
                              const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: notesController,
                        decoration: InputDecoration(
                          labelText: 'Notes (Optional)',
                          hintText: 'e.g. Deposit for upcoming bulk order',
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
                    final entered = double.tryParse(amountController.text.trim()) ?? 0.0;
                    if (entered <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid deposit amount.')),
                      );
                      return;
                    }

                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.of(dialogContext).pop();
                    try {
                      final repo = ref.read(billingRepositoryProvider);
                      await repo.recordAdvanceDeposit(
                        customerId: customer.id,
                        amount: entered,
                        method: selectedMethod,
                        date: depositDate,
                        notes: notesController.text,
                      );
                      ref.invalidate(customerFinancialSummaryProvider(customer.id));
                      ref.invalidate(customerAdvanceBalanceProvider(customer.id));
                      ref.invalidate(customerLedgerEntriesProvider(customer.id));
                      ref.invalidate(customerPaymentsProvider(customer.id));
                      ref.invalidate(customersStreamProvider);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Advance deposit of ₹${entered.toStringAsFixed(2)} recorded!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(e.toString().replaceAll('Exception: ', '')),
                          backgroundColor: AppColors.critical,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Advance'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasBalance = summary.outstandingBalance > 0;
    final hasAdvance = summary.advanceBalance > 0;

    final accentColor = hasBalance
        ? AppColors.critical
        : (hasAdvance ? AppColors.info : AppColors.success);
    final badgeBgColor = hasBalance
        ? AppColors.criticalBg
        : (hasAdvance ? AppColors.infoBg : AppColors.successBg);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.04),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left Accent Strip
              Container(
                width: 4,
                color: accentColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ACCOUNT BALANCE',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeBgColor,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: accentColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  hasBalance
                                      ? 'Outstanding'
                                      : (hasAdvance ? 'Advance Credit' : 'All Clear'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Figures split: Outstanding vs Advance Held
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Outstanding Balance',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₹ ${summary.outstandingBalance.toStringAsFixed(0)}',
                                  style: AppTypography.displayLg.copyWith(
                                    color: hasBalance ? AppColors.critical : AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Advance Held',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₹ ${summary.advanceBalance.toStringAsFixed(0)}',
                                  style: AppTypography.displayLg.copyWith(
                                    color: hasAdvance ? AppColors.info : AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          text: 'Billed: ',
                          style: AppTypography.bodySm.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: '₹ ${summary.totalBilled.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const TextSpan(text: ' • Paid: '),
                            TextSpan(
                              text: '₹ ${summary.totalPaid.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.go('/billing/new/${customer.id}');
                              },
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Create Bill'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showRecordAdvanceDialog(context, ref),
                              icon: const Icon(Icons.account_balance_wallet_outlined, size: 16),
                              label: const Text('Record Advance'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.borderMedium),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
