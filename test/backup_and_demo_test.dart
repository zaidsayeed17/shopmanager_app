import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopmanager/data/db/app_database.dart';
import 'package:shopmanager/data/repositories/customer_repository.dart';
import 'package:shopmanager/services/backup_service.dart';
import 'package:shopmanager/services/demo_data_service.dart';

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
  late DemoDataService demoDataService;
  late BackupService backupService;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    customerRepo = CustomerRepository(db);
    demoDataService = DemoDataService(db);
    backupService = BackupService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Demo Data Cleanup Tests', () {
    test('seedInitialCustomersIfEmpty does not insert demo customers on fresh install', () async {
      await customerRepo.seedInitialCustomersIfEmpty();

      final hasDemoBefore = await demoDataService.hasDemoDataToClean();
      expect(hasDemoBefore, isFalse);

      final allCustomersBefore = await customerRepo.watchAllCustomers().first;
      expect(allCustomersBefore.isEmpty, isTrue);
    });
  });

  group('Backup Validation Tests', () {
    test('validateBackupFile correctly identifies real backup as valid and corrupt file as invalid', () async {
      // Create real backup using file-based DB setup or SQLite snapshot
      final tempDir = Directory.systemTemp;
      final realBackupFile = File('${tempDir.path}/test_backup_${DateTime.now().millisecondsSinceEpoch}.db');
      
      // Seed some data in memory database
      await customerRepo.addCustomer(name: 'Test Customer', mobile: '9999999999');

      // Vacuum into file
      final safePath = realBackupFile.path.replaceAll('\\', '/');
      await db.customStatement("VACUUM INTO '$safePath'");

      // Validate real backup
      final validResult = await backupService.validateBackupFile(realBackupFile);
      expect(validResult.isValid, isTrue);
      expect(validResult.schemaVersion, equals(db.schemaVersion));
      expect(validResult.errorMessage, isNull);

      // Clean up real backup file
      if (await realBackupFile.exists()) {
        await realBackupFile.delete();
      }

      // Create a corrupt/fake file
      final corruptFile = File('${tempDir.path}/corrupt_file_${DateTime.now().millisecondsSinceEpoch}.txt');
      await corruptFile.writeAsString('This is not a SQLite database file.');

      // Validate corrupt file
      final invalidResult = await backupService.validateBackupFile(corruptFile);
      expect(invalidResult.isValid, isFalse);
      expect(invalidResult.errorMessage, isNotNull);
      expect(invalidResult.errorMessage, contains('could not be read'));

      // Clean up corrupt file
      if (await corruptFile.exists()) {
        await corruptFile.delete();
      }
    });
  });
}
