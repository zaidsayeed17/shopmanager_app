import 'package:drift/drift.dart';
import '../db/app_database.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  final AppDatabase _db;

  CustomerRepository(this._db);

  /// Fetch all customers ordered by name
  Future<List<Customer>> getAllCustomers() async {
    final query = _db.select(_db.customers)
      ..orderBy([
        (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)
      ]);
    final entities = await query.get();
    return entities.map(Customer.fromEntity).toList();
  }

  /// Watch all customers in real time
  Stream<List<Customer>> watchAllCustomers() {
    final query = _db.select(_db.customers)
      ..orderBy([
        (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)
      ]);
    return query.watch().map((entities) => entities.map(Customer.fromEntity).toList());
  }

  /// Get single customer by ID
  Future<Customer?> getCustomerById(int id) async {
    final query = _db.select(_db.customers)..where((t) => t.id.equals(id));
    final entity = await query.getSingleOrNull();
    return entity != null ? Customer.fromEntity(entity) : null;
  }

  /// Find an existing customer by exact mobile number (excluding optional customer ID)
  Future<Customer?> findCustomerByMobile(String mobile, {int? excludeId}) async {
    final cleanMobile = mobile.trim();
    if (cleanMobile.isEmpty) return null;
    var query = _db.select(_db.customers)..where((t) => t.mobile.equals(cleanMobile));
    if (excludeId != null) {
      query = query..where((t) => t.id.equals(excludeId).not());
    }
    final entity = await query.getSingleOrNull();
    return entity != null ? Customer.fromEntity(entity) : null;
  }

  /// Check if a customer name already exists (case-insensitive, excluding optional customer ID)
  Future<bool> customerNameExists(String name, {int? excludeId}) async {
    final cleanName = name.trim().toLowerCase();
    if (cleanName.isEmpty) return false;
    var query = _db.select(_db.customers)..where((t) => t.name.lower().equals(cleanName));
    if (excludeId != null) {
      query = query..where((t) => t.id.equals(excludeId).not());
    }
    final list = await query.get();
    return list.isNotEmpty;
  }

  /// Add a new customer
  Future<int> addCustomer({
    required String name,
    required String mobile,
    String? address,
    String? gstin,
    double openingBalance = 0.0,
    String? notes,
    bool isWholesale = false,
    bool isActive = true,
  }) async {
    final companion = CustomersCompanion.insert(
      name: name.trim(),
      mobile: mobile.trim(),
      address: Value(address?.trim().isEmpty == true ? null : address?.trim()),
      gstInfo: Value(gstin?.trim().isEmpty == true ? null : gstin?.trim()),
      openingBalance: Value(openingBalance),
      notes: Value(notes?.trim().isEmpty == true ? null : notes?.trim()),
      isWholesale: Value(isWholesale),
      isActive: Value(isActive),
    );
    return await _db.into(_db.customers).insert(companion);
  }

  /// Update an existing customer
  Future<bool> updateCustomer({
    required int id,
    required String name,
    required String mobile,
    String? address,
    String? gstin,
    double? openingBalance,
    String? notes,
    bool? isWholesale,
    bool? isActive,
  }) async {
    final statement = _db.update(_db.customers)..where((t) => t.id.equals(id));
    final updatedRows = await statement.write(
      CustomersCompanion(
        name: Value(name.trim()),
        mobile: Value(mobile.trim()),
        address: Value(address?.trim().isEmpty == true ? null : address?.trim()),
        gstInfo: Value(gstin?.trim().isEmpty == true ? null : gstin?.trim()),
        openingBalance: openingBalance != null ? Value(openingBalance) : const Value.absent(),
        notes: Value(notes?.trim().isEmpty == true ? null : notes?.trim()),
        isWholesale: isWholesale != null ? Value(isWholesale) : const Value.absent(),
        isActive: isActive != null ? Value(isActive) : const Value.absent(),
      ),
    );
    return updatedRows > 0;
  }

  /// Set customer active/inactive status
  Future<bool> setCustomerActive(int id, bool isActive) async {
    final statement = _db.update(_db.customers)..where((t) => t.id.equals(id));
    final updatedRows = await statement.write(
      CustomersCompanion(
        isActive: Value(isActive),
      ),
    );
    return updatedRows > 0;
  }

  /// Seed initial customers if the customers table is empty (No-op: Demo customer seeding removed)
  Future<void> seedInitialCustomersIfEmpty() async {
    // No-op: Initial demo data seeding has been removed so clean installs start with an empty customer list.
  }
}
