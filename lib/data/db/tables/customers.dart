import 'package:drift/drift.dart';

@DataClassName('CustomerEntity')
class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get mobile => text()();
  TextColumn get address => text().nullable()();
  TextColumn get gstInfo => text().nullable()();
  RealColumn get openingBalance => real().withDefault(const Constant(0.0))();
  TextColumn get notes => text().nullable()();
  BoolColumn get isWholesale => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
