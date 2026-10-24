import 'dart:io';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/balance_utils.dart';
import '../data/repositories/billing_repository.dart';
import '../data/repositories/business_profile_repository.dart';
import '../features/customers/customers_placeholder_data.dart';

class PdfService {
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')} ${_months[dt.month - 1]} ${dt.year}';
  }

  static String _formatDateTime(DateTime? dt) {
    if (dt == null) return '';
    final dateStr = _formatDate(dt);
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$dateStr, $hour:$minute $period';
  }

  static String _formatCurrency(double amount) {
    final formattedNum = amount % 1 == 0
        ? amount.toInt().toString().replaceAllMapped(
              RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))'),
              (m) => '${m[1]},',
            )
        : amount.toStringAsFixed(2);
    return '₹$formattedNum';
  }

  /// Convert amount to words in Indian Numbering format (Rupees & Paise)
  static String numberToWordsIndian(double amount) {
    if (amount < 0) {
      return 'Minus ${numberToWordsIndian(-amount)}';
    }
    final intRupees = amount.floor();
    final intPaise = ((amount - intRupees) * 100).round();

    String rupeesText;
    if (intRupees == 0) {
      rupeesText = 'Zero Rupees';
    } else {
      rupeesText = '${_convertTwoDigitsOrMore(intRupees)} Rupees';
    }

    if (intPaise > 0) {
      final paiseText = _convertTwoDigitsOrMore(intPaise);
      return '$rupeesText and $paiseText Paise Only';
    } else {
      return '$rupeesText Only';
    }
  }

  static String _convertTwoDigitsOrMore(int n) {
    if (n == 0) return '';

    const units = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen'
    ];
    const tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety'
    ];

    String convertUnderThousand(int val) {
      var str = '';
      if (val >= 100) {
        str += '${units[val ~/ 100]} Hundred ';
        val %= 100;
      }
      if (val >= 20) {
        str += '${tens[val ~/ 10]} ';
        val %= 10;
      }
      if (val > 0) {
        str += '${units[val]} ';
      }
      return str.trim();
    }

    var result = '';

    if (n >= 10000000) {
      final crores = n ~/ 10000000;
      result += '${_convertTwoDigitsOrMore(crores)} Crore ';
      n %= 10000000;
    }
    if (n >= 100000) {
      final lakhs = n ~/ 100000;
      result += '${_convertTwoDigitsOrMore(lakhs)} Lakh ';
      n %= 100000;
    }
    if (n >= 1000) {
      final thousands = n ~/ 1000;
      result += '${_convertTwoDigitsOrMore(thousands)} Thousand ';
      n %= 1000;
    }
    if (n > 0) {
      result += convertUnderThousand(n);
    }

    return result.trim();
  }

  /// Generate single-page A4 PDF document bytes for a bill
  static Future<Uint8List> generateBillPdf(
    BillDetailData billDetail, {
    BusinessProfile? businessProfile,
  }) async {
    final pdf = pw.Document();
    final bill = billDetail.bill;
    final customer = billDetail.customer;
    final items = billDetail.items;
    final payments = billDetail.payments;
    final isVoided = bill.isVoided;

    final shopName = businessProfile?.name ?? AppConstants.shopName;
    final shopMobile = businessProfile?.mobile ?? '';
    final shopAddress = businessProfile?.address ?? '';
    final shopInitials = businessProfile?.initials ?? (shopName.isNotEmpty ? shopName[0].toUpperCase() : 'S');
    final contactLine = [
      if (shopMobile.isNotEmpty) 'Phone: $shopMobile',
      if (shopAddress.isNotEmpty) 'Address: $shopAddress',
    ].join(' • ');

    pw.Font mainFont;
    pw.Font boldFont;
    try {
      final regularData =
          await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      final boldData =
          await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
      mainFont = pw.Font.ttf(regularData);
      boldFont = pw.Font.ttf(boldData);
    } catch (_) {
      try {
        mainFont = await PdfGoogleFonts.notoSansRegular();
        boldFont = await PdfGoogleFonts.notoSansBold();
      } catch (_) {
        mainFont = pw.Font.helvetica();
        boldFont = pw.Font.helveticaBold();
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: mainFont,
          bold: boldFont,
        ),
        build: (pw.Context context) {
          final balances = resolveBillBalances(
            previousOutstandingSnapshot: bill.previousOutstandingSnapshot,
            currentBalanceSnapshot: bill.currentBalanceSnapshot,
            grandTotal: bill.grandTotal,
            amountPaid: bill.amountPaid,
            advanceApplied: bill.advanceApplied,
          );

          final totalQty =
              items.fold<double>(0.0, (sum, item) => sum + item.quantity);
          final totalQtyStr = totalQty % 1 == 0
              ? totalQty.toInt().toString()
              : totalQty.toStringAsFixed(2);

          final amountInWords = numberToWordsIndian(bill.grandTotal);

          return pw.Stack(
            children: [
              // MAIN CONTENT
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // 1. HEADER BLOCK
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 36,
                            height: 36,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.blueGrey800,
                              borderRadius: pw.BorderRadius.circular(6),
                            ),
                            alignment: pw.Alignment.center,
                            child: pw.Text(
                              shopInitials,
                              style: pw.TextStyle(
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 10),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                shopName,
                                style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blueGrey900,
                                ),
                              ),
                              if (contactLine.isNotEmpty) ...[
                                pw.SizedBox(height: 2),
                                pw.Text(
                                  contactLine,
                                  style: const pw.TextStyle(
                                    fontSize: 9,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 8),
                  pw.Divider(thickness: 1, color: PdfColors.blueGrey300),
                  pw.SizedBox(height: 6),

                  // 2. CENTERED INVOICE BANNER
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blueGrey800,
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      bill.isWholesaleBill ? 'WHOLESALE INVOICE' : 'INVOICE',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  pw.SizedBox(height: 8),

                  // VOID BANNER (if voided)
                  if (isVoided) ...[
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.red50,
                        border:
                            pw.Border.all(color: PdfColors.red400, width: 1),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Text(
                            'VOIDED INVOICE: ',
                            style: pw.TextStyle(
                              fontSize: 9.5,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.red900,
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              'Voided on ${_formatDateTime(bill.voidedAt)}. Reason: ${bill.voidReason ?? "No reason specified"}',
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.red900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 8),
                  ],

                  // 3. TWO-COLUMN TOP SECTION
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Left Box: Billed To
                      pw.Expanded(
                        flex: 1,
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey50,
                            border: pw.Border.all(
                                color: PdfColors.grey300, width: 0.5),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'BILLED TO',
                                style: pw.TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blueGrey800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                customer.name,
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                '+91 ${customer.mobile}',
                                style: const pw.TextStyle(
                                  fontSize: 9,
                                  color: PdfColors.grey800,
                                ),
                              ),
                              if (customer.address != null &&
                                  customer.address!.isNotEmpty) ...[
                                pw.SizedBox(height: 2),
                                pw.Text(
                                  'Address: ${customer.address}',
                                  style: const pw.TextStyle(
                                    fontSize: 9,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 10),
                      // Right Box: Invoice Details
                      pw.Expanded(
                        flex: 1,
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey50,
                            border: pw.Border.all(
                                color: PdfColors.grey300, width: 0.5),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'INVOICE DETAILS',
                                style: pw.TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blueGrey800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text('Invoice No:',
                                      style: const pw.TextStyle(
                                          fontSize: 9,
                                          color: PdfColors.grey700)),
                                  pw.Text(bill.billNumber,
                                      style: pw.TextStyle(
                                          fontSize: 10,
                                          fontWeight: pw.FontWeight.bold)),
                                ],
                              ),
                              pw.SizedBox(height: 2),
                              pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text('Invoice Date:',
                                      style: const pw.TextStyle(
                                          fontSize: 9,
                                          color: PdfColors.grey700)),
                                  pw.Text(_formatDate(bill.billDate),
                                      style: const pw.TextStyle(
                                          fontSize: 9,
                                          color: PdfColors.black)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 10),

                  // 4. ITEMS TABLE
                  pw.Table(
                    border: pw.TableBorder.all(
                        color: PdfColors.grey300, width: 0.5),
                    columnWidths: const {
                      0: pw.FlexColumnWidth(3.5),
                      1: pw.FlexColumnWidth(1.2),
                      2: pw.FlexColumnWidth(1.2),
                      3: pw.FlexColumnWidth(2.0),
                      4: pw.FlexColumnWidth(2.1),
                    },
                    children: [
                      // Header Row
                      pw.TableRow(
                        decoration:
                            const pw.BoxDecoration(color: PdfColors.blueGrey800),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            child: pw.Text('Item Name',
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.white)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            child: pw.Text('Qty',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.white)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            child: pw.Text('Unit',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.white)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            child: pw.Text('Rate (₹)',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.white)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            child: pw.Text('Amount (₹)',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.white)),
                          ),
                        ],
                      ),
                      // Line items
                      ...items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final line = entry.value;
                        final isEven = index % 2 == 0;
                        final qtyStr = line.quantity % 1 == 0
                            ? line.quantity.toInt().toString()
                            : line.quantity.toStringAsFixed(2);

                        return pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color:
                                isEven ? PdfColors.white : PdfColors.grey50,
                          ),
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              child: pw.Text(line.itemName,
                                  style: const pw.TextStyle(fontSize: 9)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              child: pw.Text(qtyStr,
                                  textAlign: pw.TextAlign.right,
                                  style: const pw.TextStyle(fontSize: 9)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              child: pw.Text(line.unit,
                                  textAlign: pw.TextAlign.center,
                                  style: const pw.TextStyle(fontSize: 9)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  pw.Text(_formatCurrency(line.rate),
                                      textAlign: pw.TextAlign.right,
                                      style: const pw.TextStyle(fontSize: 9)),
                                  if (line.mrpRateAtSale != null)
                                    pw.Text(
                                      '(MRP ${_formatCurrency(line.mrpRateAtSale!)})',
                                      textAlign: pw.TextAlign.right,
                                      style: const pw.TextStyle(
                                        fontSize: 7,
                                        color: PdfColors.grey600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              child: pw.Text(_formatCurrency(line.amount),
                                  textAlign: pw.TextAlign.right,
                                  style: pw.TextStyle(
                                      fontSize: 9,
                                      fontWeight: pw.FontWeight.bold)),
                            ),
                          ],
                        );
                      }),
                      // Table Total Row
                      pw.TableRow(
                        decoration:
                            const pw.BoxDecoration(color: PdfColors.grey100),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            child: pw.Text('Total',
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.black)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            child: pw.Text(totalQtyStr,
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.black)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            child: pw.Text('—',
                                textAlign: pw.TextAlign.center,
                                style: const pw.TextStyle(
                                    fontSize: 9, color: PdfColors.grey600)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            child: pw.Text('—',
                                textAlign: pw.TextAlign.right,
                                style: const pw.TextStyle(
                                    fontSize: 9, color: PdfColors.grey600)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            child: pw.Text(_formatCurrency(bill.subtotal),
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.black)),
                          ),
                        ],
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 10),

                  // 5 & 6. TWO-COLUMN FOOTER
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // LEFT COLUMN: Words, Payment Mode, Terms & Conditions, Notes
                      pw.Expanded(
                        flex: 6,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            // Invoice Amount in Words Box
                            pw.Container(
                              width: double.infinity,
                              padding: const pw.EdgeInsets.all(7),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.grey50,
                                border: pw.Border.all(
                                    color: PdfColors.grey300, width: 0.5),
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'INVOICE AMOUNT IN WORDS',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.blueGrey800,
                                    ),
                                  ),
                                  pw.SizedBox(height: 2),
                                  pw.Text(
                                    amountInWords,
                                    style: pw.TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            pw.SizedBox(height: 6),

                            // Payment Mode & Notes Box
                            pw.Container(
                              width: double.infinity,
                              padding: const pw.EdgeInsets.all(7),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.grey50,
                                border: pw.Border.all(
                                    color: PdfColors.grey300, width: 0.5),
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Row(
                                    children: [
                                      pw.Text(
                                        'Payment Mode: ',
                                        style: pw.TextStyle(
                                            fontSize: 8,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.blueGrey800),
                                      ),
                                      pw.Text(
                                        payments.isNotEmpty
                                            ? payments
                                                .map((p) => p.method.toUpperCase())
                                                .toSet()
                                                .join(', ')
                                            : 'Unpaid',
                                        style: pw.TextStyle(
                                            fontSize: 8,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.black),
                                      ),
                                    ],
                                  ),
                                  if (bill.notes != null &&
                                      bill.notes!.trim().isNotEmpty) ...[
                                    pw.SizedBox(height: 3),
                                    pw.Text(
                                      'Notes / Remarks: ${bill.notes!.trim()}',
                                      style: const pw.TextStyle(
                                          fontSize: 8, color: PdfColors.grey800),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            pw.SizedBox(height: 6),

                            // Terms and Conditions Box
                            pw.Container(
                              width: double.infinity,
                              padding: const pw.EdgeInsets.all(7),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.grey50,
                                border: pw.Border.all(
                                    color: PdfColors.grey300, width: 0.5),
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'TERMS & CONDITIONS',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.blueGrey800,
                                    ),
                                  ),
                                  pw.SizedBox(height: 2),
                                  // TODO: Replace with editable terms & conditions once the Settings module is implemented.
                                  pw.Text(
                                    'Goods once sold are not returnable except for verified defects reported within 7 days. Thank you for your business!',
                                    style: const pw.TextStyle(
                                      fontSize: 7.5,
                                      color: PdfColors.grey700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      pw.SizedBox(width: 10),

                      // RIGHT COLUMN: Amounts Box
                      pw.Expanded(
                        flex: 5,
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey50,
                            border: pw.Border.all(
                                color: PdfColors.grey300, width: 0.5),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Column(
                            children: [
                              _buildSummaryRow('Sub Total',
                                  _formatCurrency(bill.subtotal)),
                              if (bill.discount > 0)
                                _buildSummaryRow(
                                    'Discount',
                                    '-${_formatCurrency(bill.discount)}',
                                    isHighlight: true),
                              if (bill.otherCharges > 0)
                                _buildSummaryRow('Other Charges',
                                    _formatCurrency(bill.otherCharges)),
                              if (bill.gstEnabled) ...[
                                _buildSummaryRow('Taxable Amount',
                                    _formatCurrency(bill.taxableAmount)),
                                _buildSummaryRow(
                                    'GST (${(bill.gstPercent ?? 0) % 1 == 0 ? (bill.gstPercent ?? 0).toInt() : bill.gstPercent}%)',
                                    _formatCurrency(bill.gstAmount)),
                              ],
                              pw.Padding(
                                padding:
                                    const pw.EdgeInsets.symmetric(vertical: 2),
                                child: pw.Divider(
                                    thickness: 0.5, color: PdfColors.grey400),
                              ),
                              _buildSummaryRow(
                                'Total',
                                _formatCurrency(bill.grandTotal),
                                isBold: true,
                                fontSize: 10.5,
                              ),
                              pw.Padding(
                                padding:
                                    const pw.EdgeInsets.symmetric(vertical: 2),
                                child: pw.Divider(
                                    thickness: 0.5, color: PdfColors.grey300),
                              ),
                              _buildSummaryRow('Received',
                                  _formatCurrency(bill.amountPaid)),
                              _buildSummaryRow('Balance',
                                  _formatCurrency(bill.remainingBalance),
                                  isBold: true),
                              if (bill.customerId != null) ...[
                                pw.Padding(
                                  padding:
                                      const pw.EdgeInsets.symmetric(vertical: 2),
                                  child: pw.Divider(
                                      thickness: 0.5, color: PdfColors.grey300),
                                ),
                                _buildSummaryRow('Previous Balance',
                                    describeBalance(balances.previous)),
                                _buildSummaryRow('Current Balance',
                                    describeBalance(balances.current),
                                    isBold: true, fontSize: 10),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  pw.Spacer(),

                  // 8. FOOTER LINE
                  pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                  pw.SizedBox(height: 3),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Generated by ShopManager',
                        style: const pw.TextStyle(
                            fontSize: 8, color: PdfColors.grey600),
                      ),
                      pw.Text(
                        _formatDateTime(DateTime.now()),
                        style: const pw.TextStyle(
                            fontSize: 8, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                ],
              ),

              // 7. VOIDED WATERMARK OVERLAY
              if (isVoided)
                pw.Positioned.fill(
                  child: pw.Center(
                    child: pw.Transform.rotate(
                      angle: -0.3,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: pw.BoxDecoration(
                          border:
                              pw.Border.all(color: PdfColors.red300, width: 3),
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.Text(
                          'VOIDED',
                          style: pw.TextStyle(
                            fontSize: 70,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red300,
                            letterSpacing: 4.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    bool isHighlight = false,
    double fontSize = 9.5,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isHighlight ? PdfColors.green800 : PdfColors.black,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isHighlight ? PdfColors.green800 : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// Generate A4 PDF document for customer ledger statement
  static Future<Uint8List> generateCustomerLedgerPdf({
    required Customer customer,
    required List<LedgerEntry> ledgerEntries,
    required CustomerFinancialSummary summary,
    BusinessProfile? businessProfile,
  }) async {
    final pdf = pw.Document();

    final shopName = businessProfile?.name ?? AppConstants.shopName;
    final shopMobile = businessProfile?.mobile ?? '';
    final shopAddress = businessProfile?.address ?? '';
    final contactLine = [
      if (shopMobile.isNotEmpty) 'Phone: $shopMobile',
      if (shopAddress.isNotEmpty) 'Address: $shopAddress',
    ].join(' • ');

    pw.Font mainFont;
    pw.Font boldFont;
    try {
      final regularData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      final boldData = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
      mainFont = pw.Font.ttf(regularData);
      boldFont = pw.Font.ttf(boldData);
    } catch (_) {
      try {
        mainFont = await PdfGoogleFonts.notoSansRegular();
        boldFont = await PdfGoogleFonts.notoSansBold();
      } catch (_) {
        mainFont = pw.Font.helvetica();
        boldFont = pw.Font.helveticaBold();
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(
          base: mainFont,
          bold: boldFont,
        ),
        build: (pw.Context context) {
          return [
            // HEADER
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      shopName,
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey900,
                      ),
                    ),
                    if (contactLine.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        contactLine,
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Customer Statement / Ledger',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Date: ${_formatDate(DateTime.now())}',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Total Entries: ${ledgerEntries.length}',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 12),
            pw.Divider(thickness: 1.5, color: PdfColors.blueGrey800),
            pw.SizedBox(height: 12),

            // CUSTOMER INFO & FINANCIAL SUMMARY CARDS
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'CUSTOMER DETAILS',
                          style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(customer.name, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 2),
                        pw.Text('Phone: +91 ${customer.mobile}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                        if (customer.address != null && customer.address!.isNotEmpty)
                          pw.Text('Address: ${customer.address}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'FINANCIAL SUMMARY',
                          style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),
                        ),
                        pw.SizedBox(height: 4),
                        _buildSummaryRow('Total Billed:', _formatCurrency(summary.totalBilled), fontSize: 8.5),
                        _buildSummaryRow('Total Paid:', _formatCurrency(summary.totalPaid), fontSize: 8.5),
                        pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                        summary.advanceBalance > 0
                            ? _buildSummaryRow('Advance Held (Credit):', _formatCurrency(summary.advanceBalance), isBold: true, isHighlight: true, fontSize: 9)
                            : _buildSummaryRow('Net Outstanding (Debit):', _formatCurrency(summary.outstandingBalance), isBold: true, fontSize: 9),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 16),

            // LEDGER ENTRIES TABLE
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: const {
                0: pw.FlexColumnWidth(1.8),
                1: pw.FlexColumnWidth(2.2),
                2: pw.FlexColumnWidth(3.5),
                3: pw.FlexColumnWidth(1.8),
                4: pw.FlexColumnWidth(1.8),
                5: pw.FlexColumnWidth(2.2),
              },
              children: [
                // Header Row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Date', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Type / Title', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Description', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Debit (+)', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Credit (-)', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Running Bal', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    ),
                  ],
                ),

                // Data Rows
                ...ledgerEntries.asMap().entries.map((entryPair) {
                  final index = entryPair.key;
                  final entry = entryPair.value;
                  final isEven = index % 2 == 0;
                  final balLabel = entry.runningBalance >= 0
                      ? '${_formatCurrency(entry.runningBalance)} Dr'
                      : '${_formatCurrency(-entry.runningBalance)} Cr';

                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: isEven ? PdfColors.white : PdfColors.grey50,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(entry.date, style: const pw.TextStyle(fontSize: 8.5)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(entry.title, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(entry.description, style: const pw.TextStyle(fontSize: 8.5)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          entry.isDebit ? _formatCurrency(entry.amount) : '—',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(fontSize: 8.5, color: entry.isDebit ? PdfColors.red900 : PdfColors.black),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          !entry.isDebit ? _formatCurrency(entry.amount) : '—',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(fontSize: 8.5, color: !entry.isDebit ? PdfColors.green900 : PdfColors.black),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          balLabel,
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// Save PDF Uint8List bytes to temporary directory file for sharing
  static Future<File> savePdfToTempFile(Uint8List pdfBytes, String billNumber) async {
    final tempDir = await getTemporaryDirectory();
    final cleanNum = billNumber.replaceAll(RegExp(r'[^\w\-]'), '_');
    final file = File('${tempDir.path}/$cleanNum.pdf');
    await file.writeAsBytes(pdfBytes, flush: true);
    return file;
  }
}
