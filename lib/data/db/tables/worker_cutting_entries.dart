import 'package:drift/drift.dart';
import 'items.dart';
import 'workers.dart';

@DataClassName('WorkerCuttingEntryEntity')
class WorkerCuttingEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workerId => integer().references(Workers, #id)();
  IntColumn get itemId => integer().references(Items, #id)();
  DateTimeColumn get date => dateTime()();
  RealColumn get quantity => real()();
  RealColumn get rate => real()();
  RealColumn get totalAmount => real().withDefault(const Constant(0.0))();
  TextColumn get remark => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
