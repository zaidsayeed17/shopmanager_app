import 'package:drift/drift.dart';

@DataClassName('SellingProductEntity')
class SellingProducts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  RealColumn get price => real().withDefault(const Constant(0.0))(); // Retail / regular price
  RealColumn get wholesalePrice => real().nullable()(); // Optional wholesale price
  TextColumn get photoPath => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
