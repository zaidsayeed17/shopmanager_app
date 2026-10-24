/// Utility functions for phone number processing and WhatsApp integration.
library;

/// Strips all non-digit characters and prefixes '91' if the result is a bare 10-digit Indian number.
/// Returns null if the cleaned result isn't a plausible phone number.
String? toWhatsAppNumber(String? mobile) {
  if (mobile == null || mobile.trim().isEmpty) return null;

  String digits = mobile.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;

  // Handle leading zero for 11 digit numbers (e.g. 09876543210 -> 9876543210)
  if (digits.length == 11 && digits.startsWith('0')) {
    digits = digits.substring(1);
  }

  // Bare 10-digit Indian number
  if (digits.length == 10) {
    if (RegExp(r'^0+$').hasMatch(digits)) return null;
    return '91$digits';
  }

  // 12-digit number starting with 91
  if (digits.length == 12 && digits.startsWith('91')) {
    return digits;
  }

  // Plausible international number (11 to 15 digits)
  if (digits.length >= 11 && digits.length <= 15) {
    if (RegExp(r'^0+$').hasMatch(digits)) return null;
    return digits;
  }

  return null;
}
