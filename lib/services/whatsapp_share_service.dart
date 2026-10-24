import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/phone_utils.dart';
import '../data/repositories/billing_repository.dart';
import '../data/repositories/business_profile_repository.dart';
import 'pdf_service.dart';

class WhatsAppShareService {
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')} ${_months[dt.month - 1]} ${dt.year}';
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

  /// Direct WhatsApp sharing for a bill using wa.me deep link followed by PDF share sheet.
  static Future<void> shareBillOnWhatsApp(
    BuildContext context,
    BillDetailData billDetail, {
    BusinessProfile? businessProfile,
  }) async {
    final customer = billDetail.customer;
    final bill = billDetail.bill;
    final messenger = ScaffoldMessenger.of(context);
    final shopName = businessProfile?.name ?? AppConstants.shopName;

    final formattedPhone = toWhatsAppNumber(customer.mobile);
    if (formattedPhone == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Add a valid mobile number for this customer to enable WhatsApp sharing'),
          backgroundColor: AppColors.critical,
        ),
      );
      return;
    }

    final dateStr = _formatDate(bill.billDate);
    final grandTotalStr = _formatCurrency(bill.grandTotal);
    final remainingStr = _formatCurrency(bill.remainingBalance);

    final message =
        'Hi ${customer.name}, here is your bill ${bill.billNumber} dated $dateStr for $grandTotalStr. Remaining balance: $remainingStr. — $shopName';

    final whatsappUri = Uri.parse('https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}');

    bool launched = false;
    try {
      launched = await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }

    if (!launched) {
      if (context.mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text("WhatsApp isn't available — opening the general share menu instead"),
          ),
        );
      }
    } else {
      if (context.mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Opening WhatsApp... Select WhatsApp to attach PDF'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      await Future.delayed(const Duration(milliseconds: 800));
    }

    // Step 6: Generate PDF and open Share Sheet
    try {
      final pdfBytes = await PdfService.generateBillPdf(billDetail, businessProfile: businessProfile);
      final pdfFile = await PdfService.savePdfToTempFile(pdfBytes, bill.billNumber);
      await Share.shareXFiles(
        [XFile(pdfFile.path, mimeType: 'application/pdf')],
        text: 'Invoice ${bill.billNumber} from $shopName',
      );
    } catch (_) {
      if (context.mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text("Couldn't generate PDF — try again"),
            backgroundColor: AppColors.critical,
          ),
        );
      }
    }
  }

  /// Opens a general WhatsApp chat with the customer (no PDF attached).
  static Future<void> openWhatsAppChat(
    BuildContext context,
    String? mobile, {
    String? message,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final formattedPhone = toWhatsAppNumber(mobile);

    if (formattedPhone == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Add a valid mobile number for this customer to enable WhatsApp sharing'),
          backgroundColor: AppColors.critical,
        ),
      );
      return;
    }

    final query = message != null && message.isNotEmpty ? '?text=${Uri.encodeComponent(message)}' : '';
    final whatsappUri = Uri.parse('https://wa.me/$formattedPhone$query');

    bool launched = false;
    try {
      launched = await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }

    if (!launched && context.mounted) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("WhatsApp isn't available on this device"),
          backgroundColor: AppColors.critical,
        ),
      );
    }
  }
}
