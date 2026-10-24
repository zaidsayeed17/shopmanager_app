import 'package:drift/drift.dart';

@DataClassName('WorkerEntity')
class Workers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get mobile => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get workType => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get joiningDate => dateTime().nullable()();
  TextColumn get paymentType => text().nullable()();
  RealColumn get defaultHourRate => real().nullable()();
  RealColumn get defaultNagRate => real().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
