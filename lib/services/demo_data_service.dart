import 'package:drift/drift.dart';
import '../data/db/app_database.dart';

class DemoCleanupSummary {
  final List<String> removed;
  final List<String> deactivated;
  final List<String> skipped;

  const DemoCleanupSummary({
    required this.removed,
    required this.deactivated,
    required this.skipped,
  });
}

class DemoDataService {
  final AppDatabase _db;

  DemoDataService(this._db);

  /// Check if there are any demo customer IDs in settings that still exist in database
  Future<bool> hasDemoDataToClean() async {
    final query = _db.select(_db.settingsTable)..where((t) => t.key.equals('demo_customer_ids'));
    final setting = await query.getSingleOrNull();
    if (setting?.value == null || setting!.value!.trim().isEmpty) {
      return false;
    }

    final ids = setting.value!
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toList();

    if (ids.isEmpty) return false;

    // Check if any of those IDs exist in customers table
    final countExp = _db.customers.id.count();
    final countQuery = _db.selectOnly(_db.customers)
      ..addColumns([countExp])
      ..where(_db.customers.id.isIn(ids));
    final result = await countQuery.map((row) => row.read(countExp)).getSingle();

    return (result ?? 0) > 0;
  }

  /// Clean demo data: hard-delete unused demo customers, soft-deactivate used ones, then clear settings key
  Future<DemoCleanupSummary> cleanDemoData() async {
    final query = _db.select(_db.settingsTable)..where((t) => t.key.equals('demo_customer_ids'));
    final setting = await query.getSingleOrNull();

    if (setting?.value == null || setting!.value!.trim().isEmpty) {
      return const DemoCleanupSummary(removed: [], deactivated: [], skipped: []);
    }

    final ids = setting.value!
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toList();

    if (ids.isEmpty) {
      return const DemoCleanupSummary(removed: [], deactivated: [], skipped: []);
    }

    final removedNames = <String>[];
    final deactivatedNames = <String>[];
    final skippedNames = <String>[];

    await _db.transaction(() async {
      for (final id in ids) {
        final custQuery = _db.select(_db.customers)..where((t) => t.id.equals(id));
        final customer = await custQuery.getSingleOrNull();
        if (customer == null) {
          continue;
        }

        // Check if customer has any bills, payments, or ledgerEntries
        final billCountExp = _db.bills.id.count();
        final billQuery = _db.selectOnly(_db.bills)
          ..addColumns([billCountExp])
          ..where(_db.bills.customerId.equals(id));
        final billCount = (await billQuery.map((r) => r.read(billCountExp)).getSingle()) ?? 0;

        final paymentCountExp = _db.payments.id.count();
        final paymentQuery = _db.selectOnly(_db.payments)
          ..addColumns([paymentCountExp])
          ..where(_db.payments.customerId.equals(id));
        final paymentCount = (await paymentQuery.map((r) => r.read(paymentCountExp)).getSingle()) ?? 0;

        final ledgerCountExp = _db.ledgerEntries.id.count();
        final ledgerQuery = _db.selectOnly(_db.ledgerEntries)
          ..addColumns([ledgerCountExp])
          ..where(_db.ledgerEntries.customerId.equals(id));
        final ledgerCount = (await ledgerQuery.map((r) => r.read(ledgerCountExp)).getSingle()) ?? 0;

        final hasRelatedData = (billCount > 0) || (paymentCount > 0) || (ledgerCount > 0);

        if (!hasRelatedData) {
          // Hard-delete unused demo customer (one deliberate exception for seed demo data)
          await (_db.delete(_db.customers)..where((t) => t.id.equals(id))).go();
          removedNames.add(customer.name);
        } else {
          // Soft-deactivate used demo customer
          if (customer.isActive) {
            await (_db.update(_db.customers)..where((t) => t.id.equals(id))).write(
              const CustomersCompanion(isActive: Value(false)),
            );
          }
          deactivatedNames.add(customer.name);
        }
      }

      // Clear settings key so this cannot run twice
      await (_db.delete(_db.settingsTable)..where((t) => t.key.equals('demo_customer_ids'))).go();
    });

    return DemoCleanupSummary(
      removed: removedNames,
      deactivated: deactivatedNames,
      skipped: skippedNames,
    );
  }
}
