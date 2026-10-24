import '../../data/db/app_database.dart';
import '../../data/models/bill_model.dart';

class BillBalances {
  final double previous;
  final double current;

  const BillBalances({
    required this.previous,
    required this.current,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillBalances &&
          runtimeType == other.runtimeType &&
          (previous - other.previous).abs() < 0.005 &&
          (current - other.current).abs() < 0.005;

  @override
  int get hashCode => Object.hash(
        (previous * 100).round(),
        (current * 100).round(),
      );

  @override
  String toString() => 'BillBalances(previous: $previous, current: $current)';
}

/// Resolves bill previous and current balances according to single source of truth:
/// - previous = bill.previousOutstandingSnapshot
/// - current = bill.currentBalanceSnapshot if present; otherwise fallback for historical bills:
///   previous + grandTotal - (amountPaid - advanceApplied)
BillBalances resolveBillBalances({
  required double previousOutstandingSnapshot,
  required double? currentBalanceSnapshot,
  required double grandTotal,
  required double amountPaid,
  required double advanceApplied,
}) {
  final prev = (previousOutstandingSnapshot * 100).roundToDouble() / 100.0;
  final curr = currentBalanceSnapshot != null
      ? ((currentBalanceSnapshot * 100).roundToDouble() / 100.0)
      : (((prev + grandTotal - (amountPaid - advanceApplied)) * 100).roundToDouble() / 100.0);

  return BillBalances(
    previous: prev,
    current: curr,
  );
}

/// Resolves balances directly from a Drift [BillEntity]
BillBalances resolveBillBalancesFromEntity(BillEntity bill) {
  return resolveBillBalances(
    previousOutstandingSnapshot: bill.previousOutstandingSnapshot,
    currentBalanceSnapshot: bill.currentBalanceSnapshot,
    grandTotal: bill.grandTotal,
    amountPaid: bill.amountPaid,
    advanceApplied: bill.advanceApplied,
  );
}

/// Resolves balances directly from a [BillModel]
BillBalances resolveBillBalancesFromModel(BillModel bill) {
  return resolveBillBalances(
    previousOutstandingSnapshot: bill.previousOutstandingSnapshot,
    currentBalanceSnapshot: bill.currentBalanceSnapshot,
    grandTotal: bill.grandTotal,
    amountPaid: bill.amountPaid,
    advanceApplied: bill.advanceApplied,
  );
}

/// Format signed customer balance:
/// - |x| < 0.005 -> "₹0.00" with no label
/// - x > 0 -> "₹X Due"
/// - x < 0 -> "₹|x| Advance"
/// Formatted using standard Indian currency notation.
String describeBalance(double? signedBalance) {
  if (signedBalance == null) return '₹0.00';
  final rounded = (signedBalance * 100).roundToDouble() / 100.0;
  if (rounded.abs() < 0.005) {
    return '₹0.00';
  }
  final absVal = rounded.abs();
  final formattedNum = absVal % 1 == 0
      ? absVal.toInt().toString().replaceAllMapped(
            RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))'),
            (m) => '${m[1]},',
          )
      : absVal.toStringAsFixed(2);
  if (rounded > 0) {
    return '₹$formattedNum Due';
  } else {
    return '₹$formattedNum Advance';
  }
}
