import 'package:drift/drift.dart';
import 'bills.dart';
import 'items.dart';
import 'selling_products.dart';

@DataClassName('BillItemEntity')
class BillItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get billId => integer().references(Bills, #id)();
  IntColumn get itemId => integer().nullable().references(Items, #id)();
  IntColumn get sellingProductId => integer().nullable().references(SellingProducts, #id)();
  TextColumn get productName => text().nullable()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  RealColumn get rate => real()();
  RealColumn get mrpRateAtSale => real().nullable()();
  RealColumn get amount => real()();
}
