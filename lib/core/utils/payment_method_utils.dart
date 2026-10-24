import 'package:flutter/material.dart';

enum AppPaymentMethod {
  cash,
  upi,
  bank,
  card,
  credit,
  other;

  String get key => name;

  String get label {
    switch (this) {
      case AppPaymentMethod.cash:
        return 'Cash';
      case AppPaymentMethod.upi:
        return 'UPI';
      case AppPaymentMethod.bank:
        return 'Bank';
      case AppPaymentMethod.card:
        return 'Card';
      case AppPaymentMethod.credit:
        return 'Credit';
      case AppPaymentMethod.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case AppPaymentMethod.cash:
        return Icons.payments;
      case AppPaymentMethod.upi:
        return Icons.qr_code;
      case AppPaymentMethod.bank:
        return Icons.account_balance;
      case AppPaymentMethod.card:
        return Icons.credit_card;
      case AppPaymentMethod.credit:
        return Icons.request_quote;
      case AppPaymentMethod.other:
        return Icons.account_balance_wallet;
    }
  }

  static AppPaymentMethod parse(String? method) {
    if (method == null) return AppPaymentMethod.cash;
    final normalized = method.trim().toLowerCase();
    switch (normalized) {
      case 'cash':
        return AppPaymentMethod.cash;
      case 'upi':
        return AppPaymentMethod.upi;
      case 'bank':
      case 'bank_transfer':
      case 'net_banking':
        return AppPaymentMethod.bank;
      case 'card':
      case 'debit_card':
      case 'credit_card':
        return AppPaymentMethod.card;
      case 'credit':
        return AppPaymentMethod.credit;
      case 'advance':
      case 'other':
      default:
        return AppPaymentMethod.other;
    }
  }
}

class PaymentMethodUtils {
  static const List<String> allowedMethods = [
    'Cash',
    'UPI',
    'Bank',
    'Card',
    'Credit',
    'Other',
  ];

  static AppPaymentMethod fromString(String? method) {
    return AppPaymentMethod.parse(method);
  }

  static String toKey(String displayLabel) {
    final parsed = AppPaymentMethod.parse(displayLabel);
    return parsed.key;
  }

  static String getLabel(String? method) {
    return AppPaymentMethod.parse(method).label;
  }

  static IconData getIcon(String? method) {
    return AppPaymentMethod.parse(method).icon;
  }
}
