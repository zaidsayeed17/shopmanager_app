import 'package:drift/drift.dart';
import 'items.dart';
import 'production_records.dart';

@DataClassName('ProductionInputEntity')
class ProductionInputs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productionRecordId => integer().references(ProductionRecords, #id)();
  IntColumn get itemId => integer().references(Items, #id)();
  RealColumn get quantityUsed => real()();
  RealColumn get quantityReturned => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
