import 'package:drift/drift.dart';
import 'items.dart';

@DataClassName('StockTransactionEntity')
class StockTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get itemId => integer().references(Items, #id)();
  TextColumn get type => text()();
  RealColumn get quantity => real()(); // positive or negative
  RealColumn get unitRate => real().nullable()();
  TextColumn get referenceType => text().nullable()();
  IntColumn get referenceId => integer().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
