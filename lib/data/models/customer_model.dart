import '../db/app_database.dart';

class Customer {
  final int id;
  final String name;
  final String mobile;
  final String? address;
  final String? gstin;
  final double openingBalance;
  final double outstandingBalance;
  final String? notes;
  final bool isWholesale;
  final bool isActive;
  final DateTime? createdAt;

  const Customer({
    required this.id,
    required this.name,
    required this.mobile,
    this.address,
    this.gstin,
    this.openingBalance = 0.0,
    this.outstandingBalance = 0.0,
    this.notes,
    this.isWholesale = false,
    this.isActive = true,
    this.createdAt,
  });

  String get initials {
    final cleanName = name.replaceAll(RegExp(r'[\(\)\-]'), ' ').trim();
    final parts =
        cleanName.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'CU';
  }

  factory Customer.fromEntity(CustomerEntity entity) {
    return Customer(
      id: entity.id,
      name: entity.name,
      mobile: entity.mobile,
      address: entity.address,
      gstin: entity.gstInfo,
      openingBalance: entity.openingBalance,
      outstandingBalance: entity.openingBalance,
      notes: entity.notes,
      isWholesale: entity.isWholesale,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }

  Customer copyWith({
    int? id,
    String? name,
    String? mobile,
    String? address,
    String? gstin,
    double? openingBalance,
    double? outstandingBalance,
    String? notes,
    bool? isWholesale,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      gstin: gstin ?? this.gstin,
      openingBalance: openingBalance ?? this.openingBalance,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      notes: notes ?? this.notes,
      isWholesale: isWholesale ?? this.isWholesale,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
