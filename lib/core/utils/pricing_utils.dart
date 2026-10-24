/// Pure utility for determining unit prices based on customer type (Retail vs Wholesale).
///
/// If [isWholesaleCustomer] is true, [wholesale] is provided, and [wholesale] > 0,
/// the wholesale rate is returned.
/// In all other cases (normal retail customer, walk-in customer, or missing wholesale price),
/// the [retail] rate is returned.
double resolveUnitPrice({
  required double retail,
  double? wholesale,
  required bool isWholesaleCustomer,
}) {
  if (isWholesaleCustomer && wholesale != null && wholesale > 0) {
    return wholesale;
  }
  return retail;
}
