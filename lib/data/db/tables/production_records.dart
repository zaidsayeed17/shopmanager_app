import 'package:drift/drift.dart';
import 'items.dart';
import 'worker_transactions.dart';
import 'workers.dart';

@DataClassName('ProductionRecordEntity')
class ProductionRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workerId => integer().references(Workers, #id)();
  IntColumn get workerTransactionId => integer().nullable().references(WorkerTransactions, #id)();
  IntColumn get outputItemId => integer().references(Items, #id)();
  RealColumn get outputQty => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get batchRef => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
