import 'package:drift/drift.dart';

@DataClassName('ItemEntity')
class Items extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get category => text().nullable()();
  TextColumn get sku => text().nullable()();
  TextColumn get type => text()(); // 'raw_material' or 'finished_product'
  TextColumn get unit => text()();
  RealColumn get purchaseRate => real().withDefault(const Constant(0.0))();
  RealColumn get sellingRate => real().withDefault(const Constant(0.0))();
  RealColumn get wholesaleRate => real().nullable()();
  RealColumn get openingQty => real().withDefault(const Constant(0.0))();
  RealColumn get currentQty => real().withDefault(const Constant(0.0))();
  RealColumn get minStockLevel => real().withDefault(const Constant(0.0))();
  TextColumn get supplierInfo => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
