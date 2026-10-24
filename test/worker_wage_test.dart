import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopmanager/data/db/app_database.dart';
import 'package:shopmanager/data/repositories/worker_repository.dart';
import 'package:shopmanager/data/repositories/worker_wage_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return Directory.systemTemp.path;
      },
    );
  });

  late AppDatabase db;
  late WorkerRepository workerRepo;
  late WorkerWageRepository wageRepo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    workerRepo = WorkerRepository(db);
    wageRepo = WorkerWageRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Worker Wage Tracking Module Tests', () {
    test('(a) Hour-only worker: 8 hours × ₹100 = ₹800 total', () async {
      final wId = await workerRepo.addWorker(
        name: 'Ramesh Hour Worker',
        mobile: '9876543210',
        paymentType: 'hour',
        defaultHourRate: 100.0,
      );

      final entryId = await wageRepo.addWorkEntry(
        workerId: wId,
        date: DateTime.now(),
        hours: 8.0,
        hourRate: 100.0,
      );

      final entries = await wageRepo.getWorkEntriesForWorker(wId);
      expect(entries.length, equals(1));
      final entry = entries.first;

      expect(entry.id, equals(entryId));
      expect(entry.hours, equals(8.0));
      expect(entry.hourRate, equals(100.0));
      expect(entry.hourAmount, equals(800.0));
      expect(entry.nagQty, isNull);
      expect(entry.nagAmount, equals(0.0));
      expect(entry.totalAmount, equals(800.0));
      expect(entry.advance, equals(0.0));
      expect(entry.finalPayable, equals(800.0));
      expect(getWorkEntryStatus(entry.totalAmount, entry.advance), equals(WorkEntryPaymentStatus.unpaid));
    });

    test('(b) Piece-only worker: 50 × ₹10 = ₹500 total', () async {
      final wId = await workerRepo.addWorker(
        name: 'Suresh Piece Worker',
        mobile: '9876543211',
        paymentType: 'piece',
        defaultNagRate: 10.0,
      );

      final entryId = await wageRepo.addWorkEntry(
        workerId: wId,
        date: DateTime.now(),
        workDescription: 'Shirt Stitching',
        nagQty: 50.0,
        nagRate: 10.0,
      );

      final entries = await wageRepo.getWorkEntriesForWorker(wId);
      expect(entries.length, equals(1));
      final entry = entries.first;

      expect(entry.id, equals(entryId));
      expect(entry.hours, isNull);
      expect(entry.hourAmount, equals(0.0));
      expect(entry.nagQty, equals(50.0));
      expect(entry.nagRate, equals(10.0));
      expect(entry.nagAmount, equals(500.0));
      expect(entry.totalAmount, equals(500.0));
      expect(entry.finalPayable, equals(500.0));
      expect(getWorkEntryStatus(entry.totalAmount, entry.advance), equals(WorkEntryPaymentStatus.unpaid));
    });

    test('(c) Both-type worker: 5h×₹100 + 30pc×₹10 = ₹800 total', () async {
      final wId = await workerRepo.addWorker(
        name: 'Mahesh Both Worker',
        mobile: '9876543212',
        paymentType: 'both',
        defaultHourRate: 100.0,
        defaultNagRate: 10.0,
      );

      final entryId = await wageRepo.addWorkEntry(
        workerId: wId,
        date: DateTime.now(),
        hours: 5.0,
        hourRate: 100.0,
        nagQty: 30.0,
        nagRate: 10.0,
      );

      final entries = await wageRepo.getWorkEntriesForWorker(wId);
      expect(entries.length, equals(1));
      final entry = entries.first;

      expect(entry.id, equals(entryId));
      expect(entry.hourAmount, equals(500.0));
      expect(entry.nagAmount, equals(300.0));
      expect(entry.totalAmount, equals(800.0));
      expect(entry.finalPayable, equals(800.0));
    });

    test('(d) Worker-specific saved rates correctly differ and persist independently for at least 2 workers', () async {
      final w1 = await workerRepo.addWorker(
        name: 'Worker Alpha',
        paymentType: 'both',
        defaultHourRate: 120.0,
        defaultNagRate: 15.0,
      );
      final w2 = await workerRepo.addWorker(
        name: 'Worker Beta',
        paymentType: 'both',
        defaultHourRate: 80.0,
        defaultNagRate: 8.0,
      );

      final worker1 = await workerRepo.getWorkerById(w1);
      final worker2 = await workerRepo.getWorkerById(w2);

      expect(worker1!.defaultHourRate, equals(120.0));
      expect(worker1.defaultNagRate, equals(15.0));

      expect(worker2!.defaultHourRate, equals(80.0));
      expect(worker2.defaultNagRate, equals(8.0));
    });

    test('(e) Daily rate override uses override value while saved default remains unchanged', () async {
      final wId = await workerRepo.addWorker(
        name: 'Worker Rate Override Test',
        paymentType: 'hour',
        defaultHourRate: 100.0,
      );

      // Entry with rate override: ₹150 instead of saved default ₹100
      await wageRepo.addWorkEntry(
        workerId: wId,
        date: DateTime.now(),
        hours: 4.0,
        hourRate: 150.0, // OVERRIDE
      );

      final entries = await wageRepo.getWorkEntriesForWorker(wId);
      final entry = entries.first;

      // Entry uses overridden rate
      expect(entry.hourRate, equals(150.0));
      expect(entry.hourAmount, equals(600.0));
      expect(entry.totalAmount, equals(600.0));

      // Worker saved default rate remains unchanged at ₹100
      final worker = await workerRepo.getWorkerById(wId);
      expect(worker!.defaultHourRate, equals(100.0));
    });

    test('(f) Advance and remaining: total 800, advance 300 -> finalPayable 500, Partial; 800 -> Paid; 0 -> Unpaid; >800 rejected', () async {
      final wId = await workerRepo.addWorker(
        name: 'Advance Test Worker',
        paymentType: 'hour',
        defaultHourRate: 100.0,
      );

      // 1. Partial advance (300 out of 800)
      await wageRepo.addWorkEntry(
        workerId: wId,
        date: DateTime.now(),
        hours: 8.0,
        hourRate: 100.0,
        advance: 300.0,
      );

      final entries1 = await wageRepo.getWorkEntriesForWorker(wId);
      final e1 = entries1.first;
      expect(e1.totalAmount, equals(800.0));
      expect(e1.advance, equals(300.0));
      expect(e1.finalPayable, equals(500.0));
      expect(getWorkEntryStatus(e1.totalAmount, e1.advance), equals(WorkEntryPaymentStatus.partial));

      // 2. Full advance (800 out of 800) -> Paid
      await wageRepo.addWorkEntry(
        workerId: wId,
        date: DateTime.now(),
        hours: 8.0,
        hourRate: 100.0,
        advance: 800.0,
      );

      final entries2 = await wageRepo.getWorkEntriesForWorker(wId);
      final e2 = entries2.first;
      expect(e2.totalAmount, equals(800.0));
      expect(e2.advance, equals(800.0));
      expect(e2.finalPayable, equals(0.0));
      expect(getWorkEntryStatus(e2.totalAmount, e2.advance), equals(WorkEntryPaymentStatus.paid));

      // 3. Zero advance -> Unpaid
      await wageRepo.addWorkEntry(
        workerId: wId,
        date: DateTime.now(),
        hours: 8.0,
        hourRate: 100.0,
        advance: 0.0,
      );

      final entries3 = await wageRepo.getWorkEntriesForWorker(wId);
      final e3 = entries3.first;
      expect(e3.advance, equals(0.0));
      expect(e3.finalPayable, equals(800.0));
      expect(getWorkEntryStatus(e3.totalAmount, e3.advance), equals(WorkEntryPaymentStatus.unpaid));

      // 4. Advance > totalAmount (e.g. 900 > 800) is rejected with ArgumentError
      expect(
        () async => await wageRepo.addWorkEntry(
          workerId: wId,
          date: DateTime.now(),
          hours: 8.0,
          hourRate: 100.0,
          advance: 900.0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('(g) Worker-wise history/totals correctly sum across multiple entries, computed live', () async {
      final wId = await workerRepo.addWorker(
        name: 'Multi Entry Summary Worker',
        paymentType: 'both',
        defaultHourRate: 100.0,
        defaultNagRate: 10.0,
      );

      // Entry 1: 5h @ ₹100 + 20pc @ ₹10 = ₹700, advance ₹200 -> payable ₹500
      await wageRepo.addWorkEntry(
        workerId: wId,
        date: DateTime.now().subtract(const Duration(days: 2)),
        hours: 5.0,
        hourRate: 100.0,
        nagQty: 20.0,
        nagRate: 10.0,
        advance: 200.0,
      );

      // Entry 2: 3h @ ₹100 + 10pc @ ₹10 = ₹400, advance ₹100 -> payable ₹300
      await wageRepo.addWorkEntry(
        workerId: wId,
        date: DateTime.now().subtract(const Duration(days: 1)),
        hours: 3.0,
        hourRate: 100.0,
        nagQty: 10.0,
        nagRate: 10.0,
        advance: 100.0,
      );

      final summary = await wageRepo.getWorkerWageSummary(wId);

      expect(summary.totalHours, equals(8.0)); // 5 + 3
      expect(summary.totalNag, equals(30.0)); // 20 + 10
      expect(summary.totalEarnings, equals(1100.0)); // 700 + 400
      expect(summary.totalAdvance, equals(300.0)); // 200 + 100
      expect(summary.remainingAmount, equals(800.0)); // 500 + 300
    });
  });
}
