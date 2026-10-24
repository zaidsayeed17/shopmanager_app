import 'dart:io';
import 'package:drift/native.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shopmanager/data/db/app_database.dart';
import 'package:shopmanager/data/models/bill_model.dart';
import 'package:shopmanager/data/repositories/billing_repository.dart';
import 'package:shopmanager/data/repositories/customer_repository.dart';
import 'package:shopmanager/data/repositories/item_repository.dart';
import 'package:shopmanager/services/excel_export_service.dart';

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
  late BillingRepository billingRepo;
  late ExcelExportService exportService;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    customerRepo = CustomerRepository(db);
    itemRepo = ItemRepository(db);
    billingRepo = BillingRepository(db);
    exportService = ExcelExportService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('ExcelExportService Tests', () {
    test('exportCustomers produces valid Excel file with matching headers, row count, and current outstanding', () async {
      // Seed 2 customers
      final cust1Id = await customerRepo.addCustomer(
        name: 'Alpha Traders',
        mobile: '9876543210',
        address: '123 Main St',
        gstin: '27AAAAA0000A1Z5',
        openingBalance: 1500.0,
        notes: 'Regular buyer',
      );

      final cust2Id = await customerRepo.addCustomer(
        name: 'Beta Enterprises',
        mobile: '9123456789',
        openingBalance: 0.0,
      );

      // Seed an item and bill for Customer 1
      final itemId = await itemRepo.addItem(
        name: 'Steel Bar 10mm',
        type: 'finished_product',
        unit: 'pcs',
        openingQty: 50,
        sellingRate: 200.0,
      );

      await billingRepo.saveBill(
        customerId: cust1Id,
        billDate: DateTime(2026, 9, 29),
        lines: [BillLine(itemId: itemId, quantity: 5, rate: 200.0)],
        amountReceived: 500.0,
      );

      // Compute expected ledger summary values
      final expectedOutstanding1 = await billingRepo.getCustomerLedgerSummary(cust1Id);
      final expectedOutstanding2 = await billingRepo.getCustomerLedgerSummary(cust2Id);

      // Export Customers.xlsx
      final file = await exportService.exportCustomers();
      expect(file.existsSync(), isTrue);

      final bytes = file.readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);
      expect(excel.tables.containsKey('Customers'), isTrue);

      final sheet = excel['Customers'];
      expect(sheet.maxRows, equals(3)); // 1 header row + 2 data rows

      // Verify header row
      final expectedHeaders = [
        'ID',
        'Name',
        'Mobile',
        'Address',
        'GST Info',
        'Opening Balance (₹)',
        'Current Outstanding (₹)',
        'Notes',
        'Status',
        'Created At',
      ];

      final headerRow = sheet.row(0).map((cell) => cell?.value?.toString()).toList();
      for (int i = 0; i < expectedHeaders.length; i++) {
        expect(headerRow[i], equals(expectedHeaders[i]));
      }

      // Verify Customer 1 data (Row 1)
      final row1 = sheet.row(1);
      expect(row1[1]?.value?.toString(), equals('Alpha Traders'));
      final outstandingCell1 = (row1[6]?.value as dynamic)?.value;
      expect((outstandingCell1 as num).toDouble(), equals(expectedOutstanding1));

      // Verify Customer 2 data (Row 2)
      final row2 = sheet.row(2);
      expect(row2[1]?.value?.toString(), equals('Beta Enterprises'));
      final outstandingCell2 = (row2[6]?.value as dynamic)?.value;
      expect((outstandingCell2 as num).toDouble(), equals(expectedOutstanding2));
    });

    test('Empty table handling: exportWorkers on empty DB produces valid Excel file with headers and 0 data rows', () async {
      final file = await exportService.exportWorkers();
      expect(file.existsSync(), isTrue);

      final bytes = file.readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);
      expect(excel.tables.containsKey('Workers'), isTrue);

      final sheet = excel['Workers'];
      expect(sheet.maxRows, equals(1)); // Header row only

      final headerRow = sheet.row(0).map((cell) => cell?.value?.toString()).toList();
      expect(headerRow[0], equals('ID'));
      expect(headerRow[1], equals('Name'));
    });

    test('exportAll produces all 11 Excel files cleanly', () async {
      final files = await exportService.exportAll();
      expect(files.length, equals(11));

      final filenames = files.map((f) => p.basename(f.path)).toList();
      expect(filenames, containsAll([
        'Customers.xlsx',
        'Items.xlsx',
        'Stock_Transactions.xlsx',
        'Workers.xlsx',
        'Worker_Transactions.xlsx',
        'Production.xlsx',
        'Bills.xlsx',
        'Bill_Items.xlsx',
        'Selling_Products.xlsx',
        'Payments.xlsx',
        'Customer_Ledger.xlsx',
      ]));

      for (final f in files) {
        expect(f.existsSync(), isTrue);
        expect(f.lengthSync(), greaterThan(0));
      }
    });

    test('exportProduction produces 2 sheets in one workbook', () async {
      final file = await exportService.exportProduction();
      expect(file.existsSync(), isTrue);

      final bytes = file.readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);
      expect(excel.tables.containsKey('Production Records'), isTrue);
      expect(excel.tables.containsKey('Production Inputs'), isTrue);
    });
  });
}
