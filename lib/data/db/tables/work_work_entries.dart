import 'package:drift/drift.dart';
import 'workers.dart';

@DataClassName('WorkWorkEntryEntity')
class WorkWorkEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workerId => integer().references(Workers, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get workDescription => text().nullable()();
  RealColumn get hours => real().nullable()();
  RealColumn get hourRate => real().nullable()();
  RealColumn get hourAmount => real().withDefault(const Constant(0.0))();
  RealColumn get nagQty => real().nullable()();
  RealColumn get nagRate => real().nullable()();
  RealColumn get nagAmount => real().withDefault(const Constant(0.0))();
  RealColumn get totalAmount => real().withDefault(const Constant(0.0))();
  RealColumn get advance => real().withDefault(const Constant(0.0))();
  RealColumn get finalPayable => real().withDefault(const Constant(0.0))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
