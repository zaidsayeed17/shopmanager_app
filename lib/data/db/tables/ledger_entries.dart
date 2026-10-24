import 'package:drift/drift.dart';
import 'customers.dart';

@DataClassName('LedgerEntryEntity')
class LedgerEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get customerId => integer().references(Customers, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get type => text()(); // 'bill'/'payment'/'opening_balance'
  IntColumn get referenceId => integer().nullable()();
  RealColumn get debit => real().withDefault(const Constant(0.0))();
  RealColumn get credit => real().withDefault(const Constant(0.0))();
  RealColumn get runningBalance => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
