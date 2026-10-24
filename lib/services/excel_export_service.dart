import 'dart:io';
import 'package:drift/drift.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

import '../core/utils/balance_utils.dart';
import '../data/db/app_database.dart';
import '../data/repositories/billing_repository.dart';

class ExcelExportService {
  final AppDatabase _db;
  final BillingRepository _billingRepo;

  ExcelExportService(this._db) : _billingRepo = BillingRepository(_db);

  CellValue? _cellText(String? str) {
    if (str == null || str.isEmpty) return null;
    return TextCellValue(str);
  }

  CellValue? _cellInt(int? val) {
    if (val == null) return null;
    return IntCellValue(val);
  }

  CellValue? _cellDouble(double? val) {
    if (val == null) return null;
    return DoubleCellValue(val);
  }

  CellValue? _cellDate(DateTime? dt) {
    if (dt == null) return null;
    return DateTimeCellValue.fromDateTime(dt);
  }

  Future<File> _createWorkbook({
    required String filename,
    required Map<String, List<String>> sheetHeaders,
    required Map<String, List<List<CellValue?>>> sheetRows,
  }) async {
    final excel = Excel.createExcel();

    bool isFirstSheet = true;
    for (final sheetName in sheetHeaders.keys) {
      if (isFirstSheet) {
        excel.rename('Sheet1', sheetName);
        isFirstSheet = false;
      }

      final sheet = excel[sheetName];
      final headers = sheetHeaders[sheetName]!;
      final rows = sheetRows[sheetName] ?? [];

      // Header Row (Row 0)
      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
        cell.value = TextCellValue(headers[col]);
        cell.cellStyle = CellStyle(bold: true);
      }

      // Data Rows (Row 1+)
      for (int row = 0; row < rows.length; row++) {
        final rowData = rows[row];
        for (int col = 0; col < rowData.length; col++) {
          final val = rowData[col];
          if (val != null) {
            final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1));
            cell.value = val;
          }
        }
      }
    }

    final bytes = excel.save();
    if (bytes == null) {
      throw Exception('Failed to generate Excel file $filename');
    }

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// 1. Export Customers (Customers.xlsx)
  Future<File> exportCustomers() async {
    final query = _db.select(_db.customers)
      ..orderBy([(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)]);
    final customers = await query.get();

    final headers = [
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

    final rows = <List<CellValue?>>[];
    for (final c in customers) {
      final outstanding = await _billingRepo.getCustomerLedgerSummary(c.id);
      rows.add([
        _cellInt(c.id),
        _cellText(c.name),
        _cellText(c.mobile),
        _cellText(c.address),
        _cellText(c.gstInfo),
        _cellDouble(c.openingBalance),
        _cellDouble(outstanding),
        _cellText(c.notes),
        _cellText(c.isActive ? 'Active' : 'Inactive'),
        _cellDate(c.createdAt),
      ]);
    }

    return _createWorkbook(
      filename: 'Customers.xlsx',
      sheetHeaders: {'Customers': headers},
      sheetRows: {'Customers': rows},
    );
  }

  /// 2. Export Items (Items.xlsx)
  // Note: Consolidates Materials.xlsx/Products.xlsx/Stock.xlsx into one file,
  // since our schema unifies raw materials and finished products into one items table with current stock already included.
  Future<File> exportItems() async {
    final query = _db.select(_db.items)
      ..orderBy([(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)]);
    final items = await query.get();

    final headers = [
      'ID',
      'Type',
      'Name',
      'Category',
      'Unit',
      'Purchase Rate (₹)',
      'Selling Rate (₹)',
      'Wholesale Rate (₹)',
      'Opening Qty',
      'Current Qty',
      'Minimum Stock Level',
      'Supplier Info',
      'Status',
      'Created At',
    ];

    final rows = <List<CellValue?>>[];
    for (final i in items) {
      final typeLabel = i.type == 'raw_material' ? 'Raw Material' : 'Finished Product';
      rows.add([
        _cellInt(i.id),
        _cellText(typeLabel),
        _cellText(i.name),
        _cellText(i.category),
        _cellText(i.unit),
        _cellDouble(i.purchaseRate),
        _cellDouble(i.sellingRate),
        _cellDouble(i.wholesaleRate),
        _cellDouble(i.openingQty),
        _cellDouble(i.currentQty),
        _cellDouble(i.minStockLevel),
        _cellText(i.supplierInfo),
        _cellText(i.isActive ? 'Active' : 'Inactive'),
        _cellDate(i.createdAt),
      ]);
    }

    return _createWorkbook(
      filename: 'Items.xlsx',
      sheetHeaders: {'Items': headers},
      sheetRows: {'Items': rows},
    );
  }

  /// 3. Export Stock Transactions (Stock_Transactions.xlsx)
  Future<File> exportStockTransactions() async {
    final query = _db.select(_db.stockTransactions).join([
      innerJoin(_db.items, _db.items.id.equalsExp(_db.stockTransactions.itemId)),
    ])..orderBy([
        OrderingTerm(expression: _db.stockTransactions.date, mode: OrderingMode.desc),
        OrderingTerm(expression: _db.stockTransactions.id, mode: OrderingMode.desc),
      ]);

    final result = await query.get();

    final headers = [
      'ID',
      'Date',
      'Item Name',
      'Item Type',
      'Transaction Type',
      'Quantity (+/-)',
      'Unit Rate (₹)',
      'Reference Type',
      'Reference ID',
      'Notes',
      'Created At',
    ];

    final rows = <List<CellValue?>>[];
    for (final r in result) {
      final tx = r.readTable(_db.stockTransactions);
      final item = r.readTable(_db.items);
      final typeLabel = item.type == 'raw_material' ? 'Raw Material' : 'Finished Product';

      rows.add([
        _cellInt(tx.id),
        _cellDate(tx.date),
        _cellText(item.name),
        _cellText(typeLabel),
        _cellText(tx.type),
        _cellDouble(tx.quantity),
        _cellDouble(tx.unitRate),
        _cellText(tx.referenceType),
        _cellText(tx.referenceId?.toString()),
        _cellText(tx.notes),
        _cellDate(tx.createdAt),
      ]);
    }

    return _createWorkbook(
      filename: 'Stock_Transactions.xlsx',
      sheetHeaders: {'Stock Transactions': headers},
      sheetRows: {'Stock Transactions': rows},
    );
  }

  /// 4. Export Workers (Workers.xlsx)
  Future<File> exportWorkers() async {
    final query = _db.select(_db.workers)
      ..orderBy([(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)]);
    final workers = await query.get();

    final headers = [
      'ID',
      'Name',
      'Mobile',
      'Address',
      'Work Type',
      'Status',
      'Notes',
      'Created At',
    ];

    final rows = <List<CellValue?>>[];
    for (final w in workers) {
      rows.add([
        _cellInt(w.id),
        _cellText(w.name),
        _cellText(w.mobile),
        _cellText(w.address),
        _cellText(w.workType),
        _cellText(w.isActive ? 'Active' : 'Inactive'),
        _cellText(w.notes),
        _cellDate(w.createdAt),
      ]);
    }

    return _createWorkbook(
      filename: 'Workers.xlsx',
      sheetHeaders: {'Workers': headers},
      sheetRows: {'Workers': rows},
    );
  }

  /// 5. Export Worker Transactions (Worker_Transactions.xlsx)
  Future<File> exportWorkerTransactions() async {
    final query = _db.select(_db.workerTransactions).join([
      innerJoin(_db.workers, _db.workers.id.equalsExp(_db.workerTransactions.workerId)),
      innerJoin(_db.items, _db.items.id.equalsExp(_db.workerTransactions.itemId)),
    ])..orderBy([
        OrderingTerm(expression: _db.workerTransactions.date, mode: OrderingMode.desc),
        OrderingTerm(expression: _db.workerTransactions.id, mode: OrderingMode.desc),
      ]);

    final result = await query.get();

    final headers = [
      'ID',
      'Worker Name',
      'Item Name',
      'Quantity Issued',
      'Date',
      'Status',
      'Notes',
      'Created At',
    ];

    final rows = <List<CellValue?>>[];
    for (final r in result) {
      final tx = r.readTable(_db.workerTransactions);
      final worker = r.readTable(_db.workers);
      final item = r.readTable(_db.items);

      rows.add([
        _cellInt(tx.id),
        _cellText(worker.name),
        _cellText(item.name),
        _cellDouble(tx.quantityIssued),
        _cellDate(tx.date),
        _cellText(tx.status),
        _cellText(tx.notes),
        _cellDate(tx.createdAt),
      ]);
    }

    return _createWorkbook(
      filename: 'Worker_Transactions.xlsx',
      sheetHeaders: {'Worker Transactions': headers},
      sheetRows: {'Worker Transactions': rows},
    );
  }

  /// 6. Export Production (Production.xlsx with 2 sheets)
  Future<File> exportProduction() async {
    // Sheet 1: Production Records
    final recQuery = _db.select(_db.productionRecords).join([
      innerJoin(_db.workers, _db.workers.id.equalsExp(_db.productionRecords.workerId)),
      innerJoin(_db.items, _db.items.id.equalsExp(_db.productionRecords.outputItemId)),
    ])..orderBy([
        OrderingTerm(expression: _db.productionRecords.id, mode: OrderingMode.desc),
      ]);

    final recResult = await recQuery.get();

    final recHeaders = [
      'ID',
      'Worker Name',
      'Date',
      'Batch Ref',
      'Output Item Name',
      'Output Qty',
      'Notes',
      'Created At',
    ];

    final recRows = <List<CellValue?>>[];
    for (final r in recResult) {
      final rec = r.readTable(_db.productionRecords);
      final worker = r.readTable(_db.workers);
      final outputItem = r.readTable(_db.items);

      recRows.add([
        _cellInt(rec.id),
        _cellText(worker.name),
        _cellDate(rec.date),
        _cellText(rec.batchRef),
        _cellText(outputItem.name),
        _cellDouble(rec.outputQty),
        _cellText(rec.notes),
        _cellDate(rec.createdAt),
      ]);
    }

    // Sheet 2: Production Inputs
    final inpQuery = _db.select(_db.productionInputs).join([
      innerJoin(_db.items, _db.items.id.equalsExp(_db.productionInputs.itemId)),
    ])..orderBy([
        OrderingTerm(expression: _db.productionInputs.productionRecordId, mode: OrderingMode.desc),
      ]);

    final inpResult = await inpQuery.get();

    final inpHeaders = [
      'Production Record ID',
      'Item Name',
      'Quantity Used',
      'Quantity Returned',
    ];

    final inpRows = <List<CellValue?>>[];
    for (final r in inpResult) {
      final inp = r.readTable(_db.productionInputs);
      final item = r.readTable(_db.items);

      inpRows.add([
        _cellInt(inp.productionRecordId),
        _cellText(item.name),
        _cellDouble(inp.quantityUsed),
        _cellDouble(inp.quantityReturned),
      ]);
    }

    return _createWorkbook(
      filename: 'Production.xlsx',
      sheetHeaders: {
        'Production Records': recHeaders,
        'Production Inputs': inpHeaders,
      },
      sheetRows: {
        'Production Records': recRows,
        'Production Inputs': inpRows,
      },
    );
  }

  /// 7. Export Bills (Bills.xlsx)
  Future<File> exportBills() async {
    final query = _db.select(_db.bills).join([
      leftOuterJoin(_db.customers, _db.customers.id.equalsExp(_db.bills.customerId)),
    ])..orderBy([
        OrderingTerm(expression: _db.bills.id, mode: OrderingMode.desc),
      ]);

    final result = await query.get();

    final headers = [
      'Bill Number',
      'Customer Name',
      'Bill Date',
      'Subtotal (₹)',
      'Discount (₹)',
      'Other Charges (₹)',
      'Grand Total (₹)',
      'Amount Paid (₹)',
      'Remaining Balance (₹)',
      'Previous Balance (+Due / −Advance)',
      'Current Balance (+Due / −Advance)',
      'Status',
      'Void Reason',
      'Void Date',
      'Notes',
      'Created At',
    ];

    final rows = <List<CellValue?>>[];
    for (final r in result) {
      final b = r.readTable(_db.bills);
      final c = r.readTableOrNull(_db.customers);
      final balances = resolveBillBalancesFromEntity(b);

      rows.add([
        _cellText(b.billNumber),
        _cellText(c?.name ?? 'Walk-in Customer'),
        _cellDate(b.billDate),
        _cellDouble(b.subtotal),
        _cellDouble(b.discount),
        _cellDouble(b.otherCharges),
        _cellDouble(b.grandTotal),
        _cellDouble(b.amountPaid),
        _cellDouble(b.remainingBalance),
        _cellDouble(balances.previous),
        _cellDouble(balances.current),
        _cellText(b.status == 'void' ? 'Void' : 'Active'),
        _cellText(b.voidReason),
        _cellDate(b.voidedAt),
        _cellText(b.notes),
        _cellDate(b.createdAt),
      ]);
    }

    return _createWorkbook(
      filename: 'Bills.xlsx',
      sheetHeaders: {'Bills': headers},
      sheetRows: {'Bills': rows},
    );
  }

  /// 8. Export Bill Items (Bill_Items.xlsx)
  Future<File> exportBillItems() async {
    final query = _db.select(_db.billItems).join([
      innerJoin(_db.bills, _db.bills.id.equalsExp(_db.billItems.billId)),
      leftOuterJoin(_db.items, _db.items.id.equalsExp(_db.billItems.itemId)),
      leftOuterJoin(_db.sellingProducts, _db.sellingProducts.id.equalsExp(_db.billItems.sellingProductId)),
    ])..orderBy([
        OrderingTerm(expression: _db.billItems.billId, mode: OrderingMode.desc),
      ]);

    final result = await query.get();

    final headers = [
      'Bill Number',
      'Item Name',
      'Line Source',
      'Quantity',
      'Unit',
      'Rate (₹)',
      'Amount (₹)',
    ];

    final rows = <List<CellValue?>>[];
    for (final r in result) {
      final bi = r.readTable(_db.billItems);
      final b = r.readTable(_db.bills);
      final item = r.readTableOrNull(_db.items);
      final prod = r.readTableOrNull(_db.sellingProducts);
      final itemName = bi.productName ?? item?.name ?? prod?.name ?? 'Item';
      final lineSource = bi.itemId != null ? 'Stock' : 'Own Product';

      rows.add([
        _cellText(b.billNumber),
        _cellText(itemName),
        _cellText(lineSource),
        _cellDouble(bi.quantity),
        _cellText(bi.unit),
        _cellDouble(bi.rate),
        _cellDouble(bi.amount),
      ]);
    }

    return _createWorkbook(
      filename: 'Bill_Items.xlsx',
      sheetHeaders: {'Bill Items': headers},
      sheetRows: {'Bill Items': rows},
    );
  }

  /// Export Selling Products (Selling_Products.xlsx)
  Future<File> exportSellingProducts() async {
    final query = _db.select(_db.sellingProducts)
      ..orderBy([(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)]);
    final products = await query.get();

    final headers = [
      'ID',
      'Name',
      'Retail Price (₹)',
      'Wholesale Price (₹)',
      'Description',
      'Status',
      'Created At',
    ];

    final rows = <List<CellValue?>>[];
    for (final p in products) {
      rows.add([
        _cellInt(p.id),
        _cellText(p.name),
        _cellDouble(p.price),
        _cellDouble(p.wholesalePrice),
        _cellText(p.description),
        _cellText(p.isActive ? 'Active' : 'Inactive'),
        _cellDate(p.createdAt),
      ]);
    }

    return _createWorkbook(
      filename: 'Selling_Products.xlsx',
      sheetHeaders: {'Selling Products': headers},
      sheetRows: {'Selling Products': rows},
    );
  }

  /// 9. Export Payments (Payments.xlsx)
  Future<File> exportPayments() async {
    final query = _db.select(_db.payments).join([
      innerJoin(_db.customers, _db.customers.id.equalsExp(_db.payments.customerId)),
      leftOuterJoin(_db.bills, _db.bills.id.equalsExp(_db.payments.billId)),
    ])..orderBy([
        OrderingTerm(expression: _db.payments.date, mode: OrderingMode.desc),
        OrderingTerm(expression: _db.payments.id, mode: OrderingMode.desc),
      ]);

    final result = await query.get();

    final headers = [
      'Date',
      'Customer Name',
      'Bill Number',
      'Amount (₹)',
      'Method',
      'Notes',
    ];

    final rows = <List<CellValue?>>[];
    for (final r in result) {
      final p = r.readTable(_db.payments);
      final c = r.readTable(_db.customers);
      final b = r.readTableOrNull(_db.bills);

      rows.add([
        _cellDate(p.date),
        _cellText(c.name),
        _cellText(b?.billNumber ?? ''),
        _cellDouble(p.amount),
        _cellText(p.method),
        _cellText(p.notes),
      ]);
    }

    return _createWorkbook(
      filename: 'Payments.xlsx',
      sheetHeaders: {'Payments': headers},
      sheetRows: {'Payments': rows},
    );
  }

  /// 10. Export Customer Ledger (Customer_Ledger.xlsx)
  Future<File> exportCustomerLedger() async {
    final query = _db.select(_db.ledgerEntries).join([
      innerJoin(_db.customers, _db.customers.id.equalsExp(_db.ledgerEntries.customerId)),
    ])..orderBy([
        OrderingTerm(expression: _db.customers.name, mode: OrderingMode.asc),
        OrderingTerm(expression: _db.ledgerEntries.date, mode: OrderingMode.asc),
        OrderingTerm(expression: _db.ledgerEntries.id, mode: OrderingMode.asc),
      ]);

    final result = await query.get();

    final headers = [
      'Customer Name',
      'Date',
      'Type',
      'Reference',
      'Debit (₹)',
      'Credit (₹)',
      'Running Balance (₹)',
    ];

    final rows = <List<CellValue?>>[];
    for (final r in result) {
      final le = r.readTable(_db.ledgerEntries);
      final c = r.readTable(_db.customers);
      final refStr = le.referenceId != null ? 'Ref #${le.referenceId}' : '-';

      rows.add([
        _cellText(c.name),
        _cellDate(le.date),
        _cellText(le.type),
        _cellText(refStr),
        _cellDouble(le.debit),
        _cellDouble(le.credit),
        _cellDouble(le.runningBalance),
      ]);
    }

    return _createWorkbook(
      filename: 'Customer_Ledger.xlsx',
      sheetHeaders: {'Customer Ledger': headers},
      sheetRows: {'Customer Ledger': rows},
    );
  }

  /// Export all 10 business datasets into separate Excel files.
  Future<List<File>> exportAll() async {
    final files = <File>[];
    files.add(await exportCustomers());
    files.add(await exportItems());
    files.add(await exportStockTransactions());
    files.add(await exportWorkers());
    files.add(await exportWorkerTransactions());
    files.add(await exportProduction());
    files.add(await exportBills());
    files.add(await exportBillItems());
    files.add(await exportSellingProducts());
    files.add(await exportPayments());
    files.add(await exportCustomerLedger());
    return files;
  }
}
