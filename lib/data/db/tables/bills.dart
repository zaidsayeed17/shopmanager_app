import 'package:drift/drift.dart';
import 'customers.dart';

@DataClassName('BillEntity')
class Bills extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get billNumber => text().unique()();
  TextColumn get saleChannel => text().withDefault(const Constant('invoice'))(); // 'invoice'/'quick_sale'
  IntColumn get customerId => integer().nullable().references(Customers, #id)();
  DateTimeColumn get billDate => dateTime()();
  RealColumn get subtotal => real()();
  RealColumn get discount => real().withDefault(const Constant(0.0))();
  RealColumn get otherCharges => real().withDefault(const Constant(0.0))();
  RealColumn get previousOutstandingSnapshot => real().withDefault(const Constant(0.0))();
  RealColumn get currentBalanceSnapshot => real().nullable()();
  RealColumn get grandTotal => real()();
  RealColumn get amountPaid => real().withDefault(const Constant(0.0))();
  RealColumn get advanceApplied => real().withDefault(const Constant(0.0))();
  BoolColumn get gstEnabled => boolean().withDefault(const Constant(false))();
  RealColumn get gstPercent => real().nullable()();
  RealColumn get taxableAmount => real().withDefault(const Constant(0.0))();
  RealColumn get gstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get remainingBalance => real()();
  TextColumn get status => text().withDefault(const Constant('active'))(); // 'active'/'void'
  TextColumn get voidReason => text().nullable()();
  DateTimeColumn get voidedAt => dateTime().nullable()();
  BoolColumn get isWholesaleBill => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
