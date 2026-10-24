import 'package:drift/drift.dart';
import 'items.dart';
import 'workers.dart';

@DataClassName('WorkerTransactionEntity')
class WorkerTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workerId => integer().references(Workers, #id)();
  IntColumn get itemId => integer().references(Items, #id)();
  RealColumn get quantityIssued => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get status => text()(); // 'pending'/'partial'/'completed'
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
