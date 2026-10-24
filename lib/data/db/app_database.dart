import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/bill_items.dart';
import 'tables/bills.dart';
import 'tables/customers.dart';
import 'tables/items.dart';
import 'tables/ledger_entries.dart';
import 'tables/payments.dart';
import 'tables/production_records.dart';
import 'tables/production_inputs.dart';
import 'tables/settings_table.dart';
import 'tables/stock_transactions.dart';
import 'tables/worker_transactions.dart';
import 'tables/workers.dart';
import 'tables/work_work_entries.dart';
import 'tables/worker_cutting_entries.dart';
import 'tables/selling_products.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Customers,
  Items,
  StockTransactions,
  Workers,
  WorkerTransactions,
  ProductionRecords,
  ProductionInputs,
  Bills,
  BillItems,
  Payments,
  LedgerEntries,
  SettingsTable,
  WorkWorkEntries,
  WorkerCuttingEntries,
  SellingProducts,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 12;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(stockTransactions, stockTransactions.unitRate);
          }
          if (from < 3) {
            await m.createTable(productionInputs);
            await m.drop(productionRecords);
            await m.createTable(productionRecords);
          }
          if (from < 4) {
            await m.addColumn(bills, bills.voidReason);
            await m.addColumn(bills, bills.voidedAt);
          }
          if (from < 5) {
            await m.addColumn(payments, payments.type);
            await m.addColumn(bills, bills.advanceApplied);
          }
          if (from < 6) {
            await m.addColumn(bills, bills.gstEnabled);
            await m.addColumn(bills, bills.gstPercent);
            await m.addColumn(bills, bills.taxableAmount);
            await m.addColumn(bills, bills.gstAmount);
            await customStatement(
              'UPDATE bills SET taxable_amount = grand_total WHERE taxable_amount = 0 AND gst_enabled = 0;'
            );
          }
          if (from < 7) {
            await m.addColumn(workers, workers.joiningDate);
            await m.addColumn(workers, workers.paymentType);
            await m.addColumn(workers, workers.defaultHourRate);
            await m.addColumn(workers, workers.defaultNagRate);
            await m.createTable(workWorkEntries);
          }
          if (from < 8) {
            await m.createTable(workerCuttingEntries);
          }
          if (from < 9) {
            await m.addColumn(items, items.sku);
            await m.addColumn(bills, bills.saleChannel);
            // ignore: experimental_member_use
            await m.alterTable(TableMigration(bills));
          }
          if (from < 10) {
            await m.addColumn(customers, customers.isWholesale);
            await m.addColumn(bills, bills.isWholesaleBill);
            await m.addColumn(billItems, billItems.mrpRateAtSale);
          }
          if (from < 11) {
            await m.createTable(sellingProducts);
            await m.addColumn(items, items.wholesaleRate);
            // ignore: experimental_member_use
            await m.alterTable(TableMigration(billItems));
            await customStatement('''
              UPDATE bill_items 
              SET product_name = (SELECT name FROM items WHERE items.id = bill_items.item_id)
              WHERE product_name IS NULL AND item_id IS NOT NULL;
            ''');
          }
          if (from < 12) {
            await m.addColumn(bills, bills.currentBalanceSnapshot);
          }
        },
      );

  static Future<File> getDatabaseFile() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return File(p.join(dbFolder.path, 'shopmanager.db'));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = await AppDatabase.getDatabaseFile();
    return NativeDatabase.createInBackground(file);
  });
}
