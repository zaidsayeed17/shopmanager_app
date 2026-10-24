import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopmanager/data/db/app_database.dart';
import 'package:shopmanager/data/models/bill_model.dart';
import 'package:shopmanager/data/repositories/billing_repository.dart';
import 'package:shopmanager/data/repositories/customer_repository.dart';
import 'package:shopmanager/data/repositories/item_repository.dart';
import 'package:shopmanager/data/repositories/worker_repository.dart';
import 'package:shopmanager/data/repositories/worker_wage_repository.dart';
import 'package:shopmanager/data/repositories/worker_cutting_repository.dart';
import 'package:shopmanager/services/factory_reset_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return Directory.systemTemp.path;
      },
    );
  });

  late AppDatabase db;
  late CustomerRepository customerRepo;
  late ItemRepository itemRepo;
  late WorkerRepository workerRepo;
  late WorkerWageRepository wageRepo;
  late WorkerCuttingRepository cuttingRepo;
  late BillingRepository billingRepo;
  late FactoryResetService factoryResetService;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    customerRepo = CustomerRepository(db);
    itemRepo = ItemRepository(db);
    workerRepo = WorkerRepository(db);
    wageRepo = WorkerWageRepository(db);
    cuttingRepo = WorkerCuttingRepository(db);
    billingRepo = BillingRepository(db);
    factoryResetService = FactoryResetService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Factory Reset Service Tests', () {
    test('resetAllData() clears all 13 tables and resets bill numbering to INV-0001', () async {
      // 1. Populate data
      final custId = await customerRepo.addCustomer(name: 'Alice', mobile: '9999999999');
      final itemId = await itemRepo.addItem(
        name: 'Item A',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 50.0,
        sellingRate: 100.0,
        openingQty: 10.0,
      );
      final workerId = await workerRepo.addWorker(
        name: 'Bob',
        paymentType: 'both',
        defaultHourRate: 100.0,
        defaultNagRate: 10.0,
      );

      // Seed worker wage entry
      await wageRepo.addWorkEntry(
        workerId: workerId,
        date: DateTime.now(),
        hours: 8,
        hourRate: 100,
      );

      // Seed worker cutting entry
      await cuttingRepo.addCuttingEntry(
        workerId: workerId,
        itemId: itemId,
        date: DateTime.now(),
        quantity: 5,
        rate: 10,
      );

      // Create 2 bills to advance next_bill_number to 3 (INV-0002)
      final bill1 = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 100.0)],
      );
      expect(bill1, equals('INV-0001'));

      final bill2 = await billingRepo.saveBill(
        customerId: custId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: itemId, quantity: 1, rate: 100.0)],
      );
      expect(bill2, equals('INV-0002'));

      // Verify DB is populated
      final customersBefore = await db.select(db.customers).get();
      final itemsBefore = await db.select(db.items).get();
      final billsBefore = await db.select(db.bills).get();
      final wageBefore = await db.select(db.workWorkEntries).get();
      final cuttingBefore = await db.select(db.workerCuttingEntries).get();
      expect(customersBefore.length, equals(1));
      expect(itemsBefore.length, equals(1));
      expect(billsBefore.length, equals(2));
      expect(wageBefore.length, equals(1));
      expect(cuttingBefore.length, equals(1));

      // 2. Perform Factory Reset
      await factoryResetService.resetAllData();

      // 3. Verify all 13 tables are empty
      expect((await db.select(db.customers).get()).isEmpty, isTrue);
      expect((await db.select(db.items).get()).isEmpty, isTrue);
      expect((await db.select(db.workers).get()).isEmpty, isTrue);
      expect((await db.select(db.bills).get()).isEmpty, isTrue);
      expect((await db.select(db.billItems).get()).isEmpty, isTrue);
      expect((await db.select(db.payments).get()).isEmpty, isTrue);
      expect((await db.select(db.ledgerEntries).get()).isEmpty, isTrue);
      expect((await db.select(db.stockTransactions).get()).isEmpty, isTrue);
      expect((await db.select(db.workerTransactions).get()).isEmpty, isTrue);
      expect((await db.select(db.productionRecords).get()).isEmpty, isTrue);
      expect((await db.select(db.productionInputs).get()).isEmpty, isTrue);
      expect((await db.select(db.workWorkEntries).get()).isEmpty, isTrue);
      expect((await db.select(db.workerCuttingEntries).get()).isEmpty, isTrue);
      expect((await db.select(db.settingsTable).get()).isEmpty, isTrue);

      // 4. Verify that new bill after reset starts at INV-0001
      final newCustId = await customerRepo.addCustomer(name: 'Charlie', mobile: '8888888888');
      final newItemId = await itemRepo.addItem(
        name: 'Item B',
        type: 'finished_product',
        unit: 'pcs',
        purchaseRate: 20.0,
        sellingRate: 50.0,
        openingQty: 5.0,
      );

      final newBill = await billingRepo.saveBill(
        customerId: newCustId,
        billDate: DateTime.now(),
        lines: [BillLine(itemId: newItemId, quantity: 1, rate: 50.0)],
      );

      expect(newBill, equals('INV-0001'));
    });
  });
}
