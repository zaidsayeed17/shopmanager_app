import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/providers.dart';
import '../../../services/pdf_service.dart';
import '../customers_placeholder_data.dart';

class LedgerTabView extends ConsumerStatefulWidget {
  final List<LedgerEntry> entries;
  final List<LedgerEntry> olderEntries;
  final bool isTablet;
  final Customer? customer;
  final CustomerFinancialSummary? summary;

  const LedgerTabView({
    super.key,
    required this.entries,
    required this.olderEntries,
    required this.isTablet,
    this.customer,
    this.summary,
  });

  @override
  ConsumerState<LedgerTabView> createState() => _LedgerTabViewState();
}

class _LedgerTabViewState extends ConsumerState<LedgerTabView> {
  bool _loadedOlder = false;

  @override
  Widget build(BuildContext context) {
    final allDisplayEntries = _loadedOlder
        ? [...widget.entries, ...widget.olderEntries]
        : widget.entries;

    if (allDisplayEntries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Column(
          children: [
            Icon(Icons.menu_book, size: 36, color: AppColors.textMuted),
            SizedBox(height: 8),
            Text(
              'No transactions yet',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subheader & Statement Download
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Last ${allDisplayEntries.length} entries',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            InkWell(
              onTap: () async {
                if (widget.customer != null && widget.summary != null) {
                  try {
                    final profile = ref.read(businessProfileProvider).value;
                    final pdfBytes = await PdfService.generateCustomerLedgerPdf(
                      customer: widget.customer!,
                      ledgerEntries: allDisplayEntries,
                      summary: widget.summary!,
                      businessProfile: profile,
                    );
                    await Printing.layoutPdf(
                      onLayout: (format) async => pdfBytes,
                      name:
                          'Ledger_${widget.customer!.name.replaceAll(RegExp(r'[^\w\-]'), '_')}.pdf',
                    );
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to generate PDF statement: $e')),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Statement PDF unavailable'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Row(
                children: [
                  Icon(Icons.download, size: 15, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text(
                    'Statement (PDF)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (widget.isTablet)
          _buildTabletLedgerTable(allDisplayEntries)
        else
          _buildMobileLedgerList(allDisplayEntries),

        if (!_loadedOlder && widget.olderEntries.isNotEmpty) ...[
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _loadedOlder = true;
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.borderMedium),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text('Load Previous Transactions'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMobileLedgerList(List<LedgerEntry> entries) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final amountColor =
            entry.isDebit ? AppColors.critical : AppColors.success;
        final amountSign = entry.isDebit ? '+' : '−';

        IconData typeIcon;
        Color iconColor;
        switch (entry.type) {
          case LedgerEntryType.bill:
            typeIcon = Icons.description_outlined;
            iconColor = AppColors.primary;
            break;
          case LedgerEntryType.payment:
            typeIcon = Icons.check_circle_outline;
            iconColor = AppColors.secondary;
            break;
          case LedgerEntryType.advanceDeposit:
            typeIcon = Icons.account_balance_wallet_outlined;
            iconColor = Colors.teal;
            break;
          case LedgerEntryType.openingBalance:
            typeIcon = Icons.account_balance_outlined;
            iconColor = AppColors.textMuted;
            break;
        }

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(typeIcon, size: 18, color: iconColor),
                            const SizedBox(width: 6),
                            Text(
                              entry.title,
                              style: AppTypography.labelLg.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$amountSign ₹ ${entry.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: amountColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.description,
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(8)),
                  border: Border(
                    top: BorderSide(color: AppColors.borderLight, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.date,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      entry.runningBalance >= 0
                          ? 'Bal: ₹ ${entry.runningBalance.toStringAsFixed(0)} Dr'
                          : 'Bal: ₹ ${(-entry.runningBalance).toStringAsFixed(0)} Cr',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: entry.runningBalance > 0
                            ? AppColors.critical
                            : (entry.runningBalance < 0
                                ? AppColors.success
                                : AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabletLedgerTable(List<LedgerEntry> entries) {
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              border: Border(
                bottom: BorderSide(color: AppColors.borderLight, width: 1),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('DATE',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary))),
                Expanded(
                    flex: 2,
                    child: Text('TYPE',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary))),
                Expanded(
                    flex: 4,
                    child: Text('DESCRIPTION',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary))),
                Expanded(
                    flex: 2,
                    child: Text('DEBIT (+)',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.critical))),
                Expanded(
                    flex: 2,
                    child: Text('CREDIT (-)',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success))),
                Expanded(
                    flex: 2,
                    child: Text('RUNNING BAL',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary))),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: AppColors.borderLight),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        entry.date,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        entry.title,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        entry.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        entry.isDebit
                            ? '₹ ${entry.amount.toStringAsFixed(0)}'
                            : '—',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.critical,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        !entry.isDebit
                            ? '₹ ${entry.amount.toStringAsFixed(0)}'
                            : '—',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        entry.runningBalance >= 0
                            ? '₹ ${entry.runningBalance.toStringAsFixed(0)} Dr'
                            : '₹ ${(-entry.runningBalance).toStringAsFixed(0)} Cr',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: entry.runningBalance > 0
                              ? AppColors.critical
                              : (entry.runningBalance < 0
                                  ? AppColors.success
                                  : AppColors.textPrimary),
                        ),
                      ),
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
}
