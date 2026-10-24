import 'package:drift/drift.dart';
import '../db/app_database.dart';
import '../models/bill_model.dart' hide BillStatus;
import '../../features/customers/customers_placeholder_data.dart';

class BillDetailData {
  final BillModel bill;
  final CustomerEntity customer;
  final List<BillItemDetail> items;
  final List<PaymentEntity> payments;

  const BillDetailData({
    required this.bill,
    required this.customer,
    required this.items,
    required this.payments,
  });
}

class TodaysSalesSummary {
  final double totalAmount;
  final int billCount;

  const TodaysSalesSummary({
    required this.totalAmount,
    required this.billCount,
  });
}

class TodaysPaymentsSummary {
  final double totalAmount;
  final double cashAmount;
  final double upiAmount;
  final double otherAmount;

  const TodaysPaymentsSummary({
    required this.totalAmount,
    required this.cashAmount,
    required this.upiAmount,
    required this.otherAmount,
  });
}

class TotalOutstandingSummary {
  final double totalOutstanding;
  final int customersWithBalanceCount;

  const TotalOutstandingSummary({
    required this.totalOutstanding,
    required this.customersWithBalanceCount,
  });
}

class DailySalesPoint {
  final DateTime date;
  final double totalSales;
  final int billCount;

  const DailySalesPoint({
    required this.date,
    required this.totalSales,
    required this.billCount,
  });
}

class DailySalesReportData {
  final List<DailySalesPoint> points;
  final double totalSales;
  final int totalBills;
  final double averageBillValue;

  const DailySalesReportData({
    required this.points,
    required this.totalSales,
    required this.totalBills,
    required this.averageBillValue,
  });
}

class MonthlySalesPoint {
  final int year;
  final int month;
  final double totalSales;
  final int billCount;

  const MonthlySalesPoint({
    required this.year,
    required this.month,
    required this.totalSales,
    required this.billCount,
  });

  String get monthLabel {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[month - 1]} $year';
  }
}

class MonthlySalesReportData {
  final List<MonthlySalesPoint> points;
  final double totalSales;
  final int totalBills;
  final double averageBillValue;

  const MonthlySalesReportData({
    required this.points,
    required this.totalSales,
    required this.totalBills,
    required this.averageBillValue,
  });
}

class CustomerOutstandingItem {
  final int id;
  final String name;
  final String mobile;
  final double outstanding;
  final DateTime? lastBilledDate;

  const CustomerOutstandingItem({
    required this.id,
    required this.name,
    required this.mobile,
    required this.outstanding,
    this.lastBilledDate,
  });
}

class CustomerOutstandingReportData {
  final List<CustomerOutstandingItem> items;
  final double totalOutstanding;
  final int customerCount;

  const CustomerOutstandingReportData({
    required this.items,
    required this.totalOutstanding,
    required this.customerCount,
  });
}

class BillingRepository {
  final AppDatabase _db;

  BillingRepository(this._db);

  double _round2(double val) {
    return (val * 100).roundToDouble() / 100.0;
  }

  double _round3(double val) {
    return (val * 1000).roundToDouble() / 1000.0;
  }

  /// Get next bill number preview string (e.g. 'INV-0001')
  Future<String> getNextBillNumber() async {
    final query = _db.select(_db.settingsTable)..where((t) => t.key.equals('next_bill_number'));
    final setting = await query.getSingleOrNull();
    int num = 1;
    if (setting?.value != null && setting!.value!.isNotEmpty) {
      num = int.tryParse(setting.value!) ?? 1;
    }
    return 'INV-${num.toString().padLeft(4, '0')}';
  }

  /// Fetch customer's current running balance prior to a new bill.
  /// Sum(debit) - sum(credit) from ledgerEntries if exists; otherwise customer.openingBalance.
  Future<double> getCustomerLedgerSummary(int customerId) async {
    final ledgerQuery = _db.select(_db.ledgerEntries)
      ..where((t) => t.customerId.equals(customerId));
    final ledgerRows = await ledgerQuery.get();

    if (ledgerRows.isNotEmpty) {
      final sumDebit = ledgerRows.fold<double>(0.0, (s, e) => s + e.debit);
      final sumCredit = ledgerRows.fold<double>(0.0, (s, e) => s + e.credit);
      return _round2(sumDebit - sumCredit);
    } else {
      final custQuery = _db.select(_db.customers)..where((t) => t.id.equals(customerId));
      final customer = await custQuery.getSingleOrNull();
      return _round2(customer?.openingBalance ?? 0.0);
    }
  }

  /// Fetch customer's current advance/credit balance held (max(0, -runningBalance)).
  Future<double> getCustomerAdvanceBalance(int customerId) async {
    final runningBal = await getCustomerLedgerSummary(customerId);
    return _round2(runningBal < 0 ? -runningBal : 0.0);
  }

  /// Fetch all bills ordered by ID desc joined with customer name
  Future<List<BillModel>> getAllBills() async {
    final query = _db.select(_db.bills).join([
      leftOuterJoin(_db.customers, _db.customers.id.equalsExp(_db.bills.customerId)),
    ])..orderBy([
        OrderingTerm(expression: _db.bills.id, mode: OrderingMode.desc),
      ]);

    final rows = await query.get();
    return rows.map((row) {
      final bill = row.readTable(_db.bills);
      final customer = row.readTableOrNull(_db.customers);
      return BillModel.fromEntity(bill, customerName: customer?.name);
    }).toList();
  }

  /// Watch all bills in real time
  Stream<List<BillModel>> watchAllBills() {
    final query = _db.select(_db.bills).join([
      leftOuterJoin(_db.customers, _db.customers.id.equalsExp(_db.bills.customerId)),
    ])..orderBy([
        OrderingTerm(expression: _db.bills.id, mode: OrderingMode.desc),
      ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final bill = row.readTable(_db.bills);
        final customer = row.readTableOrNull(_db.customers);
        return BillModel.fromEntity(bill, customerName: customer?.name);
      }).toList();
    });
  }

  /// Search bills by bill number or customer name
  Future<List<BillModel>> searchBills(String queryText) async {
    if (queryText.trim().isEmpty) {
      return getAllBills();
    }
    final pattern = '%${queryText.trim().toLowerCase()}%';
    var whereClause = _db.bills.billNumber.lower().like(pattern) | _db.customers.name.lower().like(pattern);
    if ('walk-in customer'.contains(queryText.trim().toLowerCase()) || 'walk-in'.contains(queryText.trim().toLowerCase())) {
      whereClause = whereClause | _db.bills.customerId.isNull();
    }

    final query = _db.select(_db.bills).join([
      leftOuterJoin(_db.customers, _db.customers.id.equalsExp(_db.bills.customerId)),
    ])
      ..where(whereClause)
      ..orderBy([
        OrderingTerm(expression: _db.bills.id, mode: OrderingMode.desc),
      ]);

    final rows = await query.get();
    return rows.map((row) {
      final bill = row.readTable(_db.bills);
      final customer = row.readTableOrNull(_db.customers);
      return BillModel.fromEntity(bill, customerName: customer?.name);
    }).toList();
  }

  /// Get single bill by ID with items
  Future<BillModel?> getBillById(int id) async {
    final query = _db.select(_db.bills).join([
      leftOuterJoin(_db.customers, _db.customers.id.equalsExp(_db.bills.customerId)),
    ])..where(_db.bills.id.equals(id));

    final row = await query.getSingleOrNull();
    if (row == null) return null;

    final billEntity = row.readTable(_db.bills);
    final customerEntity = row.readTableOrNull(_db.customers);

    final itemsQuery = _db.select(_db.billItems).join([
      leftOuterJoin(_db.items, _db.items.id.equalsExp(_db.billItems.itemId)),
      leftOuterJoin(_db.sellingProducts, _db.sellingProducts.id.equalsExp(_db.billItems.sellingProductId)),
    ])..where(_db.billItems.billId.equals(id));

    final itemRows = await itemsQuery.get();
    final itemDetails = itemRows.map((r) {
      final bItem = r.readTable(_db.billItems);
      final item = r.readTableOrNull(_db.items);
      final prod = r.readTableOrNull(_db.sellingProducts);
      final itemName = bItem.productName ?? item?.name ?? prod?.name ?? 'Unknown Item';
      return BillItemDetail.fromEntity(bItem, itemName);
    }).toList();

    return BillModel.fromEntity(
      billEntity,
      customerName: customerEntity?.name,
      items: itemDetails,
    );
  }

  /// Atomically save a new bill (invoice or quick sale) and associated entries
  Future<String> saveBill({
    int? customerId,
    String saleChannel = 'invoice',
    required DateTime billDate,
    required List<BillLine> lines,
    double discount = 0.0,
    double otherCharges = 0.0,
    bool gstEnabled = false,
    double? gstPercent,
    double advanceToApply = 0.0,
    double amountReceived = 0.0,
    String? paymentMethod,
    String? notes,
  }) async {
    if (lines.isEmpty) {
      throw ArgumentError('Bill must contain at least one item line.');
    }
    for (final line in lines) {
      if ((line.itemId == null && line.sellingProductId == null) ||
          (line.itemId != null && line.sellingProductId != null)) {
        throw ArgumentError('Each bill line must reference exactly one product source (Stock Item or Own Product).');
      }
      if (line.quantity <= 0) {
        throw ArgumentError('Item quantity must be greater than zero.');
      }
      if (line.rate < 0) {
        throw ArgumentError('Item rate cannot be negative.');
      }
    }
    if (discount < 0) {
      throw ArgumentError('Discount cannot be negative.');
    }
    if (otherCharges < 0) {
      throw ArgumentError('Other charges cannot be negative.');
    }
    if (gstEnabled) {
      if (gstPercent == null || gstPercent <= 0 || gstPercent > 100) {
        throw ArgumentError(
          'GST percentage must be greater than 0 and less than or equal to 100 when GST is enabled.',
        );
      }
    }
    if (advanceToApply < 0) {
      throw ArgumentError('Advance to apply cannot be negative.');
    }
    if (amountReceived < 0) {
      throw ArgumentError('Amount received cannot be negative.');
    }

    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    if (billDate.isAfter(todayEnd)) {
      throw ArgumentError('Bill date cannot be in the future.');
    }

    CustomerEntity? customerEntity;
    if (customerId != null) {
      final custQuery = _db.select(_db.customers)..where((t) => t.id.equals(customerId));
      customerEntity = await custQuery.getSingleOrNull();
      if (customerEntity == null) {
        throw ArgumentError('Customer #$customerId does not exist.');
      }
    }

    // Pre-calculate subtotal, taxable amount, gst amount, and grandTotal for validation
    double subtotalCalc = 0.0;
    for (final line in lines) {
      subtotalCalc += _round2(line.quantity * line.rate);
    }
    subtotalCalc = _round2(subtotalCalc);
    final taxableAmountCalc = _round2(subtotalCalc - discount + otherCharges);
    final gstAmountCalc = gstEnabled
        ? _round2(taxableAmountCalc * gstPercent! / 100)
        : 0.0;
    final grandTotalCalc = _round2(taxableAmountCalc + gstAmountCalc);

    if (customerId != null && advanceToApply > 0) {
      final availableAdvance = await getCustomerAdvanceBalance(customerId);
      if (advanceToApply > availableAdvance + 0.001) {
        throw ArgumentError(
          'Advance to apply (₹${advanceToApply.toStringAsFixed(2)}) cannot exceed available advance balance (₹${availableAdvance.toStringAsFixed(2)}).',
        );
      }
      if (advanceToApply > grandTotalCalc + 0.001) {
        throw ArgumentError(
          'Advance to apply (₹${advanceToApply.toStringAsFixed(2)}) cannot exceed bill grand total (₹${grandTotalCalc.toStringAsFixed(2)}).',
        );
      }
    }

    final effectiveAdvanceToApply = customerId != null ? advanceToApply : 0.0;
    final netPayableAfterAdvance = _round2(grandTotalCalc - effectiveAdvanceToApply);
    if (customerId != null && amountReceived > netPayableAfterAdvance + 0.001) {
      throw ArgumentError(
        'Amount received (₹${amountReceived.toStringAsFixed(2)}) cannot exceed remaining total after advance (₹${netPayableAfterAdvance.toStringAsFixed(2)}).',
      );
    }

    return await _db.transaction(() async {
      final createdAt = DateTime.now();

      // 1. Generate Bill Number inside transaction based on saleChannel
      final String settingKey = saleChannel == 'quick_sale' ? 'next_quick_sale_number' : 'next_bill_number';
      final String prefix = saleChannel == 'quick_sale' ? 'QS-' : 'INV-';

      final settingQuery = _db.select(_db.settingsTable)
        ..where((t) => t.key.equals(settingKey));
      final setting = await settingQuery.getSingleOrNull();
      int nextNum = 1;
      if (setting?.value != null && setting!.value!.isNotEmpty) {
        nextNum = int.tryParse(setting.value!) ?? 1;
      }

      final billNumber = '$prefix${nextNum.toString().padLeft(4, '0')}';

      // Update counter setting
      await _db.into(_db.settingsTable).insertOnConflictUpdate(
        SettingsTableCompanion.insert(
          key: settingKey,
          value: Value((nextNum + 1).toString()),
        ),
      );

      final subtotal = subtotalCalc;
      final grandTotal = grandTotalCalc;

      final double totalPaidAndApplied;
      final double remainingBalance;

      if (customerId == null) {
        // Walk-in sales are forced fully paid
        totalPaidAndApplied = grandTotal;
        remainingBalance = 0.0;
      } else {
        totalPaidAndApplied = _round2(effectiveAdvanceToApply + amountReceived);
        remainingBalance = _round2(grandTotal - totalPaidAndApplied);
      }

      // 2. Previous Outstanding & Auto-seed Ledger if customer is present
      double previousOutstanding = 0.0;
      if (customerId != null) {
        final ledgerQuery = _db.select(_db.ledgerEntries)
          ..where((t) => t.customerId.equals(customerId));
        final ledgerRows = await ledgerQuery.get();

        if (ledgerRows.isNotEmpty) {
          final sumDebit = ledgerRows.fold<double>(0.0, (s, e) => s + e.debit);
          final sumCredit = ledgerRows.fold<double>(0.0, (s, e) => s + e.credit);
          previousOutstanding = _round2(sumDebit - sumCredit);
        } else if (customerEntity != null) {
          previousOutstanding = _round2(customerEntity.openingBalance);
          if (customerEntity.openingBalance != 0.0) {
            await _db.into(_db.ledgerEntries).insert(
              LedgerEntriesCompanion.insert(
                customerId: customerId,
                date: billDate,
                type: 'opening_balance',
                referenceId: const Value(null),
                debit: Value(customerEntity.openingBalance),
                credit: const Value(0.0),
                runningBalance: customerEntity.openingBalance,
                createdAt: Value(createdAt),
              ),
            );
          }
        }
      }

      // 3. Insert Bills row
      final isWholesaleBill = customerEntity?.isWholesale ?? false;
      final billCompanion = BillsCompanion.insert(
        billNumber: billNumber,
        saleChannel: Value(saleChannel),
        customerId: Value(customerId),
        billDate: billDate,
        subtotal: subtotal,
        discount: Value(discount),
        otherCharges: Value(otherCharges),
        gstEnabled: Value(gstEnabled),
        gstPercent: Value(gstEnabled ? gstPercent : null),
        taxableAmount: Value(taxableAmountCalc),
        gstAmount: Value(gstAmountCalc),
        advanceApplied: Value(effectiveAdvanceToApply),
        previousOutstandingSnapshot: Value(previousOutstanding),
        currentBalanceSnapshot: const Value(null),
        grandTotal: grandTotal,
        amountPaid: Value(totalPaidAndApplied),
        remainingBalance: remainingBalance,
        status: const Value('active'),
        isWholesaleBill: Value(isWholesaleBill),
        notes: Value(notes?.trim().isEmpty == true ? null : notes?.trim()),
        createdAt: Value(createdAt),
      );
      final billId = await _db.into(_db.bills).insert(billCompanion);

      // 4. Insert BillItems & Stock Transactions (sold)
      for (final line in lines) {
        final lineAmount = _round2(line.quantity * line.rate);

        if (line.itemId != null) {
          final itemQuery = _db.select(_db.items)..where((t) => t.id.equals(line.itemId!));
          final itemEntity = await itemQuery.getSingle();

          await _db.into(_db.billItems).insert(
            BillItemsCompanion.insert(
              billId: billId,
              itemId: Value(line.itemId),
              sellingProductId: const Value(null),
              productName: Value(itemEntity.name),
              quantity: line.quantity,
              unit: itemEntity.unit,
              rate: line.rate,
              mrpRateAtSale: Value(itemEntity.sellingRate),
              amount: lineAmount,
            ),
          );

          final String refType = saleChannel == 'quick_sale' ? 'quick_sale' : 'bill';
          final String refNotes = saleChannel == 'quick_sale' ? 'Quick Sale $billNumber' : 'Bill $billNumber';

          // Stock transaction sold
          await _db.into(_db.stockTransactions).insert(
            StockTransactionsCompanion.insert(
              itemId: line.itemId!,
              type: 'sold',
              quantity: -line.quantity,
              referenceType: Value(refType),
              referenceId: Value(billId),
              date: billDate,
              notes: Value(refNotes),
              createdAt: Value(createdAt),
            ),
          );

          // Update item currentQty (allowed to go negative)
          final updatedQty = _round3(itemEntity.currentQty - line.quantity);
          await (_db.update(_db.items)..where((t) => t.id.equals(line.itemId!))).write(
            ItemsCompanion(currentQty: Value(updatedQty)),
          );
        } else if (line.sellingProductId != null) {
          final prodQuery = _db.select(_db.sellingProducts)..where((t) => t.id.equals(line.sellingProductId!));
          final prodEntity = await prodQuery.getSingle();

          await _db.into(_db.billItems).insert(
            BillItemsCompanion.insert(
              billId: billId,
              itemId: const Value(null),
              sellingProductId: Value(line.sellingProductId),
              productName: Value(prodEntity.name),
              quantity: line.quantity,
              unit: 'pcs',
              rate: line.rate,
              mrpRateAtSale: Value(prodEntity.price),
              amount: lineAmount,
            ),
          );
          // Own products: zero stock deduction, zero stock transactions
        }
      }

      // 5, 6, 7. Insert Ledger & Payments (ONLY IF customerId IS PRESENT)
      if (customerId != null) {
        final runningAfterBill = _round2(previousOutstanding + grandTotal);
        await _db.into(_db.ledgerEntries).insert(
          LedgerEntriesCompanion.insert(
            customerId: customerId,
            date: billDate,
            type: 'bill',
            referenceId: Value(billId),
            debit: Value(grandTotal),
            credit: const Value(0.0),
            runningBalance: runningAfterBill,
            createdAt: Value(createdAt),
          ),
        );

        if (effectiveAdvanceToApply > 0) {
          await _db.into(_db.payments).insert(
            PaymentsCompanion.insert(
              customerId: customerId,
              billId: Value(billId),
              amount: effectiveAdvanceToApply,
              method: 'advance',
              type: const Value('advance_applied'),
              date: billDate,
              notes: const Value('Applied from customer advance balance'),
              createdAt: Value(createdAt),
            ),
          );
        }

        if (amountReceived > 0) {
          final paymentCompanion = PaymentsCompanion.insert(
            customerId: customerId,
            billId: Value(billId),
            amount: amountReceived,
            method: paymentMethod ?? 'cash',
            type: const Value('bill_payment'),
            date: billDate,
            notes: const Value(null),
            createdAt: Value(createdAt),
          );
          final paymentId = await _db.into(_db.payments).insert(paymentCompanion);

          final runningAfterPayment = _round2(runningAfterBill - amountReceived);
          await _db.into(_db.ledgerEntries).insert(
            LedgerEntriesCompanion.insert(
              customerId: customerId,
              date: billDate,
              type: 'payment',
              referenceId: Value(paymentId),
              debit: const Value(0.0),
              credit: Value(amountReceived),
              runningBalance: runningAfterPayment,
              createdAt: Value(createdAt),
            ),
          );
        }

        // 8. Capture currentBalanceSnapshot fresh from ledger inside transaction
        final postLedgerQuery = _db.select(_db.ledgerEntries)
          ..where((t) => t.customerId.equals(customerId));
        final postLedgerRows = await postLedgerQuery.get();
        final postSumDebit = postLedgerRows.fold<double>(0.0, (s, e) => s + e.debit);
        final postSumCredit = postLedgerRows.fold<double>(0.0, (s, e) => s + e.credit);
        final currentBalance = _round2(postSumDebit - postSumCredit);

        final cashReceivedAtBilling = _round2(totalPaidAndApplied - effectiveAdvanceToApply);
        final expectedCurrent = _round2(previousOutstanding + grandTotal - cashReceivedAtBilling);
        assert(
          (currentBalance - expectedCurrent).abs() < 0.01,
          'currentBalanceSnapshot ($currentBalance) does not match expected ($expectedCurrent)',
        );

        await (_db.update(_db.bills)..where((b) => b.id.equals(billId))).write(
          BillsCompanion(
            currentBalanceSnapshot: Value(currentBalance),
          ),
        );
      }

      return billNumber;
    });
  }

  /// Get comprehensive bill details (bill, customer, items, payments)
  Future<BillDetailData?> getBillDetail(int billId) async {
    final query = _db.select(_db.bills).join([
      leftOuterJoin(_db.customers, _db.customers.id.equalsExp(_db.bills.customerId)),
    ])..where(_db.bills.id.equals(billId));

    final row = await query.getSingleOrNull();
    if (row == null) return null;

    final billEntity = row.readTable(_db.bills);
    final customerEntity = row.readTableOrNull(_db.customers) ??
        CustomerEntity(
          id: 0,
          name: 'Walk-in Customer',
          mobile: '',
          openingBalance: 0.0,
          isWholesale: false,
          isActive: true,
          createdAt: DateTime.now(),
        );

    final itemsQuery = _db.select(_db.billItems).join([
      leftOuterJoin(_db.items, _db.items.id.equalsExp(_db.billItems.itemId)),
      leftOuterJoin(_db.sellingProducts, _db.sellingProducts.id.equalsExp(_db.billItems.sellingProductId)),
    ])..where(_db.billItems.billId.equals(billId));

    final itemRows = await itemsQuery.get();
    final itemDetails = itemRows.map((r) {
      final bItem = r.readTable(_db.billItems);
      final item = r.readTableOrNull(_db.items);
      final prod = r.readTableOrNull(_db.sellingProducts);
      final itemName = bItem.productName ?? item?.name ?? prod?.name ?? 'Unknown Item';
      return BillItemDetail.fromEntity(bItem, itemName);
    }).toList();

    final paymentsQuery = _db.select(_db.payments)
      ..where((p) => p.billId.equals(billId))
      ..orderBy([(p) => OrderingTerm(expression: p.id, mode: OrderingMode.desc)]);

    final paymentRows = await paymentsQuery.get();

    final billModel = BillModel.fromEntity(
      billEntity,
      customerName: customerEntity.name,
      items: itemDetails,
    );

    return BillDetailData(
      bill: billModel,
      customer: customerEntity,
      items: itemDetails,
      payments: paymentRows,
    );
  }

  /// Record a payment against an active bill with remaining balance.
  /// If payment amount exceeds remaining balance, the applied portion settles the bill
  /// and the excess is recorded as an advance deposit.
  Future<void> recordPaymentForBill({
    required int billId,
    required double amount,
    required String method,
    DateTime? date,
    String? notes,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Payment amount must be greater than zero.');
    }

    final paymentDate = date ?? DateTime.now();

    await _db.transaction(() async {
      // Re-read bill fresh inside transaction
      final query = _db.select(_db.bills).join([
        innerJoin(_db.customers, _db.customers.id.equalsExp(_db.bills.customerId)),
      ])..where(_db.bills.id.equals(billId));

      final row = await query.getSingleOrNull();
      if (row == null) {
        throw ArgumentError('Bill #$billId does not exist.');
      }

      final billEntity = row.readTable(_db.bills);

      if (billEntity.status == 'void') {
        throw ArgumentError('Cannot record a payment against a voided bill');
      }

      if (billEntity.customerId == null) {
        throw ArgumentError('Cannot record a payment against a walk-in sale.');
      }

      final custId = billEntity.customerId!;
      final currentRemaining = _round2(billEntity.remainingBalance);
      final paymentAmount = _round2(amount);

      final appliedAmount = _round2(paymentAmount > currentRemaining ? currentRemaining : paymentAmount);
      final excessAmount = _round2(paymentAmount - appliedAmount);

      final now = DateTime.now();

      if (appliedAmount > 0) {
        final paymentId = await _db.into(_db.payments).insert(
          PaymentsCompanion.insert(
            customerId: custId,
            billId: Value(billId),
            amount: appliedAmount,
            method: method,
            type: const Value('bill_payment'),
            date: paymentDate,
            notes: Value(notes?.trim().isEmpty == true ? null : notes?.trim()),
            createdAt: Value(now),
          ),
        );

        final currentRunningBal = await getCustomerLedgerSummary(custId);
        final newRunningBal = _round2(currentRunningBal - appliedAmount);

        await _db.into(_db.ledgerEntries).insert(
          LedgerEntriesCompanion.insert(
            customerId: custId,
            date: paymentDate,
            type: 'payment',
            referenceId: Value(paymentId),
            debit: const Value(0.0),
            credit: Value(appliedAmount),
            runningBalance: newRunningBal,
            createdAt: Value(now),
          ),
        );

        final newAmountPaid = _round2(billEntity.amountPaid + appliedAmount);
        final newRemainingBalance = _round2(billEntity.remainingBalance - appliedAmount);

        await (_db.update(_db.bills)..where((b) => b.id.equals(billId))).write(
          BillsCompanion(
            amountPaid: Value(newAmountPaid),
            remainingBalance: Value(newRemainingBalance),
          ),
        );
      }

      if (excessAmount > 0) {
        final excessNote = notes?.trim().isNotEmpty == true
            ? '${notes!.trim()} (Excess on ${billEntity.billNumber})'
            : 'Excess payment on ${billEntity.billNumber}';

        final paymentId = await _db.into(_db.payments).insert(
          PaymentsCompanion.insert(
            customerId: custId,
            billId: const Value(null),
            amount: excessAmount,
            method: method,
            type: const Value('advance'),
            date: paymentDate,
            notes: Value(excessNote),
            createdAt: Value(now),
          ),
        );

        final currentRunningBal = await getCustomerLedgerSummary(custId);
        final newRunningBal = _round2(currentRunningBal - excessAmount);

        await _db.into(_db.ledgerEntries).insert(
          LedgerEntriesCompanion.insert(
            customerId: custId,
            date: paymentDate,
            type: 'advance_deposit',
            referenceId: Value(paymentId),
            debit: const Value(0.0),
            credit: Value(excessAmount),
            runningBalance: newRunningBal,
            createdAt: Value(now),
          ),
        );
      }
    });
  }

  /// Record a standalone advance / deposit for a customer
  Future<void> recordAdvanceDeposit({
    required int customerId,
    required double amount,
    required String method,
    DateTime? date,
    String? notes,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Advance amount must be greater than zero.');
    }

    final custQuery = _db.select(_db.customers)..where((t) => t.id.equals(customerId));
    final customer = await custQuery.getSingleOrNull();
    if (customer == null) {
      throw ArgumentError('Customer #$customerId does not exist.');
    }

    final paymentDate = date ?? DateTime.now();
    final now = DateTime.now();

    await _db.transaction(() async {
      final paymentId = await _db.into(_db.payments).insert(
        PaymentsCompanion.insert(
          customerId: customerId,
          billId: const Value(null),
          amount: _round2(amount),
          method: method,
          type: const Value('advance'),
          date: paymentDate,
          notes: Value(notes?.trim().isEmpty == true ? null : notes?.trim()),
          createdAt: Value(now),
        ),
      );

      final currentRunningBal = await getCustomerLedgerSummary(customerId);
      final newRunningBal = _round2(currentRunningBal - amount);

      await _db.into(_db.ledgerEntries).insert(
        LedgerEntriesCompanion.insert(
          customerId: customerId,
          date: paymentDate,
          type: 'advance_deposit',
          referenceId: Value(paymentId),
          debit: const Value(0.0),
          credit: Value(_round2(amount)),
          runningBalance: newRunningBal,
          createdAt: Value(now),
        ),
      );
    });
  }

  /// Void an active bill and reverse its stock and ledger debit effects
  Future<void> voidBill({
    required int billId,
    required String reason,
  }) async {
    final trimmedReason = reason.trim();
    if (trimmedReason.isEmpty) {
      throw ArgumentError('Reason for voiding is required.');
    }

    final now = DateTime.now();

    await _db.transaction(() async {
      // Re-read bill fresh inside transaction
      final query = _db.select(_db.bills).join([
        leftOuterJoin(_db.customers, _db.customers.id.equalsExp(_db.bills.customerId)),
      ])..where(_db.bills.id.equals(billId));

      final row = await query.getSingleOrNull();
      if (row == null) {
        throw ArgumentError('Bill #$billId does not exist.');
      }

      final billEntity = row.readTable(_db.bills);

      if (billEntity.status == 'void') {
        throw ArgumentError('This bill is already voided');
      }

      // 1. Fetch billItems
      final itemsQuery = _db.select(_db.billItems)..where((b) => b.billId.equals(billId));
      final billItems = await itemsQuery.get();

      // 2. Reverse stock transactions and restore item currentQty (stock lines only)
      for (final line in billItems) {
        if (line.itemId != null) {
          // Insert stockTransactions row reversing original sale
          await _db.into(_db.stockTransactions).insert(
            StockTransactionsCompanion.insert(
              itemId: line.itemId!,
              type: 'adjustment_increase',
              quantity: line.quantity,
              referenceType: const Value('bill_void'),
              referenceId: Value(billId),
              date: now,
              notes: Value('Void reversal for ${billEntity.billNumber}: $trimmedReason'),
              createdAt: Value(now),
            ),
          );

          // Increase currentQty by line.quantity
          final itemQuery = _db.select(_db.items)..where((i) => i.id.equals(line.itemId!));
          final itemEntity = await itemQuery.getSingleOrNull();
          if (itemEntity != null) {
            final updatedQty = _round3(itemEntity.currentQty + line.quantity);
            await (_db.update(_db.items)..where((i) => i.id.equals(line.itemId!))).write(
              ItemsCompanion(currentQty: Value(updatedQty)),
            );
          }
        }
      }

      // 3. Insert ONE offsetting ledgerEntries row to reverse original bill debit (if customer exists)
      if (billEntity.customerId != null) {
        final custId = billEntity.customerId!;
        final currentRunningBal = await getCustomerLedgerSummary(custId);
        final newRunningBal = _round2(currentRunningBal - billEntity.grandTotal);

        await _db.into(_db.ledgerEntries).insert(
          LedgerEntriesCompanion.insert(
            customerId: custId,
            date: now,
            type: 'bill',
            referenceId: Value(billId),
            debit: const Value(0.0),
            credit: Value(billEntity.grandTotal),
            runningBalance: newRunningBal,
            createdAt: Value(now),
          ),
        );
      }

      // 4. Update bills status = 'void', voidReason, and voidedAt
      await (_db.update(_db.bills)..where((b) => b.id.equals(billId))).write(
        BillsCompanion(
          status: const Value('void'),
          voidReason: Value(trimmedReason),
          voidedAt: Value(now),
        ),
      );
    });
  }

  /// Summary of sales created today (excluding voided bills)
  Future<TodaysSalesSummary> getTodaysSalesSummary() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final query = _db.select(_db.bills)
      ..where((b) =>
          b.billDate.isBetweenValues(startOfDay, endOfDay) &
          b.status.equals('void').not());

    final billsToday = await query.get();
    final totalAmount = billsToday.fold<double>(0.0, (s, b) => s + b.grandTotal);
    return TodaysSalesSummary(
      totalAmount: _round2(totalAmount),
      billCount: billsToday.length,
    );
  }

  /// Summary of payments collected today (cash, upi, other breakdown)
  Future<TodaysPaymentsSummary> getTodaysPaymentsSummary() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final query = _db.select(_db.payments)
      ..where((p) => p.date.isBetweenValues(startOfDay, endOfDay));

    final paymentsToday = await query.get();
    double totalAmount = 0.0;
    double cashAmount = 0.0;
    double upiAmount = 0.0;
    double otherAmount = 0.0;

    for (final p in paymentsToday) {
      totalAmount += p.amount;
      final m = p.method.toLowerCase();
      if (m == 'cash') {
        cashAmount += p.amount;
      } else if (m == 'upi') {
        upiAmount += p.amount;
      } else {
        otherAmount += p.amount;
      }
    }

    return TodaysPaymentsSummary(
      totalAmount: _round2(totalAmount),
      cashAmount: _round2(cashAmount),
      upiAmount: _round2(upiAmount),
      otherAmount: _round2(otherAmount),
    );
  }

  /// Total outstanding balance across all customers and count of customers with balance > 0
  Future<TotalOutstandingSummary> getTotalOutstanding() async {
    final customers = await _db.select(_db.customers).get();
    double sumOutstanding = 0.0;
    int countWithBalance = 0;

    for (final cust in customers) {
      final bal = await getCustomerLedgerSummary(cust.id);
      if (bal > 0) {
        sumOutstanding += bal;
        countWithBalance++;
      }
    }

    return TotalOutstandingSummary(
      totalOutstanding: _round2(sumOutstanding),
      customersWithBalanceCount: countWithBalance,
    );
  }

  /// Fetch recent N bills for dashboard preview
  Future<List<BillModel>> getRecentBills({int limit = 5}) async {
    final query = _db.select(_db.bills).join([
      leftOuterJoin(_db.customers, _db.customers.id.equalsExp(_db.bills.customerId)),
    ])
      ..orderBy([
        OrderingTerm(expression: _db.bills.id, mode: OrderingMode.desc),
      ])
      ..limit(limit);

    final rows = await query.get();
    return rows.map((row) {
      final bill = row.readTable(_db.bills);
      final customer = row.readTableOrNull(_db.customers);
      return BillModel.fromEntity(bill, customerName: customer?.name);
    }).toList();
  }

  /// Fetch quick sales ordered by ID desc
  Future<List<BillModel>> getQuickSales({
    DateTime? from,
    DateTime? to,
    String? statusFilter,
  }) async {
    final query = _db.select(_db.bills).join([
      leftOuterJoin(_db.customers, _db.customers.id.equalsExp(_db.bills.customerId)),
    ])..where(_db.bills.saleChannel.equals('quick_sale'));

    if (from != null && to != null) {
      final startOfFrom = DateTime(from.year, from.month, from.day);
      final endOfTo = DateTime(to.year, to.month, to.day, 23, 59, 59);
      query.where(_db.bills.billDate.isBetweenValues(startOfFrom, endOfTo));
    }

    query.orderBy([
      OrderingTerm(expression: _db.bills.id, mode: OrderingMode.desc),
    ]);

    final rows = await query.get();
    final list = rows.map((row) {
      final bill = row.readTable(_db.bills);
      final customer = row.readTableOrNull(_db.customers);
      return BillModel.fromEntity(bill, customerName: customer?.name);
    }).toList();

    if (statusFilter != null && statusFilter != 'all') {
      return list.where((b) => b.paymentStatus.name == statusFilter).toList();
    }
    return list;
  }

  /// Summary of quick sales created today (excluding voided bills)
  Future<TodaysSalesSummary> getTodaysQuickSaleSummary() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final query = _db.select(_db.bills)
      ..where((b) =>
          b.saleChannel.equals('quick_sale') &
          b.billDate.isBetweenValues(startOfDay, endOfDay) &
          b.status.equals('void').not());

    final billsToday = await query.get();
    final totalAmount = billsToday.fold<double>(0.0, (s, b) => s + b.grandTotal);
    return TodaysSalesSummary(
      totalAmount: _round2(totalAmount),
      billCount: billsToday.length,
    );
  }

  /// Returns true ONLY if customers, items, and bills tables are ALL empty (0 rows in each)
  Future<bool> isFreshInstall() async {
    final custCount = await _db.customSelect('SELECT COUNT(*) AS c FROM customers').getSingle();
    final itemsCount = await _db.customSelect('SELECT COUNT(*) AS c FROM items').getSingle();
    final billsCount = await _db.customSelect('SELECT COUNT(*) AS c FROM bills').getSingle();

    final cCount = custCount.read<int>('c');
    final iCount = itemsCount.read<int>('c');
    final bCount = billsCount.read<int>('c');

    return cCount == 0 && iCount == 0 && bCount == 0;
  }

  /// Get daily sales report breakdown and totals for date range [from] to [to] (inclusive)
  Future<DailySalesReportData> getDailySalesReport({
    required DateTime from,
    required DateTime to,
  }) async {
    final startOfFrom = DateTime(from.year, from.month, from.day);
    final endOfTo = DateTime(to.year, to.month, to.day, 23, 59, 59);

    final query = _db.select(_db.bills)
      ..where((b) =>
          b.billDate.isBetweenValues(startOfFrom, endOfTo) &
          b.status.equals('void').not());

    final billRows = await query.get();

    final Map<String, List<BillEntity>> grouped = {};
    for (final bill in billRows) {
      final key =
          '${bill.billDate.year}-${bill.billDate.month.toString().padLeft(2, '0')}-${bill.billDate.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(bill);
    }

    final List<DailySalesPoint> points = [];
    double grandTotalSum = 0.0;
    int grandBillCount = 0;

    DateTime cursor = startOfFrom;
    while (!cursor.isAfter(to)) {
      final key =
          '${cursor.year}-${cursor.month.toString().padLeft(2, '0')}-${cursor.day.toString().padLeft(2, '0')}';
      final dayBills = grouped[key] ?? [];
      final daySales = _round2(dayBills.fold<double>(0.0, (sum, b) => sum + b.grandTotal));
      final dayCount = dayBills.length;

      points.add(DailySalesPoint(
        date: DateTime(cursor.year, cursor.month, cursor.day),
        totalSales: daySales,
        billCount: dayCount,
      ));

      grandTotalSum += daySales;
      grandBillCount += dayCount;

      cursor = cursor.add(const Duration(days: 1));
    }

    grandTotalSum = _round2(grandTotalSum);
    final avgValue = grandBillCount > 0 ? _round2(grandTotalSum / grandBillCount) : 0.0;

    return DailySalesReportData(
      points: points,
      totalSales: grandTotalSum,
      totalBills: grandBillCount,
      averageBillValue: avgValue,
    );
  }

  /// Get monthly sales report breakdown and totals for the last [monthsBack] months
  Future<MonthlySalesReportData> getMonthlySalesReport({
    required int monthsBack,
  }) async {
    final now = DateTime.now();
    final List<MapEntry<int, int>> monthTargets = [];
    for (int i = monthsBack - 1; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      monthTargets.add(MapEntry(d.year, d.month));
    }

    final firstTarget = monthTargets.first;
    final startOfRange = DateTime(firstTarget.key, firstTarget.value, 1);
    final endOfRange = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final query = _db.select(_db.bills)
      ..where((b) =>
          b.billDate.isBetweenValues(startOfRange, endOfRange) &
          b.status.equals('void').not());

    final billRows = await query.get();

    final Map<String, List<BillEntity>> grouped = {};
    for (final bill in billRows) {
      final key = '${bill.billDate.year}-${bill.billDate.month}';
      grouped.putIfAbsent(key, () => []).add(bill);
    }

    final List<MonthlySalesPoint> points = [];
    double grandTotalSum = 0.0;
    int grandBillCount = 0;

    for (final target in monthTargets) {
      final key = '${target.key}-${target.value}';
      final monthBills = grouped[key] ?? [];
      final monthSales = _round2(monthBills.fold<double>(0.0, (sum, b) => sum + b.grandTotal));
      final monthCount = monthBills.length;

      points.add(MonthlySalesPoint(
        year: target.key,
        month: target.value,
        totalSales: monthSales,
        billCount: monthCount,
      ));

      grandTotalSum += monthSales;
      grandBillCount += monthCount;
    }

    grandTotalSum = _round2(grandTotalSum);
    final avgValue = grandBillCount > 0 ? _round2(grandTotalSum / grandBillCount) : 0.0;

    return MonthlySalesReportData(
      points: points,
      totalSales: grandTotalSum,
      totalBills: grandBillCount,
      averageBillValue: avgValue,
    );
  }

  /// Get customer outstanding report (customers with balance > 0)
  Future<CustomerOutstandingReportData> getCustomerOutstandingReport({
    required bool highestFirst,
  }) async {
    final customers = await _db.select(_db.customers).get();
    final List<CustomerOutstandingItem> items = [];
    double totalOutstandingSum = 0.0;

    for (final cust in customers) {
      final bal = await getCustomerLedgerSummary(cust.id);
      if (bal > 0) {
        final billQuery = _db.select(_db.bills)
          ..where((b) => b.customerId.equals(cust.id) & b.status.equals('void').not())
          ..orderBy([(b) => OrderingTerm(expression: b.billDate, mode: OrderingMode.desc)])
          ..limit(1);
        final lastBill = await billQuery.getSingleOrNull();

        items.add(CustomerOutstandingItem(
          id: cust.id,
          name: cust.name,
          mobile: cust.mobile,
          outstanding: bal,
          lastBilledDate: lastBill?.billDate,
        ));

        totalOutstandingSum += bal;
      }
    }

    if (highestFirst) {
      items.sort((a, b) {
        final cmp = b.outstanding.compareTo(a.outstanding);
        if (cmp != 0) return cmp;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    } else {
      // Oldest Bill First
      items.sort((a, b) {
        if (a.lastBilledDate == null && b.lastBilledDate == null) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        }
        if (a.lastBilledDate == null) return 1;
        if (b.lastBilledDate == null) return -1;
        final cmp = a.lastBilledDate!.compareTo(b.lastBilledDate!);
        if (cmp != 0) return cmp;
        return b.outstanding.compareTo(a.outstanding);
      });
    }

    return CustomerOutstandingReportData(
      items: items,
      totalOutstanding: _round2(totalOutstandingSum),
      customerCount: items.length,
    );
  }

  /// Get Payment Report breakdown for date range [from] to [to] (inclusive)
  Future<PaymentReportData> getPaymentReport({
    required DateTime from,
    required DateTime to,
  }) async {
    final startOfFrom = DateTime(from.year, from.month, from.day);
    final endOfTo = DateTime(to.year, to.month, to.day, 23, 59, 59);

    final query = _db.select(_db.payments).join([
      innerJoin(_db.customers, _db.customers.id.equalsExp(_db.payments.customerId)),
      leftOuterJoin(_db.bills, _db.bills.id.equalsExp(_db.payments.billId)),
    ])
      ..where(_db.payments.date.isBetweenValues(startOfFrom, endOfTo))
      ..orderBy([
        OrderingTerm(expression: _db.payments.date, mode: OrderingMode.desc),
        OrderingTerm(expression: _db.payments.id, mode: OrderingMode.desc),
      ]);

    final rows = await query.get();

    final items = <PaymentReportItem>[];
    double totalCollected = 0.0;
    double cashTotal = 0.0;
    double upiTotal = 0.0;
    double otherTotal = 0.0;

    for (final row in rows) {
      final pmt = row.readTable(_db.payments);
      final cust = row.readTable(_db.customers);
      final bill = row.readTableOrNull(_db.bills);

      final amt = _round2(pmt.amount);
      totalCollected += amt;

      final m = pmt.method.toLowerCase();
      if (m == 'cash') {
        cashTotal += amt;
      } else if (m == 'upi') {
        upiTotal += amt;
      } else {
        otherTotal += amt;
      }

      items.add(
        PaymentReportItem(
          id: pmt.id,
          date: pmt.date,
          customerName: cust.name,
          billId: pmt.billId,
          billNumber: bill?.billNumber,
          amount: amt,
          method: pmt.method,
          notes: pmt.notes,
        ),
      );
    }

    return PaymentReportData(
      items: items,
      totalCollected: _round2(totalCollected),
      cashTotal: _round2(cashTotal),
      upiTotal: _round2(upiTotal),
      otherTotal: _round2(otherTotal),
      paymentCount: items.length,
    );
  }

  String _formatDateShort(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  /// Get financial summary for a customer (total billed, total paid, current outstanding, advance balance)
  Future<CustomerFinancialSummary> getCustomerFinancialSummary(int customerId) async {
    final billsQuery = _db.select(_db.bills)
      ..where((b) => b.customerId.equals(customerId) & b.status.equals('void').not());
    final bills = await billsQuery.get();
    final totalBilled = _round2(bills.fold<double>(0.0, (s, b) => s + b.grandTotal));

    final paymentsQuery = _db.select(_db.payments)
      ..where((p) => p.customerId.equals(customerId));
    final payments = await paymentsQuery.get();
    final totalPaid = _round2(payments.fold<double>(0.0, (s, p) => s + p.amount));

    final runningBal = await getCustomerLedgerSummary(customerId);
    final outstandingBalance = _round2(runningBal > 0 ? runningBal : 0.0);
    final advanceBalance = _round2(runningBal < 0 ? -runningBal : 0.0);

    return CustomerFinancialSummary(
      totalBilled: totalBilled,
      totalPaid: totalPaid,
      outstandingBalance: outstandingBalance,
      advanceBalance: advanceBalance,
    );
  }

  /// Get all bills for a specific customer (most recent first, including void bills)
  Future<List<CustomerBill>> getBillsForCustomer(int customerId) async {
    final query = _db.select(_db.bills)
      ..where((b) => b.customerId.equals(customerId))
      ..orderBy([
        (b) => OrderingTerm(expression: b.billDate, mode: OrderingMode.desc),
        (b) => OrderingTerm(expression: b.id, mode: OrderingMode.desc),
      ]);

    final rows = await query.get();
    final List<CustomerBill> result = [];

    for (final bill in rows) {
      final itemsQuery = _db.select(_db.billItems).join([
        leftOuterJoin(_db.items, _db.items.id.equalsExp(_db.billItems.itemId)),
        leftOuterJoin(_db.sellingProducts, _db.sellingProducts.id.equalsExp(_db.billItems.sellingProductId)),
      ])..where(_db.billItems.billId.equals(bill.id));

      final itemRows = await itemsQuery.get();
      final itemNames = itemRows.map((r) {
        final bItem = r.readTable(_db.billItems);
        final item = r.readTableOrNull(_db.items);
        final prod = r.readTableOrNull(_db.sellingProducts);
        return bItem.productName ?? item?.name ?? prod?.name ?? 'Item';
      }).toList();

      final String itemsSummary;
      if (itemNames.isEmpty) {
        itemsSummary = 'Bill #${bill.billNumber}';
      } else {
        final count = itemNames.length;
        itemsSummary = '$count item${count == 1 ? '' : 's'} • ${itemNames.join(', ')}';
      }

      final BillStatus status;
      final String statusLabel;
      final computed = computeBillStatus(
        status: bill.status,
        remainingBalance: bill.remainingBalance,
        grandTotal: bill.grandTotal,
        amountPaid: bill.amountPaid,
      );
      switch (computed) {
        case BillPaymentStatus.voided:
          status = BillStatus.voided;
          statusLabel = 'Void';
          break;
        case BillPaymentStatus.paid:
          status = BillStatus.paid;
          statusLabel = 'Paid';
          break;
        case BillPaymentStatus.partial:
          status = BillStatus.partial;
          statusLabel = 'Partial';
          break;
        case BillPaymentStatus.unpaid:
          status = BillStatus.unpaid;
          statusLabel = 'Unpaid';
          break;
      }

      result.add(
        CustomerBill(
          id: bill.id,
          billNumber: bill.billNumber,
          date: _formatDateShort(bill.billDate),
          totalAmount: bill.grandTotal,
          itemsSummary: itemsSummary,
          status: status,
          statusLabel: statusLabel,
        ),
      );
    }

    return result;
  }

  /// Get all payments for a specific customer (most recent first)
  Future<List<CustomerPayment>> getPaymentsForCustomer(int customerId) async {
    final query = _db.select(_db.payments).join([
      leftOuterJoin(_db.bills, _db.bills.id.equalsExp(_db.payments.billId)),
    ])
      ..where(_db.payments.customerId.equals(customerId))
      ..orderBy([
        OrderingTerm(expression: _db.payments.date, mode: OrderingMode.desc),
        OrderingTerm(expression: _db.payments.id, mode: OrderingMode.desc),
      ]);

    final rows = await query.get();
    final List<CustomerPayment> result = [];

    for (final row in rows) {
      final payment = row.readTable(_db.payments);
      final bill = row.readTableOrNull(_db.bills);

      final String methodStr = payment.method.toLowerCase();
      final PaymentMethod method;
      final String methodLabel;
      if (methodStr == 'cash') {
        method = PaymentMethod.cash;
        methodLabel = 'Cash Payment';
      } else if (methodStr == 'upi') {
        method = PaymentMethod.upi;
        methodLabel = 'UPI Payment';
      } else if (methodStr == 'advance') {
        method = PaymentMethod.other;
        methodLabel = 'Advance Credit Applied';
      } else {
        method = PaymentMethod.other;
        methodLabel = 'Payment (${payment.method.toUpperCase()})';
      }

      String refNote = '';
      if (payment.type == 'advance') {
        refNote = 'Advance Deposit / Credit';
        if (payment.notes != null && payment.notes!.trim().isNotEmpty) {
          refNote += ' • ${payment.notes!.trim()}';
        }
      } else if (payment.type == 'advance_applied') {
        refNote = bill != null ? 'Applied to Bill #${bill.billNumber}' : 'Advance Applied';
      } else if (bill != null) {
        refNote = 'Ref: Bill #${bill.billNumber}';
        if (payment.notes != null && payment.notes!.trim().isNotEmpty) {
          refNote += ' • ${payment.notes!.trim()}';
        }
      } else if (payment.notes != null && payment.notes!.trim().isNotEmpty) {
        refNote = payment.notes!.trim();
      } else {
        refNote = 'Direct Payment #${payment.id}';
      }

      result.add(
        CustomerPayment(
          id: payment.id.toString(),
          date: _formatDateShort(payment.date),
          amount: payment.amount,
          method: method,
          methodLabel: methodLabel,
          referenceNote: refNote,
          linkedBillNumber: bill?.billNumber,
        ),
      );
    }

    return result;
  }

  /// Get all ledger entries for a specific customer (most recent first)
  Future<List<LedgerEntry>> getLedgerEntriesForCustomer(int customerId) async {
    final query = _db.select(_db.ledgerEntries).join([
      leftOuterJoin(_db.bills, _db.bills.id.equalsExp(_db.ledgerEntries.referenceId)),
    ])
      ..where(_db.ledgerEntries.customerId.equals(customerId))
      ..orderBy([
        OrderingTerm(expression: _db.ledgerEntries.date, mode: OrderingMode.desc),
        OrderingTerm(expression: _db.ledgerEntries.id, mode: OrderingMode.desc),
      ]);

    final rows = await query.get();
    final List<LedgerEntry> result = [];

    for (final row in rows) {
      final entry = row.readTable(_db.ledgerEntries);
      final bill = row.readTableOrNull(_db.bills);

      final bool isDebit = entry.debit > 0;
      final double amount = isDebit ? entry.debit : entry.credit;

      final LedgerEntryType type;
      final String title;
      final String description;

      if (entry.type == 'bill') {
        type = LedgerEntryType.bill;
        final billNum = bill?.billNumber;
        title = billNum != null ? 'Bill #$billNum' : 'Bill #${entry.referenceId ?? ''}';
        description = isDebit ? 'Sales Invoice' : 'Bill Reversal / Void';
      } else if (entry.type == 'payment') {
        type = LedgerEntryType.payment;
        title = 'Payment Received';
        description = 'Customer Payment';
      } else if (entry.type == 'advance_deposit') {
        type = LedgerEntryType.advanceDeposit;
        title = 'Advance Deposit';
        description = 'Customer Advance Credit Received';
      } else {
        type = LedgerEntryType.openingBalance;
        title = 'Opening Balance';
        description = 'Initial Customer Balance';
      }

      result.add(
        LedgerEntry(
          id: entry.id.toString(),
          date: _formatDateShort(entry.date),
          type: type,
          title: title,
          description: description,
          amount: amount,
          isDebit: isDebit,
          runningBalance: entry.runningBalance,
        ),
      );
    }

    return result;
  }
}

class PaymentReportItem {
  final int id;
  final DateTime date;
  final String customerName;
  final int? billId;
  final String? billNumber;
  final double amount;
  final String method;
  final String? notes;

  const PaymentReportItem({
    required this.id,
    required this.date,
    required this.customerName,
    this.billId,
    this.billNumber,
    required this.amount,
    required this.method,
    this.notes,
  });
}

class PaymentReportData {
  final List<PaymentReportItem> items;
  final double totalCollected;
  final double cashTotal;
  final double upiTotal;
  final double otherTotal;
  final int paymentCount;

  const PaymentReportData({
    required this.items,
    required this.totalCollected,
    required this.cashTotal,
    required this.upiTotal,
    required this.otherTotal,
    required this.paymentCount,
  });
}
