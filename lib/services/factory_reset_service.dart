import '../data/db/app_database.dart';

class FactoryResetService {
  final AppDatabase _db;

  FactoryResetService(this._db);

  /// Performs a complete factory reset of all business data inside a single Drift transaction.
  /// Deletes all records from 13 tables in reverse foreign key order and resets bill numbering.
  Future<void> resetAllData() async {
    await _db.transaction(() async {
      // 1. Delete ledger entries (references customer, bill, payment)
      await _db.delete(_db.ledgerEntries).go();

      // 2. Delete payments (references customer, bill)
      await _db.delete(_db.payments).go();

      // 3. Delete bill items (references bill, item)
      await _db.delete(_db.billItems).go();

      // 4. Delete bills (references customer)
      await _db.delete(_db.bills).go();

      // 5. Delete production inputs (references productionRecord, item)
      await _db.delete(_db.productionInputs).go();

      // 6. Delete production records (references worker, output item)
      await _db.delete(_db.productionRecords).go();

      // 7. Delete worker transactions (references worker)
      await _db.delete(_db.workerTransactions).go();

      // 8. Delete worker wage entries (references worker)
      await _db.delete(_db.workWorkEntries).go();

      // 9. Delete worker cutting entries (references worker, item)
      await _db.delete(_db.workerCuttingEntries).go();

      // 10. Delete stock transactions (references item)
      await _db.delete(_db.stockTransactions).go();

      // 11. Delete items
      await _db.delete(_db.items).go();

      // 12. Delete selling products
      await _db.delete(_db.sellingProducts).go();

      // 12. Delete workers
      await _db.delete(_db.workers).go();

      // 13. Delete customers
      await _db.delete(_db.customers).go();

      // 12. Clear settings (including next_bill_number so next bill starts at INV-0001)
      await _db.delete(_db.settingsTable).go();
    });
  }
}
