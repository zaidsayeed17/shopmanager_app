import '../../data/models/customer_model.dart';
export '../../data/models/customer_model.dart';

enum BillStatus { paid, partial, unpaid, voided }

enum LedgerEntryType { bill, payment, advanceDeposit, openingBalance }

class LedgerEntry {
  final String id;
  final String date;
  final LedgerEntryType type;
  final String title;
  final String description;
  final double amount; // Positive amount
  final bool isDebit; // true for Debit (+₹X), false for Credit (-₹X)
  final double runningBalance;

  const LedgerEntry({
    required this.id,
    required this.date,
    required this.type,
    required this.title,
    required this.description,
    required this.amount,
    required this.isDebit,
    required this.runningBalance,
  });
}

class CustomerBill {
  final int? id;
  final String billNumber; // e.g. 'INV-0001'
  final String date;
  final double totalAmount;
  final String itemsSummary;
  final BillStatus status; // paid, partial, unpaid, voided
  final String statusLabel;

  const CustomerBill({
    this.id,
    required this.billNumber,
    required this.date,
    required this.totalAmount,
    required this.itemsSummary,
    required this.status,
    required this.statusLabel,
  });
}

enum PaymentMethod { cash, upi, other }

class CustomerPayment {
  final String id;
  final String date;
  final double amount;
  final PaymentMethod method;
  final String methodLabel;
  final String referenceNote;
  final String? linkedBillNumber;

  const CustomerPayment({
    required this.id,
    required this.date,
    required this.amount,
    required this.method,
    required this.methodLabel,
    required this.referenceNote,
    this.linkedBillNumber,
  });
}

class CustomerFinancialSummary {
  final double totalBilled;
  final double totalPaid;
  final double outstandingBalance;
  final double advanceBalance;

  const CustomerFinancialSummary({
    required this.totalBilled,
    required this.totalPaid,
    required this.outstandingBalance,
    this.advanceBalance = 0.0,
  });
}

// NOTE: Static placeholder data maps below have been neutralized.
// Real customer financial summaries, ledger entries, bills, and payments are now fetched
// dynamically from BillingRepository and database tables via Riverpod providers.
class CustomersPlaceholderData {
  // Legacy initial customers seed reference (now managed by CustomerRepository.seedInitialCustomersIfEmpty)
  static const List<Customer> initialCustomers = [];

  // Neutralized static mock maps (previously contained hardcoded Phase 1d/2a test data)
  static const Map<String, CustomerFinancialSummary> financialSummaries = {};
  static const Map<String, List<LedgerEntry>> customerLedgerEntries = {};
  static const Map<String, List<LedgerEntry>> olderLedgerEntries = {};
  static const Map<String, List<CustomerBill>> customerBills = {};
  static const Map<String, List<CustomerPayment>> customerPayments = {};
}
