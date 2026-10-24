import 'package:drift/drift.dart';
import '../../core/constants/app_constants.dart';
import '../db/app_database.dart';

class BusinessProfile {
  final String name;
  final String mobile;
  final String address;

  const BusinessProfile({
    required this.name,
    required this.mobile,
    required this.address,
  });

  bool get hasMobile => mobile.trim().isNotEmpty;
  bool get hasAddress => address.trim().isNotEmpty;
  String get initials => name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'M';
}

class BusinessProfileRepository {
  final AppDatabase _db;

  BusinessProfileRepository(this._db);

  static const String keyName = 'business_name';
  static const String keyMobile = 'business_mobile';
  static const String keyAddress = 'business_address';

  /// Get current business profile from database or defaults
  Future<BusinessProfile> getBusinessProfile() async {
    final rows = await (_db.select(_db.settingsTable)
          ..where((t) =>
              t.key.equals(keyName) |
              t.key.equals(keyMobile) |
              t.key.equals(keyAddress)))
        .get();

    String name = AppConstants.shopName;
    String mobile = '';
    String address = '';

    for (final row in rows) {
      if (row.key == keyName && row.value != null && row.value!.trim().isNotEmpty) {
        name = row.value!.trim();
      } else if (row.key == keyMobile && row.value != null) {
        mobile = row.value!.trim();
      } else if (row.key == keyAddress && row.value != null) {
        address = row.value!.trim();
      }
    }

    return BusinessProfile(name: name, mobile: mobile, address: address);
  }

  /// Watch business profile stream for real-time UI updates
  Stream<BusinessProfile> watchBusinessProfile() {
    final query = _db.select(_db.settingsTable)
      ..where((t) =>
          t.key.equals(keyName) |
          t.key.equals(keyMobile) |
          t.key.equals(keyAddress));

    return query.watch().map((rows) {
      String name = AppConstants.shopName;
      String mobile = '';
      String address = '';

      for (final row in rows) {
        if (row.key == keyName && row.value != null && row.value!.trim().isNotEmpty) {
          name = row.value!.trim();
        } else if (row.key == keyMobile && row.value != null) {
          mobile = row.value!.trim();
        } else if (row.key == keyAddress && row.value != null) {
          address = row.value!.trim();
        }
      }

      return BusinessProfile(name: name, mobile: mobile, address: address);
    });
  }

  /// Update business profile in a single transaction
  Future<void> updateBusinessProfile({
    required String name,
    String? mobile,
    String? address,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Shop Name is required.');
    }

    final trimmedMobile = mobile?.trim() ?? '';
    if (trimmedMobile.isNotEmpty && !RegExp(r'^\d{10}$').hasMatch(trimmedMobile)) {
      throw ArgumentError('Please enter a valid 10-digit mobile number.');
    }

    final trimmedAddress = address?.trim() ?? '';

    await _db.transaction(() async {
      await _db.into(_db.settingsTable).insertOnConflictUpdate(
            SettingsTableCompanion.insert(
              key: keyName,
              value: Value(trimmedName),
            ),
          );
      await _db.into(_db.settingsTable).insertOnConflictUpdate(
            SettingsTableCompanion.insert(
              key: keyMobile,
              value: Value(trimmedMobile),
            ),
          );
      await _db.into(_db.settingsTable).insertOnConflictUpdate(
            SettingsTableCompanion.insert(
              key: keyAddress,
              value: Value(trimmedAddress),
            ),
          );
    });
  }
}
