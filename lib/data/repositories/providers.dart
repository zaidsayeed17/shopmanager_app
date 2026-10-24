import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/app_database.dart';
import '../models/item_model.dart';
import '../models/worker_model.dart';
import '../../services/excel_export_service.dart';
import '../../services/backup_service.dart';
import '../../services/demo_data_service.dart';
import '../../services/factory_reset_service.dart';
import 'customer_repository.dart';
import 'item_repository.dart';
import 'stock_repository.dart';
import 'worker_repository.dart';
import 'worker_wage_repository.dart';
import 'worker_cutting_repository.dart';
import 'worker_issue_repository.dart';
import 'production_repository.dart';
import 'billing_repository.dart';
import 'business_profile_repository.dart';
import '../models/bill_model.dart';
import '../models/selling_product_model.dart';
import '../models/billable_product_model.dart';
import 'selling_product_repository.dart';
import '../../features/customers/customers_placeholder_data.dart';

/// AppDatabase singleton provider
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// ExcelExportService provider
final excelExportServiceProvider = Provider<ExcelExportService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ExcelExportService(db);
});

/// BackupService provider
final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BackupService(db);
});

/// DemoDataService provider
final demoDataServiceProvider = Provider<DemoDataService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DemoDataService(db);
});

/// FactoryResetService provider
final factoryResetServiceProvider = Provider<FactoryResetService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return FactoryResetService(db);
});

/// CustomerRepository provider
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CustomerRepository(db);
});

/// Stream of all customers from the database for real-time UI updates
final customersStreamProvider = StreamProvider<List<Customer>>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.watchAllCustomers();
});

/// Future provider to fetch a single customer by ID
final customerByIdProvider = FutureProvider.family<Customer?, int>((ref, id) async {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getCustomerById(id);
});

/// ItemRepository provider
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ItemRepository(db);
});

/// Stream of all items from the database for real-time UI updates
final itemsStreamProvider = StreamProvider<List<ItemModel>>((ref) {
  final repository = ref.watch(itemRepositoryProvider);
  return repository.watchAllItems();
});

/// Future provider to fetch active raw materials for material issuing
final activeRawMaterialsProvider = FutureProvider<List<ItemModel>>((ref) async {
  final repository = ref.watch(itemRepositoryProvider);
  return repository.getActiveRawMaterials();
});

/// Future provider to fetch a single item by ID
final itemByIdProvider = FutureProvider.family<ItemModel?, int>((ref, id) async {
  final repository = ref.watch(itemRepositoryProvider);
  return repository.getItemById(id);
});

/// SellingProductRepository provider
final sellingProductRepositoryProvider = Provider<SellingProductRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SellingProductRepository(db);
});

/// Stream of all selling products
final sellingProductsStreamProvider = StreamProvider<List<SellingProductModel>>((ref) {
  final repo = ref.watch(sellingProductRepositoryProvider);
  return repo.watchAllProducts();
});

/// Stream of active selling products
final activeSellingProductsStreamProvider = StreamProvider<List<SellingProductModel>>((ref) {
  final repo = ref.watch(sellingProductRepositoryProvider);
  return repo.watchActiveProducts();
});

/// Future provider to fetch a single selling product by ID
final sellingProductByIdProvider = FutureProvider.family<SellingProductModel?, int>((ref, id) async {
  final repo = ref.watch(sellingProductRepositoryProvider);
  return repo.getProductById(id);
});

/// Combined billable products stream provider (Stock Items + Selling Products)
final billableProductsStreamProvider = StreamProvider<List<BillableProduct>>((ref) {
  final itemsAsync = ref.watch(itemsStreamProvider);
  final sellingProductsAsync = ref.watch(activeSellingProductsStreamProvider);

  final stockItems = itemsAsync.value ?? [];
  final sellingProducts = sellingProductsAsync.value ?? [];

  final List<BillableProduct> combined = [
    ...sellingProducts.map((p) => BillableProduct.fromSellingProduct(p)),
    ...stockItems.where((i) => i.isActive).map((i) => BillableProduct.fromStockItem(i)),
  ];

  combined.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return Stream.value(combined);
});

/// StockRepository provider
final stockRepositoryProvider = Provider<StockRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return StockRepository(db);
});

/// Stream of stock transactions for a specific item with computed running balance
final stockTransactionsStreamProvider =
    StreamProvider.family<List<StockTransactionWithBalance>, int>((ref, itemId) {
  final repository = ref.watch(stockRepositoryProvider);
  return repository.watchItemTransactions(itemId);
});

/// WorkerRepository provider
final workerRepositoryProvider = Provider<WorkerRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return WorkerRepository(db);
});

/// Stream of all workers from the database for real-time UI updates
final workersStreamProvider = StreamProvider<List<WorkerModel>>((ref) {
  final repository = ref.watch(workerRepositoryProvider);
  return repository.watchAllWorkers();
});

/// Future provider to fetch a single worker by ID
final workerByIdProvider = FutureProvider.family<WorkerModel?, int>((ref, id) async {
  final repository = ref.watch(workerRepositoryProvider);
  return repository.getWorkerById(id);
});

/// WorkerIssueRepository provider
final workerIssueRepositoryProvider = Provider<WorkerIssueRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return WorkerIssueRepository(db);
});

/// Future provider to fetch active finished product items for record production
final finishedProductsProvider = FutureProvider<List<ItemModel>>((ref) async {
  final repository = ref.watch(itemRepositoryProvider);
  return repository.getFinishedProducts();
});

/// ProductionRepository provider
final productionRepositoryProvider = Provider<ProductionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ProductionRepository(db);
});

/// Future provider to fetch pending materials for a specific worker
final pendingMaterialsForWorkerProvider =
    FutureProvider.family<List<PendingMaterialForWorker>, int>((ref, workerId) async {
  final repository = ref.watch(productionRepositoryProvider);
  return repository.getPendingMaterialsForWorker(workerId);
});

/// BillingRepository provider
final billingRepositoryProvider = Provider<BillingRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BillingRepository(db);
});

/// Stream of all bills from the database for real-time UI updates
final billsStreamProvider = StreamProvider<List<BillModel>>((ref) {
  final repository = ref.watch(billingRepositoryProvider);
  return repository.watchAllBills();
});

/// Future provider to fetch customer ledger summary (previous outstanding balance)
final customerLedgerSummaryProvider =
    FutureProvider.family<double, int>((ref, customerId) async {
  final repository = ref.watch(billingRepositoryProvider);
  return repository.getCustomerLedgerSummary(customerId);
});

/// Future provider to fetch customer advance credit balance
final customerAdvanceBalanceProvider =
    FutureProvider.family<double, int>((ref, customerId) async {
  final repository = ref.watch(billingRepositoryProvider);
  return repository.getCustomerAdvanceBalance(customerId);
});

/// Future provider to fetch preview of next bill number
final nextBillNumberProvider = FutureProvider<String>((ref) async {
  final repository = ref.watch(billingRepositoryProvider);
  return repository.getNextBillNumber();
});

/// Future provider to fetch a single bill by ID
final billByIdProvider = FutureProvider.family<BillModel?, int>((ref, id) async {
  final repository = ref.watch(billingRepositoryProvider);
  return repository.getBillById(id);
});

/// Future provider to fetch full bill detail data (bill, customer, items, payments)
final billDetailProvider = FutureProvider.family<BillDetailData?, int>((ref, id) async {
  final repository = ref.watch(billingRepositoryProvider);
  return repository.getBillDetail(id);
});

/// DASHBOARD PROVIDERS

final todaysSalesSummaryProvider = FutureProvider<TodaysSalesSummary>((ref) async {
  final repository = ref.watch(billingRepositoryProvider);
  return repository.getTodaysSalesSummary();
});

final todaysQuickSaleSummaryProvider = FutureProvider<TodaysSalesSummary>((ref) async {
  final repository = ref.watch(billingRepositoryProvider);
  return repository.getTodaysQuickSaleSummary();
});

class QuickSalesQueryParams {
  final DateTime? from;
  final DateTime? to;
  final String? statusFilter;

  const QuickSalesQueryParams({this.from, this.to, this.statusFilter});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuickSalesQueryParams &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to &&
          statusFilter == other.statusFilter;

  @override
  int get hashCode => Object.hash(from, to, statusFilter);
}

final quickSalesProvider =
    FutureProvider.family<List<BillModel>, QuickSalesQueryParams>((ref, params) async {
  final repository = ref.watch(billingRepositoryProvider);
  return repository.getQuickSales(
    from: params.from,
    to: params.to,
    statusFilter: params.statusFilter,
  );
});

final todaysPaymentsSummaryProvider = FutureProvider<TodaysPaymentsSummary>((ref) async {
  final repository = ref.watch(billingRepositoryProvider);
  return repository.getTodaysPaymentsSummary();
});

final totalOutstandingProvider = FutureProvider<TotalOutstandingSummary>((ref) async {
  final repository = ref.watch(billingRepositoryProvider);
  return repository.getTotalOutstanding();
});

final recentBillsProvider = FutureProvider<List<BillModel>>((ref) async {
  final repository = ref.watch(billingRepositoryProvider);
  return repository.getRecentBills(limit: 5);
});

final stockOverviewProvider = FutureProvider<StockOverviewSummary>((ref) async {
  final repository = ref.watch(itemRepositoryProvider);
  return repository.getStockOverview();
});

final workersPendingSummaryProvider = FutureProvider<WorkersPendingSummary>((ref) async {
  final repository = ref.watch(workerRepositoryProvider);
  return repository.getWorkersWithPendingSummary();
});

final pendingMaterialPreviewProvider = FutureProvider<List<PendingMaterialPreview>>((ref) async {
  final repository = ref.watch(workerRepositoryProvider);
  return repository.getPendingMaterialPreview(limit: 3);
});

final isFreshInstallProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(billingRepositoryProvider);
  return repository.isFreshInstall();
});

/// REPORT PROVIDERS

class DailySalesReportParams {
  final DateTime from;
  final DateTime to;

  const DailySalesReportParams({required this.from, required this.to});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailySalesReportParams &&
          runtimeType == other.runtimeType &&
          from.year == other.from.year &&
          from.month == other.from.month &&
          from.day == other.from.day &&
          to.year == other.to.year &&
          to.month == other.to.month &&
          to.day == other.to.day;

  @override
  int get hashCode =>
      Object.hash(from.year, from.month, from.day, to.year, to.month, to.day);
}

final dailySalesReportProvider =
    FutureProvider.family<DailySalesReportData, DailySalesReportParams>((ref, params) async {
  final repository = ref.watch(billingRepositoryProvider);
  return repository.getDailySalesReport(from: params.from, to: params.to);
});

final monthlySalesReportProvider =
    FutureProvider.family<MonthlySalesReportData, int>((ref, monthsBack) async {
  final repository = ref.watch(billingRepositoryProvider);
  return repository.getMonthlySalesReport(monthsBack: monthsBack);
});

final customerOutstandingReportProvider =
    FutureProvider.family<CustomerOutstandingReportData, bool>((ref, highestFirst) async {
  final repository = ref.watch(billingRepositoryProvider);
  return repository.getCustomerOutstandingReport(highestFirst: highestFirst);
});

final stockReportProvider = FutureProvider<StockReportData>((ref) async {
  final repository = ref.watch(itemRepositoryProvider);
  return repository.getStockReport();
});

class StockMovementReportParams {
  final DateTime? from;
  final DateTime? to;
  final String? typeFilter;

  const StockMovementReportParams({this.from, this.to, this.typeFilter});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockMovementReportParams &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to &&
          typeFilter == other.typeFilter;

  @override
  int get hashCode => Object.hash(from, to, typeFilter);
}

final stockMovementReportProvider =
    FutureProvider.family<StockMovementReportData, StockMovementReportParams>((ref, params) async {
  final repository = ref.watch(stockRepositoryProvider);
  return repository.getStockMovementReport(
    from: params.from,
    to: params.to,
    typeFilter: params.typeFilter,
  );
});

final lowStockReportProvider = FutureProvider<LowStockReportData>((ref) async {
  final repository = ref.watch(itemRepositoryProvider);
  return repository.getLowStockReport();
});

final workerMaterialReportProvider = FutureProvider<WorkerMaterialReportData>((ref) async {
  final repository = ref.watch(productionRepositoryProvider);
  return repository.getWorkerMaterialReport();
});

class DateRangeParams {
  final DateTime from;
  final DateTime to;

  const DateRangeParams({required this.from, required this.to});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRangeParams &&
          runtimeType == other.runtimeType &&
          from.year == other.from.year &&
          from.month == other.from.month &&
          from.day == other.from.day &&
          to.year == other.to.year &&
          to.month == other.to.month &&
          to.day == other.to.day;

  @override
  int get hashCode =>
      Object.hash(from.year, from.month, from.day, to.year, to.month, to.day);
}

final workerProductionReportProvider =
    FutureProvider.family<WorkerProductionReportData, DateRangeParams>((ref, params) async {
  final repository = ref.watch(productionRepositoryProvider);
  return repository.getWorkerProductionReport(from: params.from, to: params.to);
});

final paymentReportProvider =
    FutureProvider.family<PaymentReportData, DateRangeParams>((ref, params) async {
  final repository = ref.watch(billingRepositoryProvider);
  return repository.getPaymentReport(from: params.from, to: params.to);
});

final customerFinancialSummaryProvider =
    FutureProvider.family<CustomerFinancialSummary, int>((ref, customerId) async {
  final repository = ref.watch(billingRepositoryProvider);
  return repository.getCustomerFinancialSummary(customerId);
});

final customerBillsProvider =
    FutureProvider.family<List<CustomerBill>, int>((ref, customerId) async {
  final repository = ref.watch(billingRepositoryProvider);
  return repository.getBillsForCustomer(customerId);
});

final customerPaymentsProvider =
    FutureProvider.family<List<CustomerPayment>, int>((ref, customerId) async {
  final repository = ref.watch(billingRepositoryProvider);
  return repository.getPaymentsForCustomer(customerId);
});

final customerLedgerEntriesProvider =
    FutureProvider.family<List<LedgerEntry>, int>((ref, customerId) async {
  final repository = ref.watch(billingRepositoryProvider);
  return repository.getLedgerEntriesForCustomer(customerId);
});

final workerWageRepositoryProvider = Provider<WorkerWageRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return WorkerWageRepository(db);
});

final workerWorkEntriesStreamProvider = StreamProvider.family<List<WorkWorkEntryEntity>, int>((ref, workerId) {
  final repository = ref.watch(workerWageRepositoryProvider);
  return repository.watchWorkEntriesForWorker(workerId);
});

final workerWageSummaryProvider = FutureProvider.family<WorkerWageSummary, int>((ref, workerId) async {
  final repository = ref.watch(workerWageRepositoryProvider);
  return repository.getWorkerWageSummary(workerId);
});

final workerCuttingRepositoryProvider = Provider<WorkerCuttingRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return WorkerCuttingRepository(db);
});

final workerCuttingEntriesStreamProvider =
    StreamProvider.family<List<WorkerCuttingEntryWithItem>, int>((ref, workerId) {
  final repository = ref.watch(workerCuttingRepositoryProvider);
  return repository.watchCuttingEntriesForWorker(workerId);
});

final workerTodaysCuttingSummaryProvider =
    FutureProvider.family<WorkerCuttingSummary, int>((ref, workerId) async {
  final repository = ref.watch(workerCuttingRepositoryProvider);
  return repository.getTodaysCuttingSummary(workerId);
});

final readyStockStreamProvider = StreamProvider<List<ItemModel>>((ref) {
  final repository = ref.watch(itemRepositoryProvider);
  return repository.watchReadyStockItems();
});

/// BusinessProfileRepository provider
final businessProfileRepositoryProvider = Provider<BusinessProfileRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BusinessProfileRepository(db);
});

/// Stream of business profile from database for real-time UI updates
final businessProfileProvider = StreamProvider<BusinessProfile>((ref) {
  final repository = ref.watch(businessProfileRepositoryProvider);
  return repository.watchBusinessProfile();
});


