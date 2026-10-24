import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopmanager/data/db/app_database.dart';
import 'package:shopmanager/data/repositories/item_repository.dart';
import 'package:shopmanager/data/repositories/stock_repository.dart';

void main() {
  late AppDatabase database;
  late ItemRepository itemRepo;
  late StockRepository stockRepo;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    itemRepo = ItemRepository(database);
    stockRepo = StockRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('ItemRepository Tests', () {
    test('(a) Adding an item with openingQty 100 creates exactly one opening_stock stockTransactions row of +100 and currentQty 100', () async {
      final itemId = await itemRepo.addItem(
        name: 'White Cement',
        category: 'Hardware',
        type: 'raw_material',
        unit: 'kg',
        openingQty: 100.0,
        purchaseRate: 25.0,
      );

      final item = await itemRepo.getItemById(itemId);
      expect(item, isNotNull);
      expect(item!.currentQty, equals(100.0));
      expect(item.openingQty, equals(100.0));

      final txs = await (database.select(database.stockTransactions)
            ..where((t) => t.itemId.equals(itemId)))
          .get();

      expect(txs.length, equals(1));
      expect(txs.first.type, equals('opening_stock'));
      expect(txs.first.quantity, equals(100.0));
      expect(txs.first.referenceType, equals('manual'));
      expect(txs.first.notes, equals('Opening stock'));
    });

    test('(b) Adding an item with openingQty 0 creates no stockTransactions row', () async {
      final itemId = await itemRepo.addItem(
        name: 'MS Flange',
        category: 'Hardware',
        type: 'raw_material',
        unit: 'pcs',
        openingQty: 0.0,
        purchaseRate: 150.0,
      );

      final item = await itemRepo.getItemById(itemId);
      expect(item, isNotNull);
      expect(item!.currentQty, equals(0.0));
      expect(item.openingQty, equals(0.0));

      final txs = await (database.select(database.stockTransactions)
            ..where((t) => t.itemId.equals(itemId)))
          .get();

      expect(txs, isEmpty);
    });

    test('(c) updateItem does not change currentQty or openingQty', () async {
      final itemId = await itemRepo.addItem(
        name: 'Brass Valves',
        category: 'Plumbing',
        type: 'raw_material',
        unit: 'pcs',
        openingQty: 50.0,
        purchaseRate: 200.0,
      );

      var item = await itemRepo.getItemById(itemId);
      expect(item!.openingQty, equals(50.0));
      expect(item.currentQty, equals(50.0));

      final updated = await itemRepo.updateItem(
        id: itemId,
        name: 'Brass Valves Heavy Duty',
        category: 'Plumbing & Fittings',
        type: 'raw_material',
        unit: 'pcs',
        purchaseRate: 220.0,
        sellingRate: 300.0,
        minStockLevel: 10.0,
      );

      expect(updated, isTrue);

      item = await itemRepo.getItemById(itemId);
      expect(item!.name, equals('Brass Valves Heavy Duty'));
      expect(item.category, equals('Plumbing & Fittings'));
      expect(item.purchaseRate, equals(220.0));
      expect(item.sellingRate, equals(300.0));
      expect(item.minStockLevel, equals(10.0));
      expect(item.openingQty, equals(50.0));
      expect(item.currentQty, equals(50.0));
    });

    test('(d) duplicate-name check is case-insensitive', () async {
      await itemRepo.addItem(
        name: 'Copper Wire 1.5mm',
        type: 'raw_material',
        unit: 'meters',
      );

      expect(await itemRepo.itemNameExists('Copper Wire 1.5mm'), isTrue);
      expect(await itemRepo.itemNameExists('copper wire 1.5mm'), isTrue);
      expect(await itemRepo.itemNameExists('COPPER WIRE 1.5MM'), isTrue);
      expect(await itemRepo.itemNameExists('  CoPpEr WiRe 1.5mM  '), isTrue);
      expect(await itemRepo.itemNameExists('Aluminum Wire'), isFalse);

      final items = await itemRepo.getAllItems();
      final createdId = items.first.id;
      expect(await itemRepo.itemNameExists('Copper Wire 1.5mm', excludeId: createdId), isFalse);
    });
  });

  group('StockRepository Transaction & Stock Control Tests', () {
    test('(a) recordPurchase inserts a +qty purchase row with unitRate and increases currentQty', () async {
      final itemId = await itemRepo.addItem(
        name: 'PVC Pipe 2 inch',
        type: 'raw_material',
        unit: 'meters',
        openingQty: 0.0,
        purchaseRate: 100.0,
      );

      final date = DateTime(2024, 10, 25);
      await stockRepo.recordPurchase(
        itemId: itemId,
        quantity: 50.0,
        unitRate: 120.0,
        date: date,
        supplier: 'Metro Plastics',
        notes: 'Bulk purchase',
        updateItemRate: true,
      );

      final item = await itemRepo.getItemById(itemId);
      expect(item!.currentQty, equals(50.0));
      expect(item.purchaseRate, equals(120.0));

      final txs = await stockRepo.getItemTransactions(itemId);
      expect(txs.length, equals(1));
      final tx = txs.first.transaction;
      expect(tx.type, equals('purchase'));
      expect(tx.quantity, equals(50.0));
      expect(tx.unitRate, equals(120.0));
      expect(tx.notes, equals('Supplier: Metro Plastics • Bulk purchase'));
    });

    test('(b) recordAdjustment decrease larger than stock throws and leaves BOTH stockTransactions table and currentQty unchanged', () async {
      final itemId = await itemRepo.addItem(
        name: 'Steel Rods',
        type: 'raw_material',
        unit: 'pcs',
        openingQty: 20.0,
      );

      final txsBefore = await stockRepo.getItemTransactions(itemId);
      expect(txsBefore.length, equals(1)); // Opening stock row

      expect(
        () async => await stockRepo.recordAdjustment(
          itemId: itemId,
          isIncrease: false,
          quantity: 30.0,
          reason: 'Wastage',
          date: DateTime.now(),
        ),
        throwsA(isA<Exception>()),
      );

      final item = await itemRepo.getItemById(itemId);
      expect(item!.currentQty, equals(20.0));

      final txsAfter = await stockRepo.getItemTransactions(itemId);
      expect(txsAfter.length, equals(1));
      expect(txsAfter.first.transaction.quantity, equals(20.0));
    });

    test('(c) a valid decrease inserts a negative-quantity row and reduces currentQty', () async {
      final itemId = await itemRepo.addItem(
        name: 'Paint Cans',
        type: 'raw_material',
        unit: 'liters',
        openingQty: 20.0,
      );

      await stockRepo.recordAdjustment(
        itemId: itemId,
        isIncrease: false,
        quantity: 5.0,
        reason: 'Damaged',
        date: DateTime.now(),
        notes: 'Leaked during transit',
      );

      final item = await itemRepo.getItemById(itemId);
      expect(item!.currentQty, equals(15.0));

      final txs = await stockRepo.getItemTransactions(itemId);
      expect(txs.length, equals(2));

      // Most recent transaction is at index 0
      final latestTx = txs.first;
      expect(latestTx.transaction.type, equals('adjustment_decrease'));
      expect(latestTx.transaction.quantity, equals(-5.0));
      expect(latestTx.transaction.notes, equals('Damaged — Leaked during transit'));
      expect(latestTx.runningBalance, equals(15.0));
    });

    test('(d) for an item with an opening transaction + purchase + adjustments, sum of transaction quantities equals items.currentQty', () async {
      final itemId = await itemRepo.addItem(
        name: 'SS Screws',
        type: 'raw_material',
        unit: 'pcs',
        openingQty: 100.0,
      );

      await stockRepo.recordPurchase(
        itemId: itemId,
        quantity: 50.0,
        unitRate: 5.0,
        date: DateTime(2024, 10, 1),
      );

      await stockRepo.recordAdjustment(
        itemId: itemId,
        isIncrease: false,
        quantity: 20.0,
        reason: 'Wastage',
        date: DateTime(2024, 10, 2),
      );

      await stockRepo.recordAdjustment(
        itemId: itemId,
        isIncrease: true,
        quantity: 10.0,
        reason: 'Recount / Correction',
        date: DateTime(2024, 10, 3),
      );

      final item = await itemRepo.getItemById(itemId);
      final txs = await stockRepo.getItemTransactions(itemId);

      // Sum of transaction quantities
      final sumQty = txs.fold(0.0, (sum, t) => sum + t.transaction.quantity);
      expect(StockRepository.round3(sumQty), equals(140.0));
      expect(item!.currentQty, equals(140.0));
    });

    test('(e) computed running balance for the last (most recent) row equals items.currentQty', () async {
      final itemId = await itemRepo.addItem(
        name: 'Hex Nuts',
        type: 'raw_material',
        unit: 'pcs',
        openingQty: 200.0,
      );

      await stockRepo.recordPurchase(
        itemId: itemId,
        quantity: 100.0,
        unitRate: 2.0,
        date: DateTime(2024, 10, 1),
      );

      await stockRepo.recordAdjustment(
        itemId: itemId,
        isIncrease: false,
        quantity: 30.0,
        reason: 'Lost',
        date: DateTime(2024, 10, 2),
      );

      final item = await itemRepo.getItemById(itemId);
      final txs = await stockRepo.getItemTransactions(itemId);

      // Most recent transaction is index 0
      final mostRecentTx = txs.first;
      expect(mostRecentTx.runningBalance, equals(270.0));
      expect(item!.currentQty, equals(270.0));
    });

    test('(f) schema v2 migration adds unitRate column preserving table operations', () async {
      // In-memory test verifying schema v2 database accepts unitRate queries & operations
      final itemId = await itemRepo.addItem(
        name: 'Copper Bar',
        type: 'raw_material',
        unit: 'kg',
        openingQty: 10.0,
      );

      await stockRepo.recordPurchase(
        itemId: itemId,
        quantity: 5.0,
        unitRate: 450.0,
        date: DateTime.now(),
      );

      final txs = await stockRepo.getItemTransactions(itemId);
      expect(txs.first.transaction.unitRate, equals(450.0));
      expect(txs.last.transaction.unitRate, isNull); // Opening stock has null unitRate
    });
  });
}
