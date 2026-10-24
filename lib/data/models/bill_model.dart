import '../db/app_database.dart';
import '../../core/utils/balance_utils.dart';
export '../../core/utils/balance_utils.dart';

enum BillStatus {
  active,
  voided;

  String get label {
    switch (this) {
      case BillStatus.active:
        return 'Active';
      case BillStatus.voided:
        return 'Voided';
    }
  }
}

enum BillPaymentStatus {
  voided,
  paid,
  partial,
  unpaid;

  String get label {
    switch (this) {
      case BillPaymentStatus.voided:
        return 'Voided';
      case BillPaymentStatus.paid:
        return 'Paid';
      case BillPaymentStatus.partial:
        return 'Partial';
      case BillPaymentStatus.unpaid:
        return 'Unpaid';
    }
  }
}

/// Single source of truth for bill payment status calculation
BillPaymentStatus computeBillStatus({
  required String status,
  required double remainingBalance,
  required double grandTotal,
  required double amountPaid,
}) {
  if (status == 'void') {
    return BillPaymentStatus.voided;
  }
  if (remainingBalance <= 0.001) {
    return BillPaymentStatus.paid;
  }
  if (remainingBalance > 0 && remainingBalance < grandTotal) {
    return BillPaymentStatus.partial;
  }
  return BillPaymentStatus.unpaid;
}

class BillLine {
  final int? itemId;
  final int? sellingProductId;
  final String? productName;
  final String unit;
  final double quantity;
  final double rate;
  final double? mrpRateAtSale;

  const BillLine({
    this.itemId,
    this.sellingProductId,
    this.productName,
    this.unit = 'pcs',
    required this.quantity,
    required this.rate,
    this.mrpRateAtSale,
  }) : assert((itemId != null) ^ (sellingProductId != null), 'Exactly one of itemId or sellingProductId must be provided');

  bool get isStock => itemId != null;
  bool get isOwn => sellingProductId != null;

  double get amount => (quantity * rate * 100).round() / 100;
}

class BillItemDetail {
  final int id;
  final int billId;
  final int? itemId;
  final int? sellingProductId;
  final String itemName;
  final double quantity;
  final String unit;
  final double rate;
  final double? mrpRateAtSale;
  final double amount;

  const BillItemDetail({
    required this.id,
    required this.billId,
    this.itemId,
    this.sellingProductId,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.rate,
    this.mrpRateAtSale,
    required this.amount,
  });

  bool get isStock => itemId != null;
  bool get isOwn => sellingProductId != null;

  factory BillItemDetail.fromEntity(BillItemEntity entity, String itemName) {
    return BillItemDetail(
      id: entity.id,
      billId: entity.billId,
      itemId: entity.itemId,
      sellingProductId: entity.sellingProductId,
      itemName: itemName,
      quantity: entity.quantity,
      unit: entity.unit,
      rate: entity.rate,
      mrpRateAtSale: entity.mrpRateAtSale,
      amount: entity.amount,
    );
  }
}

class BillModel {
  final int id;
  final String billNumber;
  final String saleChannel; // 'invoice' / 'quick_sale'
  final int? customerId;
  final String customerName;
  final DateTime billDate;
  final double subtotal;
  final double discount;
  final double otherCharges;
  final bool gstEnabled;
  final double? gstPercent;
  final double taxableAmount;
  final double gstAmount;
  final double previousOutstandingSnapshot;
  final double? currentBalanceSnapshot;
  final double grandTotal;
  final double amountPaid;
  final double advanceApplied;
  final double remainingBalance;
  final String status; // 'active' / 'void'
  final String? voidReason;
  final DateTime? voidedAt;
  final bool isWholesaleBill;
  final String? notes;
  final DateTime? createdAt;
  final List<BillItemDetail> items;

  const BillModel({
    required this.id,
    required this.billNumber,
    this.saleChannel = 'invoice',
    this.customerId,
    this.customerName = 'Walk-in Customer',
    required this.billDate,
    required this.subtotal,
    this.discount = 0.0,
    this.otherCharges = 0.0,
    this.gstEnabled = false,
    this.gstPercent,
    this.taxableAmount = 0.0,
    this.gstAmount = 0.0,
    this.previousOutstandingSnapshot = 0.0,
    this.currentBalanceSnapshot,
    required this.grandTotal,
    this.amountPaid = 0.0,
    this.advanceApplied = 0.0,
    required this.remainingBalance,
    this.status = 'active',
    this.voidReason,
    this.voidedAt,
    this.isWholesaleBill = false,
    this.notes,
    this.createdAt,
    this.items = const [],
  });

  bool get isQuickSale => saleChannel == 'quick_sale';
  bool get isWalkIn => customerId == null;

  BillBalances get balances => resolveBillBalancesFromModel(this);

  BillPaymentStatus get paymentStatus => computeBillStatus(
        status: status,
        remainingBalance: remainingBalance,
        grandTotal: grandTotal,
        amountPaid: amountPaid,
      );

  bool get isPaid => paymentStatus == BillPaymentStatus.paid;
  bool get isUnpaid => paymentStatus == BillPaymentStatus.unpaid;
  bool get isPartial => paymentStatus == BillPaymentStatus.partial;
  bool get isVoided => paymentStatus == BillPaymentStatus.voided;

  factory BillModel.fromEntity(BillEntity entity, {String? customerName, List<BillItemDetail> items = const []}) {
    return BillModel(
      id: entity.id,
      billNumber: entity.billNumber,
      saleChannel: entity.saleChannel,
      customerId: entity.customerId,
      customerName: customerName ?? (entity.customerId == null ? 'Walk-in Customer' : 'Customer #${entity.customerId}'),
      billDate: entity.billDate,
      subtotal: entity.subtotal,
      discount: entity.discount,
      otherCharges: entity.otherCharges,
      gstEnabled: entity.gstEnabled,
      gstPercent: entity.gstPercent,
      taxableAmount: entity.taxableAmount == 0.0 && !entity.gstEnabled ? entity.grandTotal : entity.taxableAmount,
      gstAmount: entity.gstAmount,
      previousOutstandingSnapshot: entity.previousOutstandingSnapshot,
      currentBalanceSnapshot: entity.currentBalanceSnapshot,
      grandTotal: entity.grandTotal,
      amountPaid: entity.amountPaid,
      advanceApplied: entity.advanceApplied,
      remainingBalance: entity.remainingBalance,
      status: entity.status,
      voidReason: entity.voidReason,
      voidedAt: entity.voidedAt,
      isWholesaleBill: entity.isWholesaleBill,
      notes: entity.notes,
      createdAt: entity.createdAt,
      items: items,
    );
  }
}
