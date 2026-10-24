// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, CustomerEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mobileMeta = const VerificationMeta('mobile');
  @override
  late final GeneratedColumn<String> mobile = GeneratedColumn<String>(
    'mobile',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gstInfoMeta = const VerificationMeta(
    'gstInfo',
  );
  @override
  late final GeneratedColumn<String> gstInfo = GeneratedColumn<String>(
    'gst_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openingBalanceMeta = const VerificationMeta(
    'openingBalance',
  );
  @override
  late final GeneratedColumn<double> openingBalance = GeneratedColumn<double>(
    'opening_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isWholesaleMeta = const VerificationMeta(
    'isWholesale',
  );
  @override
  late final GeneratedColumn<bool> isWholesale = GeneratedColumn<bool>(
    'is_wholesale',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_wholesale" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    mobile,
    address,
    gstInfo,
    openingBalance,
    notes,
    isWholesale,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('mobile')) {
      context.handle(
        _mobileMeta,
        mobile.isAcceptableOrUnknown(data['mobile']!, _mobileMeta),
      );
    } else if (isInserting) {
      context.missing(_mobileMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('gst_info')) {
      context.handle(
        _gstInfoMeta,
        gstInfo.isAcceptableOrUnknown(data['gst_info']!, _gstInfoMeta),
      );
    }
    if (data.containsKey('opening_balance')) {
      context.handle(
        _openingBalanceMeta,
        openingBalance.isAcceptableOrUnknown(
          data['opening_balance']!,
          _openingBalanceMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_wholesale')) {
      context.handle(
        _isWholesaleMeta,
        isWholesale.isAcceptableOrUnknown(
          data['is_wholesale']!,
          _isWholesaleMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      mobile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      gstInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gst_info'],
      ),
      openingBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}opening_balance'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isWholesale: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_wholesale'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class CustomerEntity extends DataClass implements Insertable<CustomerEntity> {
  final int id;
  final String name;
  final String mobile;
  final String? address;
  final String? gstInfo;
  final double openingBalance;
  final String? notes;
  final bool isWholesale;
  final bool isActive;
  final DateTime createdAt;
  const CustomerEntity({
    required this.id,
    required this.name,
    required this.mobile,
    this.address,
    this.gstInfo,
    required this.openingBalance,
    this.notes,
    required this.isWholesale,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['mobile'] = Variable<String>(mobile);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || gstInfo != null) {
      map['gst_info'] = Variable<String>(gstInfo);
    }
    map['opening_balance'] = Variable<double>(openingBalance);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_wholesale'] = Variable<bool>(isWholesale);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      name: Value(name),
      mobile: Value(mobile),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      gstInfo: gstInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(gstInfo),
      openingBalance: Value(openingBalance),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isWholesale: Value(isWholesale),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory CustomerEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerEntity(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      mobile: serializer.fromJson<String>(json['mobile']),
      address: serializer.fromJson<String?>(json['address']),
      gstInfo: serializer.fromJson<String?>(json['gstInfo']),
      openingBalance: serializer.fromJson<double>(json['openingBalance']),
      notes: serializer.fromJson<String?>(json['notes']),
      isWholesale: serializer.fromJson<bool>(json['isWholesale']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'mobile': serializer.toJson<String>(mobile),
      'address': serializer.toJson<String?>(address),
      'gstInfo': serializer.toJson<String?>(gstInfo),
      'openingBalance': serializer.toJson<double>(openingBalance),
      'notes': serializer.toJson<String?>(notes),
      'isWholesale': serializer.toJson<bool>(isWholesale),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CustomerEntity copyWith({
    int? id,
    String? name,
    String? mobile,
    Value<String?> address = const Value.absent(),
    Value<String?> gstInfo = const Value.absent(),
    double? openingBalance,
    Value<String?> notes = const Value.absent(),
    bool? isWholesale,
    bool? isActive,
    DateTime? createdAt,
  }) => CustomerEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    mobile: mobile ?? this.mobile,
    address: address.present ? address.value : this.address,
    gstInfo: gstInfo.present ? gstInfo.value : this.gstInfo,
    openingBalance: openingBalance ?? this.openingBalance,
    notes: notes.present ? notes.value : this.notes,
    isWholesale: isWholesale ?? this.isWholesale,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  CustomerEntity copyWithCompanion(CustomersCompanion data) {
    return CustomerEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      mobile: data.mobile.present ? data.mobile.value : this.mobile,
      address: data.address.present ? data.address.value : this.address,
      gstInfo: data.gstInfo.present ? data.gstInfo.value : this.gstInfo,
      openingBalance: data.openingBalance.present
          ? data.openingBalance.value
          : this.openingBalance,
      notes: data.notes.present ? data.notes.value : this.notes,
      isWholesale: data.isWholesale.present
          ? data.isWholesale.value
          : this.isWholesale,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerEntity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('mobile: $mobile, ')
          ..write('address: $address, ')
          ..write('gstInfo: $gstInfo, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('notes: $notes, ')
          ..write('isWholesale: $isWholesale, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    mobile,
    address,
    gstInfo,
    openingBalance,
    notes,
    isWholesale,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerEntity &&
          other.id == this.id &&
          other.name == this.name &&
          other.mobile == this.mobile &&
          other.address == this.address &&
          other.gstInfo == this.gstInfo &&
          other.openingBalance == this.openingBalance &&
          other.notes == this.notes &&
          other.isWholesale == this.isWholesale &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class CustomersCompanion extends UpdateCompanion<CustomerEntity> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> mobile;
  final Value<String?> address;
  final Value<String?> gstInfo;
  final Value<double> openingBalance;
  final Value<String?> notes;
  final Value<bool> isWholesale;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.mobile = const Value.absent(),
    this.address = const Value.absent(),
    this.gstInfo = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.notes = const Value.absent(),
    this.isWholesale = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CustomersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String mobile,
    this.address = const Value.absent(),
    this.gstInfo = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.notes = const Value.absent(),
    this.isWholesale = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       mobile = Value(mobile);
  static Insertable<CustomerEntity> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? mobile,
    Expression<String>? address,
    Expression<String>? gstInfo,
    Expression<double>? openingBalance,
    Expression<String>? notes,
    Expression<bool>? isWholesale,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (mobile != null) 'mobile': mobile,
      if (address != null) 'address': address,
      if (gstInfo != null) 'gst_info': gstInfo,
      if (openingBalance != null) 'opening_balance': openingBalance,
      if (notes != null) 'notes': notes,
      if (isWholesale != null) 'is_wholesale': isWholesale,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CustomersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? mobile,
    Value<String?>? address,
    Value<String?>? gstInfo,
    Value<double>? openingBalance,
    Value<String?>? notes,
    Value<bool>? isWholesale,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      gstInfo: gstInfo ?? this.gstInfo,
      openingBalance: openingBalance ?? this.openingBalance,
      notes: notes ?? this.notes,
      isWholesale: isWholesale ?? this.isWholesale,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (mobile.present) {
      map['mobile'] = Variable<String>(mobile.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (gstInfo.present) {
      map['gst_info'] = Variable<String>(gstInfo.value);
    }
    if (openingBalance.present) {
      map['opening_balance'] = Variable<double>(openingBalance.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isWholesale.present) {
      map['is_wholesale'] = Variable<bool>(isWholesale.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('mobile: $mobile, ')
          ..write('address: $address, ')
          ..write('gstInfo: $gstInfo, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('notes: $notes, ')
          ..write('isWholesale: $isWholesale, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ItemsTable extends Items with TableInfo<$ItemsTable, ItemEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchaseRateMeta = const VerificationMeta(
    'purchaseRate',
  );
  @override
  late final GeneratedColumn<double> purchaseRate = GeneratedColumn<double>(
    'purchase_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _sellingRateMeta = const VerificationMeta(
    'sellingRate',
  );
  @override
  late final GeneratedColumn<double> sellingRate = GeneratedColumn<double>(
    'selling_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _wholesaleRateMeta = const VerificationMeta(
    'wholesaleRate',
  );
  @override
  late final GeneratedColumn<double> wholesaleRate = GeneratedColumn<double>(
    'wholesale_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openingQtyMeta = const VerificationMeta(
    'openingQty',
  );
  @override
  late final GeneratedColumn<double> openingQty = GeneratedColumn<double>(
    'opening_qty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _currentQtyMeta = const VerificationMeta(
    'currentQty',
  );
  @override
  late final GeneratedColumn<double> currentQty = GeneratedColumn<double>(
    'current_qty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _minStockLevelMeta = const VerificationMeta(
    'minStockLevel',
  );
  @override
  late final GeneratedColumn<double> minStockLevel = GeneratedColumn<double>(
    'min_stock_level',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _supplierInfoMeta = const VerificationMeta(
    'supplierInfo',
  );
  @override
  late final GeneratedColumn<String> supplierInfo = GeneratedColumn<String>(
    'supplier_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    sku,
    type,
    unit,
    purchaseRate,
    sellingRate,
    wholesaleRate,
    openingQty,
    currentQty,
    minStockLevel,
    supplierInfo,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('purchase_rate')) {
      context.handle(
        _purchaseRateMeta,
        purchaseRate.isAcceptableOrUnknown(
          data['purchase_rate']!,
          _purchaseRateMeta,
        ),
      );
    }
    if (data.containsKey('selling_rate')) {
      context.handle(
        _sellingRateMeta,
        sellingRate.isAcceptableOrUnknown(
          data['selling_rate']!,
          _sellingRateMeta,
        ),
      );
    }
    if (data.containsKey('wholesale_rate')) {
      context.handle(
        _wholesaleRateMeta,
        wholesaleRate.isAcceptableOrUnknown(
          data['wholesale_rate']!,
          _wholesaleRateMeta,
        ),
      );
    }
    if (data.containsKey('opening_qty')) {
      context.handle(
        _openingQtyMeta,
        openingQty.isAcceptableOrUnknown(data['opening_qty']!, _openingQtyMeta),
      );
    }
    if (data.containsKey('current_qty')) {
      context.handle(
        _currentQtyMeta,
        currentQty.isAcceptableOrUnknown(data['current_qty']!, _currentQtyMeta),
      );
    }
    if (data.containsKey('min_stock_level')) {
      context.handle(
        _minStockLevelMeta,
        minStockLevel.isAcceptableOrUnknown(
          data['min_stock_level']!,
          _minStockLevelMeta,
        ),
      );
    }
    if (data.containsKey('supplier_info')) {
      context.handle(
        _supplierInfoMeta,
        supplierInfo.isAcceptableOrUnknown(
          data['supplier_info']!,
          _supplierInfoMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      purchaseRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_rate'],
      )!,
      sellingRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}selling_rate'],
      )!,
      wholesaleRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}wholesale_rate'],
      ),
      openingQty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}opening_qty'],
      )!,
      currentQty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_qty'],
      )!,
      minStockLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_stock_level'],
      )!,
      supplierInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_info'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class ItemEntity extends DataClass implements Insertable<ItemEntity> {
  final int id;
  final String name;
  final String? category;
  final String? sku;
  final String type;
  final String unit;
  final double purchaseRate;
  final double sellingRate;
  final double? wholesaleRate;
  final double openingQty;
  final double currentQty;
  final double minStockLevel;
  final String? supplierInfo;
  final bool isActive;
  final DateTime createdAt;
  const ItemEntity({
    required this.id,
    required this.name,
    this.category,
    this.sku,
    required this.type,
    required this.unit,
    required this.purchaseRate,
    required this.sellingRate,
    this.wholesaleRate,
    required this.openingQty,
    required this.currentQty,
    required this.minStockLevel,
    this.supplierInfo,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
    }
    map['type'] = Variable<String>(type);
    map['unit'] = Variable<String>(unit);
    map['purchase_rate'] = Variable<double>(purchaseRate);
    map['selling_rate'] = Variable<double>(sellingRate);
    if (!nullToAbsent || wholesaleRate != null) {
      map['wholesale_rate'] = Variable<double>(wholesaleRate);
    }
    map['opening_qty'] = Variable<double>(openingQty);
    map['current_qty'] = Variable<double>(currentQty);
    map['min_stock_level'] = Variable<double>(minStockLevel);
    if (!nullToAbsent || supplierInfo != null) {
      map['supplier_info'] = Variable<String>(supplierInfo);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      name: Value(name),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
      type: Value(type),
      unit: Value(unit),
      purchaseRate: Value(purchaseRate),
      sellingRate: Value(sellingRate),
      wholesaleRate: wholesaleRate == null && nullToAbsent
          ? const Value.absent()
          : Value(wholesaleRate),
      openingQty: Value(openingQty),
      currentQty: Value(currentQty),
      minStockLevel: Value(minStockLevel),
      supplierInfo: supplierInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierInfo),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory ItemEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemEntity(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String?>(json['category']),
      sku: serializer.fromJson<String?>(json['sku']),
      type: serializer.fromJson<String>(json['type']),
      unit: serializer.fromJson<String>(json['unit']),
      purchaseRate: serializer.fromJson<double>(json['purchaseRate']),
      sellingRate: serializer.fromJson<double>(json['sellingRate']),
      wholesaleRate: serializer.fromJson<double?>(json['wholesaleRate']),
      openingQty: serializer.fromJson<double>(json['openingQty']),
      currentQty: serializer.fromJson<double>(json['currentQty']),
      minStockLevel: serializer.fromJson<double>(json['minStockLevel']),
      supplierInfo: serializer.fromJson<String?>(json['supplierInfo']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String?>(category),
      'sku': serializer.toJson<String?>(sku),
      'type': serializer.toJson<String>(type),
      'unit': serializer.toJson<String>(unit),
      'purchaseRate': serializer.toJson<double>(purchaseRate),
      'sellingRate': serializer.toJson<double>(sellingRate),
      'wholesaleRate': serializer.toJson<double?>(wholesaleRate),
      'openingQty': serializer.toJson<double>(openingQty),
      'currentQty': serializer.toJson<double>(currentQty),
      'minStockLevel': serializer.toJson<double>(minStockLevel),
      'supplierInfo': serializer.toJson<String?>(supplierInfo),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ItemEntity copyWith({
    int? id,
    String? name,
    Value<String?> category = const Value.absent(),
    Value<String?> sku = const Value.absent(),
    String? type,
    String? unit,
    double? purchaseRate,
    double? sellingRate,
    Value<double?> wholesaleRate = const Value.absent(),
    double? openingQty,
    double? currentQty,
    double? minStockLevel,
    Value<String?> supplierInfo = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
  }) => ItemEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category.present ? category.value : this.category,
    sku: sku.present ? sku.value : this.sku,
    type: type ?? this.type,
    unit: unit ?? this.unit,
    purchaseRate: purchaseRate ?? this.purchaseRate,
    sellingRate: sellingRate ?? this.sellingRate,
    wholesaleRate: wholesaleRate.present
        ? wholesaleRate.value
        : this.wholesaleRate,
    openingQty: openingQty ?? this.openingQty,
    currentQty: currentQty ?? this.currentQty,
    minStockLevel: minStockLevel ?? this.minStockLevel,
    supplierInfo: supplierInfo.present ? supplierInfo.value : this.supplierInfo,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  ItemEntity copyWithCompanion(ItemsCompanion data) {
    return ItemEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      sku: data.sku.present ? data.sku.value : this.sku,
      type: data.type.present ? data.type.value : this.type,
      unit: data.unit.present ? data.unit.value : this.unit,
      purchaseRate: data.purchaseRate.present
          ? data.purchaseRate.value
          : this.purchaseRate,
      sellingRate: data.sellingRate.present
          ? data.sellingRate.value
          : this.sellingRate,
      wholesaleRate: data.wholesaleRate.present
          ? data.wholesaleRate.value
          : this.wholesaleRate,
      openingQty: data.openingQty.present
          ? data.openingQty.value
          : this.openingQty,
      currentQty: data.currentQty.present
          ? data.currentQty.value
          : this.currentQty,
      minStockLevel: data.minStockLevel.present
          ? data.minStockLevel.value
          : this.minStockLevel,
      supplierInfo: data.supplierInfo.present
          ? data.supplierInfo.value
          : this.supplierInfo,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemEntity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('sku: $sku, ')
          ..write('type: $type, ')
          ..write('unit: $unit, ')
          ..write('purchaseRate: $purchaseRate, ')
          ..write('sellingRate: $sellingRate, ')
          ..write('wholesaleRate: $wholesaleRate, ')
          ..write('openingQty: $openingQty, ')
          ..write('currentQty: $currentQty, ')
          ..write('minStockLevel: $minStockLevel, ')
          ..write('supplierInfo: $supplierInfo, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    sku,
    type,
    unit,
    purchaseRate,
    sellingRate,
    wholesaleRate,
    openingQty,
    currentQty,
    minStockLevel,
    supplierInfo,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemEntity &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.sku == this.sku &&
          other.type == this.type &&
          other.unit == this.unit &&
          other.purchaseRate == this.purchaseRate &&
          other.sellingRate == this.sellingRate &&
          other.wholesaleRate == this.wholesaleRate &&
          other.openingQty == this.openingQty &&
          other.currentQty == this.currentQty &&
          other.minStockLevel == this.minStockLevel &&
          other.supplierInfo == this.supplierInfo &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class ItemsCompanion extends UpdateCompanion<ItemEntity> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> category;
  final Value<String?> sku;
  final Value<String> type;
  final Value<String> unit;
  final Value<double> purchaseRate;
  final Value<double> sellingRate;
  final Value<double?> wholesaleRate;
  final Value<double> openingQty;
  final Value<double> currentQty;
  final Value<double> minStockLevel;
  final Value<String?> supplierInfo;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.sku = const Value.absent(),
    this.type = const Value.absent(),
    this.unit = const Value.absent(),
    this.purchaseRate = const Value.absent(),
    this.sellingRate = const Value.absent(),
    this.wholesaleRate = const Value.absent(),
    this.openingQty = const Value.absent(),
    this.currentQty = const Value.absent(),
    this.minStockLevel = const Value.absent(),
    this.supplierInfo = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ItemsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.category = const Value.absent(),
    this.sku = const Value.absent(),
    required String type,
    required String unit,
    this.purchaseRate = const Value.absent(),
    this.sellingRate = const Value.absent(),
    this.wholesaleRate = const Value.absent(),
    this.openingQty = const Value.absent(),
    this.currentQty = const Value.absent(),
    this.minStockLevel = const Value.absent(),
    this.supplierInfo = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       type = Value(type),
       unit = Value(unit);
  static Insertable<ItemEntity> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? sku,
    Expression<String>? type,
    Expression<String>? unit,
    Expression<double>? purchaseRate,
    Expression<double>? sellingRate,
    Expression<double>? wholesaleRate,
    Expression<double>? openingQty,
    Expression<double>? currentQty,
    Expression<double>? minStockLevel,
    Expression<String>? supplierInfo,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (sku != null) 'sku': sku,
      if (type != null) 'type': type,
      if (unit != null) 'unit': unit,
      if (purchaseRate != null) 'purchase_rate': purchaseRate,
      if (sellingRate != null) 'selling_rate': sellingRate,
      if (wholesaleRate != null) 'wholesale_rate': wholesaleRate,
      if (openingQty != null) 'opening_qty': openingQty,
      if (currentQty != null) 'current_qty': currentQty,
      if (minStockLevel != null) 'min_stock_level': minStockLevel,
      if (supplierInfo != null) 'supplier_info': supplierInfo,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? category,
    Value<String?>? sku,
    Value<String>? type,
    Value<String>? unit,
    Value<double>? purchaseRate,
    Value<double>? sellingRate,
    Value<double?>? wholesaleRate,
    Value<double>? openingQty,
    Value<double>? currentQty,
    Value<double>? minStockLevel,
    Value<String?>? supplierInfo,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      sku: sku ?? this.sku,
      type: type ?? this.type,
      unit: unit ?? this.unit,
      purchaseRate: purchaseRate ?? this.purchaseRate,
      sellingRate: sellingRate ?? this.sellingRate,
      wholesaleRate: wholesaleRate ?? this.wholesaleRate,
      openingQty: openingQty ?? this.openingQty,
      currentQty: currentQty ?? this.currentQty,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      supplierInfo: supplierInfo ?? this.supplierInfo,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (purchaseRate.present) {
      map['purchase_rate'] = Variable<double>(purchaseRate.value);
    }
    if (sellingRate.present) {
      map['selling_rate'] = Variable<double>(sellingRate.value);
    }
    if (wholesaleRate.present) {
      map['wholesale_rate'] = Variable<double>(wholesaleRate.value);
    }
    if (openingQty.present) {
      map['opening_qty'] = Variable<double>(openingQty.value);
    }
    if (currentQty.present) {
      map['current_qty'] = Variable<double>(currentQty.value);
    }
    if (minStockLevel.present) {
      map['min_stock_level'] = Variable<double>(minStockLevel.value);
    }
    if (supplierInfo.present) {
      map['supplier_info'] = Variable<String>(supplierInfo.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('sku: $sku, ')
          ..write('type: $type, ')
          ..write('unit: $unit, ')
          ..write('purchaseRate: $purchaseRate, ')
          ..write('sellingRate: $sellingRate, ')
          ..write('wholesaleRate: $wholesaleRate, ')
          ..write('openingQty: $openingQty, ')
          ..write('currentQty: $currentQty, ')
          ..write('minStockLevel: $minStockLevel, ')
          ..write('supplierInfo: $supplierInfo, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $StockTransactionsTable extends StockTransactions
    with TableInfo<$StockTransactionsTable, StockTransactionEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitRateMeta = const VerificationMeta(
    'unitRate',
  );
  @override
  late final GeneratedColumn<double> unitRate = GeneratedColumn<double>(
    'unit_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceTypeMeta = const VerificationMeta(
    'referenceType',
  );
  @override
  late final GeneratedColumn<String> referenceType = GeneratedColumn<String>(
    'reference_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceIdMeta = const VerificationMeta(
    'referenceId',
  );
  @override
  late final GeneratedColumn<int> referenceId = GeneratedColumn<int>(
    'reference_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    type,
    quantity,
    unitRate,
    referenceType,
    referenceId,
    date,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockTransactionEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_rate')) {
      context.handle(
        _unitRateMeta,
        unitRate.isAcceptableOrUnknown(data['unit_rate']!, _unitRateMeta),
      );
    }
    if (data.containsKey('reference_type')) {
      context.handle(
        _referenceTypeMeta,
        referenceType.isAcceptableOrUnknown(
          data['reference_type']!,
          _referenceTypeMeta,
        ),
      );
    }
    if (data.containsKey('reference_id')) {
      context.handle(
        _referenceIdMeta,
        referenceId.isAcceptableOrUnknown(
          data['reference_id']!,
          _referenceIdMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockTransactionEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockTransactionEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unitRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_rate'],
      ),
      referenceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_type'],
      ),
      referenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reference_id'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StockTransactionsTable createAlias(String alias) {
    return $StockTransactionsTable(attachedDatabase, alias);
  }
}

class StockTransactionEntity extends DataClass
    implements Insertable<StockTransactionEntity> {
  final int id;
  final int itemId;
  final String type;
  final double quantity;
  final double? unitRate;
  final String? referenceType;
  final int? referenceId;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
  const StockTransactionEntity({
    required this.id,
    required this.itemId,
    required this.type,
    required this.quantity,
    this.unitRate,
    this.referenceType,
    this.referenceId,
    required this.date,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['item_id'] = Variable<int>(itemId);
    map['type'] = Variable<String>(type);
    map['quantity'] = Variable<double>(quantity);
    if (!nullToAbsent || unitRate != null) {
      map['unit_rate'] = Variable<double>(unitRate);
    }
    if (!nullToAbsent || referenceType != null) {
      map['reference_type'] = Variable<String>(referenceType);
    }
    if (!nullToAbsent || referenceId != null) {
      map['reference_id'] = Variable<int>(referenceId);
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StockTransactionsCompanion toCompanion(bool nullToAbsent) {
    return StockTransactionsCompanion(
      id: Value(id),
      itemId: Value(itemId),
      type: Value(type),
      quantity: Value(quantity),
      unitRate: unitRate == null && nullToAbsent
          ? const Value.absent()
          : Value(unitRate),
      referenceType: referenceType == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceType),
      referenceId: referenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceId),
      date: Value(date),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory StockTransactionEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockTransactionEntity(
      id: serializer.fromJson<int>(json['id']),
      itemId: serializer.fromJson<int>(json['itemId']),
      type: serializer.fromJson<String>(json['type']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unitRate: serializer.fromJson<double?>(json['unitRate']),
      referenceType: serializer.fromJson<String?>(json['referenceType']),
      referenceId: serializer.fromJson<int?>(json['referenceId']),
      date: serializer.fromJson<DateTime>(json['date']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'itemId': serializer.toJson<int>(itemId),
      'type': serializer.toJson<String>(type),
      'quantity': serializer.toJson<double>(quantity),
      'unitRate': serializer.toJson<double?>(unitRate),
      'referenceType': serializer.toJson<String?>(referenceType),
      'referenceId': serializer.toJson<int?>(referenceId),
      'date': serializer.toJson<DateTime>(date),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StockTransactionEntity copyWith({
    int? id,
    int? itemId,
    String? type,
    double? quantity,
    Value<double?> unitRate = const Value.absent(),
    Value<String?> referenceType = const Value.absent(),
    Value<int?> referenceId = const Value.absent(),
    DateTime? date,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => StockTransactionEntity(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    type: type ?? this.type,
    quantity: quantity ?? this.quantity,
    unitRate: unitRate.present ? unitRate.value : this.unitRate,
    referenceType: referenceType.present
        ? referenceType.value
        : this.referenceType,
    referenceId: referenceId.present ? referenceId.value : this.referenceId,
    date: date ?? this.date,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  StockTransactionEntity copyWithCompanion(StockTransactionsCompanion data) {
    return StockTransactionEntity(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      type: data.type.present ? data.type.value : this.type,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitRate: data.unitRate.present ? data.unitRate.value : this.unitRate,
      referenceType: data.referenceType.present
          ? data.referenceType.value
          : this.referenceType,
      referenceId: data.referenceId.present
          ? data.referenceId.value
          : this.referenceId,
      date: data.date.present ? data.date.value : this.date,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockTransactionEntity(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('type: $type, ')
          ..write('quantity: $quantity, ')
          ..write('unitRate: $unitRate, ')
          ..write('referenceType: $referenceType, ')
          ..write('referenceId: $referenceId, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemId,
    type,
    quantity,
    unitRate,
    referenceType,
    referenceId,
    date,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockTransactionEntity &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.type == this.type &&
          other.quantity == this.quantity &&
          other.unitRate == this.unitRate &&
          other.referenceType == this.referenceType &&
          other.referenceId == this.referenceId &&
          other.date == this.date &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class StockTransactionsCompanion
    extends UpdateCompanion<StockTransactionEntity> {
  final Value<int> id;
  final Value<int> itemId;
  final Value<String> type;
  final Value<double> quantity;
  final Value<double?> unitRate;
  final Value<String?> referenceType;
  final Value<int?> referenceId;
  final Value<DateTime> date;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const StockTransactionsCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.type = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitRate = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  StockTransactionsCompanion.insert({
    this.id = const Value.absent(),
    required int itemId,
    required String type,
    required double quantity,
    this.unitRate = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.referenceId = const Value.absent(),
    required DateTime date,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : itemId = Value(itemId),
       type = Value(type),
       quantity = Value(quantity),
       date = Value(date);
  static Insertable<StockTransactionEntity> custom({
    Expression<int>? id,
    Expression<int>? itemId,
    Expression<String>? type,
    Expression<double>? quantity,
    Expression<double>? unitRate,
    Expression<String>? referenceType,
    Expression<int>? referenceId,
    Expression<DateTime>? date,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (type != null) 'type': type,
      if (quantity != null) 'quantity': quantity,
      if (unitRate != null) 'unit_rate': unitRate,
      if (referenceType != null) 'reference_type': referenceType,
      if (referenceId != null) 'reference_id': referenceId,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  StockTransactionsCompanion copyWith({
    Value<int>? id,
    Value<int>? itemId,
    Value<String>? type,
    Value<double>? quantity,
    Value<double?>? unitRate,
    Value<String?>? referenceType,
    Value<int?>? referenceId,
    Value<DateTime>? date,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return StockTransactionsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      unitRate: unitRate ?? this.unitRate,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unitRate.present) {
      map['unit_rate'] = Variable<double>(unitRate.value);
    }
    if (referenceType.present) {
      map['reference_type'] = Variable<String>(referenceType.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<int>(referenceId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('type: $type, ')
          ..write('quantity: $quantity, ')
          ..write('unitRate: $unitRate, ')
          ..write('referenceType: $referenceType, ')
          ..write('referenceId: $referenceId, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WorkersTable extends Workers
    with TableInfo<$WorkersTable, WorkerEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mobileMeta = const VerificationMeta('mobile');
  @override
  late final GeneratedColumn<String> mobile = GeneratedColumn<String>(
    'mobile',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workTypeMeta = const VerificationMeta(
    'workType',
  );
  @override
  late final GeneratedColumn<String> workType = GeneratedColumn<String>(
    'work_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _joiningDateMeta = const VerificationMeta(
    'joiningDate',
  );
  @override
  late final GeneratedColumn<DateTime> joiningDate = GeneratedColumn<DateTime>(
    'joining_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentTypeMeta = const VerificationMeta(
    'paymentType',
  );
  @override
  late final GeneratedColumn<String> paymentType = GeneratedColumn<String>(
    'payment_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultHourRateMeta = const VerificationMeta(
    'defaultHourRate',
  );
  @override
  late final GeneratedColumn<double> defaultHourRate = GeneratedColumn<double>(
    'default_hour_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultNagRateMeta = const VerificationMeta(
    'defaultNagRate',
  );
  @override
  late final GeneratedColumn<double> defaultNagRate = GeneratedColumn<double>(
    'default_nag_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    mobile,
    address,
    workType,
    isActive,
    notes,
    joiningDate,
    paymentType,
    defaultHourRate,
    defaultNagRate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workers';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkerEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('mobile')) {
      context.handle(
        _mobileMeta,
        mobile.isAcceptableOrUnknown(data['mobile']!, _mobileMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('work_type')) {
      context.handle(
        _workTypeMeta,
        workType.isAcceptableOrUnknown(data['work_type']!, _workTypeMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('joining_date')) {
      context.handle(
        _joiningDateMeta,
        joiningDate.isAcceptableOrUnknown(
          data['joining_date']!,
          _joiningDateMeta,
        ),
      );
    }
    if (data.containsKey('payment_type')) {
      context.handle(
        _paymentTypeMeta,
        paymentType.isAcceptableOrUnknown(
          data['payment_type']!,
          _paymentTypeMeta,
        ),
      );
    }
    if (data.containsKey('default_hour_rate')) {
      context.handle(
        _defaultHourRateMeta,
        defaultHourRate.isAcceptableOrUnknown(
          data['default_hour_rate']!,
          _defaultHourRateMeta,
        ),
      );
    }
    if (data.containsKey('default_nag_rate')) {
      context.handle(
        _defaultNagRateMeta,
        defaultNagRate.isAcceptableOrUnknown(
          data['default_nag_rate']!,
          _defaultNagRateMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkerEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkerEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      mobile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      workType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_type'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      joiningDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joining_date'],
      ),
      paymentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_type'],
      ),
      defaultHourRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_hour_rate'],
      ),
      defaultNagRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_nag_rate'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WorkersTable createAlias(String alias) {
    return $WorkersTable(attachedDatabase, alias);
  }
}

class WorkerEntity extends DataClass implements Insertable<WorkerEntity> {
  final int id;
  final String name;
  final String? mobile;
  final String? address;
  final String? workType;
  final bool isActive;
  final String? notes;
  final DateTime? joiningDate;
  final String? paymentType;
  final double? defaultHourRate;
  final double? defaultNagRate;
  final DateTime createdAt;
  const WorkerEntity({
    required this.id,
    required this.name,
    this.mobile,
    this.address,
    this.workType,
    required this.isActive,
    this.notes,
    this.joiningDate,
    this.paymentType,
    this.defaultHourRate,
    this.defaultNagRate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || mobile != null) {
      map['mobile'] = Variable<String>(mobile);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || workType != null) {
      map['work_type'] = Variable<String>(workType);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || joiningDate != null) {
      map['joining_date'] = Variable<DateTime>(joiningDate);
    }
    if (!nullToAbsent || paymentType != null) {
      map['payment_type'] = Variable<String>(paymentType);
    }
    if (!nullToAbsent || defaultHourRate != null) {
      map['default_hour_rate'] = Variable<double>(defaultHourRate);
    }
    if (!nullToAbsent || defaultNagRate != null) {
      map['default_nag_rate'] = Variable<double>(defaultNagRate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WorkersCompanion toCompanion(bool nullToAbsent) {
    return WorkersCompanion(
      id: Value(id),
      name: Value(name),
      mobile: mobile == null && nullToAbsent
          ? const Value.absent()
          : Value(mobile),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      workType: workType == null && nullToAbsent
          ? const Value.absent()
          : Value(workType),
      isActive: Value(isActive),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      joiningDate: joiningDate == null && nullToAbsent
          ? const Value.absent()
          : Value(joiningDate),
      paymentType: paymentType == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentType),
      defaultHourRate: defaultHourRate == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultHourRate),
      defaultNagRate: defaultNagRate == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultNagRate),
      createdAt: Value(createdAt),
    );
  }

  factory WorkerEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkerEntity(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      mobile: serializer.fromJson<String?>(json['mobile']),
      address: serializer.fromJson<String?>(json['address']),
      workType: serializer.fromJson<String?>(json['workType']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      notes: serializer.fromJson<String?>(json['notes']),
      joiningDate: serializer.fromJson<DateTime?>(json['joiningDate']),
      paymentType: serializer.fromJson<String?>(json['paymentType']),
      defaultHourRate: serializer.fromJson<double?>(json['defaultHourRate']),
      defaultNagRate: serializer.fromJson<double?>(json['defaultNagRate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'mobile': serializer.toJson<String?>(mobile),
      'address': serializer.toJson<String?>(address),
      'workType': serializer.toJson<String?>(workType),
      'isActive': serializer.toJson<bool>(isActive),
      'notes': serializer.toJson<String?>(notes),
      'joiningDate': serializer.toJson<DateTime?>(joiningDate),
      'paymentType': serializer.toJson<String?>(paymentType),
      'defaultHourRate': serializer.toJson<double?>(defaultHourRate),
      'defaultNagRate': serializer.toJson<double?>(defaultNagRate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WorkerEntity copyWith({
    int? id,
    String? name,
    Value<String?> mobile = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> workType = const Value.absent(),
    bool? isActive,
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> joiningDate = const Value.absent(),
    Value<String?> paymentType = const Value.absent(),
    Value<double?> defaultHourRate = const Value.absent(),
    Value<double?> defaultNagRate = const Value.absent(),
    DateTime? createdAt,
  }) => WorkerEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    mobile: mobile.present ? mobile.value : this.mobile,
    address: address.present ? address.value : this.address,
    workType: workType.present ? workType.value : this.workType,
    isActive: isActive ?? this.isActive,
    notes: notes.present ? notes.value : this.notes,
    joiningDate: joiningDate.present ? joiningDate.value : this.joiningDate,
    paymentType: paymentType.present ? paymentType.value : this.paymentType,
    defaultHourRate: defaultHourRate.present
        ? defaultHourRate.value
        : this.defaultHourRate,
    defaultNagRate: defaultNagRate.present
        ? defaultNagRate.value
        : this.defaultNagRate,
    createdAt: createdAt ?? this.createdAt,
  );
  WorkerEntity copyWithCompanion(WorkersCompanion data) {
    return WorkerEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      mobile: data.mobile.present ? data.mobile.value : this.mobile,
      address: data.address.present ? data.address.value : this.address,
      workType: data.workType.present ? data.workType.value : this.workType,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      notes: data.notes.present ? data.notes.value : this.notes,
      joiningDate: data.joiningDate.present
          ? data.joiningDate.value
          : this.joiningDate,
      paymentType: data.paymentType.present
          ? data.paymentType.value
          : this.paymentType,
      defaultHourRate: data.defaultHourRate.present
          ? data.defaultHourRate.value
          : this.defaultHourRate,
      defaultNagRate: data.defaultNagRate.present
          ? data.defaultNagRate.value
          : this.defaultNagRate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkerEntity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('mobile: $mobile, ')
          ..write('address: $address, ')
          ..write('workType: $workType, ')
          ..write('isActive: $isActive, ')
          ..write('notes: $notes, ')
          ..write('joiningDate: $joiningDate, ')
          ..write('paymentType: $paymentType, ')
          ..write('defaultHourRate: $defaultHourRate, ')
          ..write('defaultNagRate: $defaultNagRate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    mobile,
    address,
    workType,
    isActive,
    notes,
    joiningDate,
    paymentType,
    defaultHourRate,
    defaultNagRate,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkerEntity &&
          other.id == this.id &&
          other.name == this.name &&
          other.mobile == this.mobile &&
          other.address == this.address &&
          other.workType == this.workType &&
          other.isActive == this.isActive &&
          other.notes == this.notes &&
          other.joiningDate == this.joiningDate &&
          other.paymentType == this.paymentType &&
          other.defaultHourRate == this.defaultHourRate &&
          other.defaultNagRate == this.defaultNagRate &&
          other.createdAt == this.createdAt);
}

class WorkersCompanion extends UpdateCompanion<WorkerEntity> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> mobile;
  final Value<String?> address;
  final Value<String?> workType;
  final Value<bool> isActive;
  final Value<String?> notes;
  final Value<DateTime?> joiningDate;
  final Value<String?> paymentType;
  final Value<double?> defaultHourRate;
  final Value<double?> defaultNagRate;
  final Value<DateTime> createdAt;
  const WorkersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.mobile = const Value.absent(),
    this.address = const Value.absent(),
    this.workType = const Value.absent(),
    this.isActive = const Value.absent(),
    this.notes = const Value.absent(),
    this.joiningDate = const Value.absent(),
    this.paymentType = const Value.absent(),
    this.defaultHourRate = const Value.absent(),
    this.defaultNagRate = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WorkersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.mobile = const Value.absent(),
    this.address = const Value.absent(),
    this.workType = const Value.absent(),
    this.isActive = const Value.absent(),
    this.notes = const Value.absent(),
    this.joiningDate = const Value.absent(),
    this.paymentType = const Value.absent(),
    this.defaultHourRate = const Value.absent(),
    this.defaultNagRate = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<WorkerEntity> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? mobile,
    Expression<String>? address,
    Expression<String>? workType,
    Expression<bool>? isActive,
    Expression<String>? notes,
    Expression<DateTime>? joiningDate,
    Expression<String>? paymentType,
    Expression<double>? defaultHourRate,
    Expression<double>? defaultNagRate,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (mobile != null) 'mobile': mobile,
      if (address != null) 'address': address,
      if (workType != null) 'work_type': workType,
      if (isActive != null) 'is_active': isActive,
      if (notes != null) 'notes': notes,
      if (joiningDate != null) 'joining_date': joiningDate,
      if (paymentType != null) 'payment_type': paymentType,
      if (defaultHourRate != null) 'default_hour_rate': defaultHourRate,
      if (defaultNagRate != null) 'default_nag_rate': defaultNagRate,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WorkersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? mobile,
    Value<String?>? address,
    Value<String?>? workType,
    Value<bool>? isActive,
    Value<String?>? notes,
    Value<DateTime?>? joiningDate,
    Value<String?>? paymentType,
    Value<double?>? defaultHourRate,
    Value<double?>? defaultNagRate,
    Value<DateTime>? createdAt,
  }) {
    return WorkersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      workType: workType ?? this.workType,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      joiningDate: joiningDate ?? this.joiningDate,
      paymentType: paymentType ?? this.paymentType,
      defaultHourRate: defaultHourRate ?? this.defaultHourRate,
      defaultNagRate: defaultNagRate ?? this.defaultNagRate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (mobile.present) {
      map['mobile'] = Variable<String>(mobile.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (workType.present) {
      map['work_type'] = Variable<String>(workType.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (joiningDate.present) {
      map['joining_date'] = Variable<DateTime>(joiningDate.value);
    }
    if (paymentType.present) {
      map['payment_type'] = Variable<String>(paymentType.value);
    }
    if (defaultHourRate.present) {
      map['default_hour_rate'] = Variable<double>(defaultHourRate.value);
    }
    if (defaultNagRate.present) {
      map['default_nag_rate'] = Variable<double>(defaultNagRate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('mobile: $mobile, ')
          ..write('address: $address, ')
          ..write('workType: $workType, ')
          ..write('isActive: $isActive, ')
          ..write('notes: $notes, ')
          ..write('joiningDate: $joiningDate, ')
          ..write('paymentType: $paymentType, ')
          ..write('defaultHourRate: $defaultHourRate, ')
          ..write('defaultNagRate: $defaultNagRate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WorkerTransactionsTable extends WorkerTransactions
    with TableInfo<$WorkerTransactionsTable, WorkerTransactionEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkerTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _workerIdMeta = const VerificationMeta(
    'workerId',
  );
  @override
  late final GeneratedColumn<int> workerId = GeneratedColumn<int>(
    'worker_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityIssuedMeta = const VerificationMeta(
    'quantityIssued',
  );
  @override
  late final GeneratedColumn<double> quantityIssued = GeneratedColumn<double>(
    'quantity_issued',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workerId,
    itemId,
    quantityIssued,
    date,
    status,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'worker_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkerTransactionEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('worker_id')) {
      context.handle(
        _workerIdMeta,
        workerId.isAcceptableOrUnknown(data['worker_id']!, _workerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workerIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('quantity_issued')) {
      context.handle(
        _quantityIssuedMeta,
        quantityIssued.isAcceptableOrUnknown(
          data['quantity_issued']!,
          _quantityIssuedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityIssuedMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkerTransactionEntity map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkerTransactionEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}worker_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
      quantityIssued: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity_issued'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WorkerTransactionsTable createAlias(String alias) {
    return $WorkerTransactionsTable(attachedDatabase, alias);
  }
}

class WorkerTransactionEntity extends DataClass
    implements Insertable<WorkerTransactionEntity> {
  final int id;
  final int workerId;
  final int itemId;
  final double quantityIssued;
  final DateTime date;
  final String status;
  final String? notes;
  final DateTime createdAt;
  const WorkerTransactionEntity({
    required this.id,
    required this.workerId,
    required this.itemId,
    required this.quantityIssued,
    required this.date,
    required this.status,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['worker_id'] = Variable<int>(workerId);
    map['item_id'] = Variable<int>(itemId);
    map['quantity_issued'] = Variable<double>(quantityIssued);
    map['date'] = Variable<DateTime>(date);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WorkerTransactionsCompanion toCompanion(bool nullToAbsent) {
    return WorkerTransactionsCompanion(
      id: Value(id),
      workerId: Value(workerId),
      itemId: Value(itemId),
      quantityIssued: Value(quantityIssued),
      date: Value(date),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory WorkerTransactionEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkerTransactionEntity(
      id: serializer.fromJson<int>(json['id']),
      workerId: serializer.fromJson<int>(json['workerId']),
      itemId: serializer.fromJson<int>(json['itemId']),
      quantityIssued: serializer.fromJson<double>(json['quantityIssued']),
      date: serializer.fromJson<DateTime>(json['date']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workerId': serializer.toJson<int>(workerId),
      'itemId': serializer.toJson<int>(itemId),
      'quantityIssued': serializer.toJson<double>(quantityIssued),
      'date': serializer.toJson<DateTime>(date),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WorkerTransactionEntity copyWith({
    int? id,
    int? workerId,
    int? itemId,
    double? quantityIssued,
    DateTime? date,
    String? status,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => WorkerTransactionEntity(
    id: id ?? this.id,
    workerId: workerId ?? this.workerId,
    itemId: itemId ?? this.itemId,
    quantityIssued: quantityIssued ?? this.quantityIssued,
    date: date ?? this.date,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  WorkerTransactionEntity copyWithCompanion(WorkerTransactionsCompanion data) {
    return WorkerTransactionEntity(
      id: data.id.present ? data.id.value : this.id,
      workerId: data.workerId.present ? data.workerId.value : this.workerId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      quantityIssued: data.quantityIssued.present
          ? data.quantityIssued.value
          : this.quantityIssued,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkerTransactionEntity(')
          ..write('id: $id, ')
          ..write('workerId: $workerId, ')
          ..write('itemId: $itemId, ')
          ..write('quantityIssued: $quantityIssued, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workerId,
    itemId,
    quantityIssued,
    date,
    status,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkerTransactionEntity &&
          other.id == this.id &&
          other.workerId == this.workerId &&
          other.itemId == this.itemId &&
          other.quantityIssued == this.quantityIssued &&
          other.date == this.date &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class WorkerTransactionsCompanion
    extends UpdateCompanion<WorkerTransactionEntity> {
  final Value<int> id;
  final Value<int> workerId;
  final Value<int> itemId;
  final Value<double> quantityIssued;
  final Value<DateTime> date;
  final Value<String> status;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const WorkerTransactionsCompanion({
    this.id = const Value.absent(),
    this.workerId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.quantityIssued = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WorkerTransactionsCompanion.insert({
    this.id = const Value.absent(),
    required int workerId,
    required int itemId,
    required double quantityIssued,
    required DateTime date,
    required String status,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : workerId = Value(workerId),
       itemId = Value(itemId),
       quantityIssued = Value(quantityIssued),
       date = Value(date),
       status = Value(status);
  static Insertable<WorkerTransactionEntity> custom({
    Expression<int>? id,
    Expression<int>? workerId,
    Expression<int>? itemId,
    Expression<double>? quantityIssued,
    Expression<DateTime>? date,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workerId != null) 'worker_id': workerId,
      if (itemId != null) 'item_id': itemId,
      if (quantityIssued != null) 'quantity_issued': quantityIssued,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WorkerTransactionsCompanion copyWith({
    Value<int>? id,
    Value<int>? workerId,
    Value<int>? itemId,
    Value<double>? quantityIssued,
    Value<DateTime>? date,
    Value<String>? status,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return WorkerTransactionsCompanion(
      id: id ?? this.id,
      workerId: workerId ?? this.workerId,
      itemId: itemId ?? this.itemId,
      quantityIssued: quantityIssued ?? this.quantityIssued,
      date: date ?? this.date,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workerId.present) {
      map['worker_id'] = Variable<int>(workerId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (quantityIssued.present) {
      map['quantity_issued'] = Variable<double>(quantityIssued.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkerTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('workerId: $workerId, ')
          ..write('itemId: $itemId, ')
          ..write('quantityIssued: $quantityIssued, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ProductionRecordsTable extends ProductionRecords
    with TableInfo<$ProductionRecordsTable, ProductionRecordEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductionRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _workerIdMeta = const VerificationMeta(
    'workerId',
  );
  @override
  late final GeneratedColumn<int> workerId = GeneratedColumn<int>(
    'worker_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workerTransactionIdMeta =
      const VerificationMeta('workerTransactionId');
  @override
  late final GeneratedColumn<int> workerTransactionId = GeneratedColumn<int>(
    'worker_transaction_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outputItemIdMeta = const VerificationMeta(
    'outputItemId',
  );
  @override
  late final GeneratedColumn<int> outputItemId = GeneratedColumn<int>(
    'output_item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outputQtyMeta = const VerificationMeta(
    'outputQty',
  );
  @override
  late final GeneratedColumn<double> outputQty = GeneratedColumn<double>(
    'output_qty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchRefMeta = const VerificationMeta(
    'batchRef',
  );
  @override
  late final GeneratedColumn<String> batchRef = GeneratedColumn<String>(
    'batch_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workerId,
    workerTransactionId,
    outputItemId,
    outputQty,
    date,
    batchRef,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'production_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductionRecordEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('worker_id')) {
      context.handle(
        _workerIdMeta,
        workerId.isAcceptableOrUnknown(data['worker_id']!, _workerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workerIdMeta);
    }
    if (data.containsKey('worker_transaction_id')) {
      context.handle(
        _workerTransactionIdMeta,
        workerTransactionId.isAcceptableOrUnknown(
          data['worker_transaction_id']!,
          _workerTransactionIdMeta,
        ),
      );
    }
    if (data.containsKey('output_item_id')) {
      context.handle(
        _outputItemIdMeta,
        outputItemId.isAcceptableOrUnknown(
          data['output_item_id']!,
          _outputItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_outputItemIdMeta);
    }
    if (data.containsKey('output_qty')) {
      context.handle(
        _outputQtyMeta,
        outputQty.isAcceptableOrUnknown(data['output_qty']!, _outputQtyMeta),
      );
    } else if (isInserting) {
      context.missing(_outputQtyMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('batch_ref')) {
      context.handle(
        _batchRefMeta,
        batchRef.isAcceptableOrUnknown(data['batch_ref']!, _batchRefMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductionRecordEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductionRecordEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}worker_id'],
      )!,
      workerTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}worker_transaction_id'],
      ),
      outputItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}output_item_id'],
      )!,
      outputQty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}output_qty'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      batchRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_ref'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ProductionRecordsTable createAlias(String alias) {
    return $ProductionRecordsTable(attachedDatabase, alias);
  }
}

class ProductionRecordEntity extends DataClass
    implements Insertable<ProductionRecordEntity> {
  final int id;
  final int workerId;
  final int? workerTransactionId;
  final int outputItemId;
  final double outputQty;
  final DateTime date;
  final String? batchRef;
  final String? notes;
  final DateTime createdAt;
  const ProductionRecordEntity({
    required this.id,
    required this.workerId,
    this.workerTransactionId,
    required this.outputItemId,
    required this.outputQty,
    required this.date,
    this.batchRef,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['worker_id'] = Variable<int>(workerId);
    if (!nullToAbsent || workerTransactionId != null) {
      map['worker_transaction_id'] = Variable<int>(workerTransactionId);
    }
    map['output_item_id'] = Variable<int>(outputItemId);
    map['output_qty'] = Variable<double>(outputQty);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || batchRef != null) {
      map['batch_ref'] = Variable<String>(batchRef);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProductionRecordsCompanion toCompanion(bool nullToAbsent) {
    return ProductionRecordsCompanion(
      id: Value(id),
      workerId: Value(workerId),
      workerTransactionId: workerTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(workerTransactionId),
      outputItemId: Value(outputItemId),
      outputQty: Value(outputQty),
      date: Value(date),
      batchRef: batchRef == null && nullToAbsent
          ? const Value.absent()
          : Value(batchRef),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory ProductionRecordEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductionRecordEntity(
      id: serializer.fromJson<int>(json['id']),
      workerId: serializer.fromJson<int>(json['workerId']),
      workerTransactionId: serializer.fromJson<int?>(
        json['workerTransactionId'],
      ),
      outputItemId: serializer.fromJson<int>(json['outputItemId']),
      outputQty: serializer.fromJson<double>(json['outputQty']),
      date: serializer.fromJson<DateTime>(json['date']),
      batchRef: serializer.fromJson<String?>(json['batchRef']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workerId': serializer.toJson<int>(workerId),
      'workerTransactionId': serializer.toJson<int?>(workerTransactionId),
      'outputItemId': serializer.toJson<int>(outputItemId),
      'outputQty': serializer.toJson<double>(outputQty),
      'date': serializer.toJson<DateTime>(date),
      'batchRef': serializer.toJson<String?>(batchRef),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ProductionRecordEntity copyWith({
    int? id,
    int? workerId,
    Value<int?> workerTransactionId = const Value.absent(),
    int? outputItemId,
    double? outputQty,
    DateTime? date,
    Value<String?> batchRef = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => ProductionRecordEntity(
    id: id ?? this.id,
    workerId: workerId ?? this.workerId,
    workerTransactionId: workerTransactionId.present
        ? workerTransactionId.value
        : this.workerTransactionId,
    outputItemId: outputItemId ?? this.outputItemId,
    outputQty: outputQty ?? this.outputQty,
    date: date ?? this.date,
    batchRef: batchRef.present ? batchRef.value : this.batchRef,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  ProductionRecordEntity copyWithCompanion(ProductionRecordsCompanion data) {
    return ProductionRecordEntity(
      id: data.id.present ? data.id.value : this.id,
      workerId: data.workerId.present ? data.workerId.value : this.workerId,
      workerTransactionId: data.workerTransactionId.present
          ? data.workerTransactionId.value
          : this.workerTransactionId,
      outputItemId: data.outputItemId.present
          ? data.outputItemId.value
          : this.outputItemId,
      outputQty: data.outputQty.present ? data.outputQty.value : this.outputQty,
      date: data.date.present ? data.date.value : this.date,
      batchRef: data.batchRef.present ? data.batchRef.value : this.batchRef,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductionRecordEntity(')
          ..write('id: $id, ')
          ..write('workerId: $workerId, ')
          ..write('workerTransactionId: $workerTransactionId, ')
          ..write('outputItemId: $outputItemId, ')
          ..write('outputQty: $outputQty, ')
          ..write('date: $date, ')
          ..write('batchRef: $batchRef, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workerId,
    workerTransactionId,
    outputItemId,
    outputQty,
    date,
    batchRef,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductionRecordEntity &&
          other.id == this.id &&
          other.workerId == this.workerId &&
          other.workerTransactionId == this.workerTransactionId &&
          other.outputItemId == this.outputItemId &&
          other.outputQty == this.outputQty &&
          other.date == this.date &&
          other.batchRef == this.batchRef &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class ProductionRecordsCompanion
    extends UpdateCompanion<ProductionRecordEntity> {
  final Value<int> id;
  final Value<int> workerId;
  final Value<int?> workerTransactionId;
  final Value<int> outputItemId;
  final Value<double> outputQty;
  final Value<DateTime> date;
  final Value<String?> batchRef;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const ProductionRecordsCompanion({
    this.id = const Value.absent(),
    this.workerId = const Value.absent(),
    this.workerTransactionId = const Value.absent(),
    this.outputItemId = const Value.absent(),
    this.outputQty = const Value.absent(),
    this.date = const Value.absent(),
    this.batchRef = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ProductionRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int workerId,
    this.workerTransactionId = const Value.absent(),
    required int outputItemId,
    required double outputQty,
    required DateTime date,
    this.batchRef = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : workerId = Value(workerId),
       outputItemId = Value(outputItemId),
       outputQty = Value(outputQty),
       date = Value(date);
  static Insertable<ProductionRecordEntity> custom({
    Expression<int>? id,
    Expression<int>? workerId,
    Expression<int>? workerTransactionId,
    Expression<int>? outputItemId,
    Expression<double>? outputQty,
    Expression<DateTime>? date,
    Expression<String>? batchRef,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workerId != null) 'worker_id': workerId,
      if (workerTransactionId != null)
        'worker_transaction_id': workerTransactionId,
      if (outputItemId != null) 'output_item_id': outputItemId,
      if (outputQty != null) 'output_qty': outputQty,
      if (date != null) 'date': date,
      if (batchRef != null) 'batch_ref': batchRef,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ProductionRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? workerId,
    Value<int?>? workerTransactionId,
    Value<int>? outputItemId,
    Value<double>? outputQty,
    Value<DateTime>? date,
    Value<String?>? batchRef,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return ProductionRecordsCompanion(
      id: id ?? this.id,
      workerId: workerId ?? this.workerId,
      workerTransactionId: workerTransactionId ?? this.workerTransactionId,
      outputItemId: outputItemId ?? this.outputItemId,
      outputQty: outputQty ?? this.outputQty,
      date: date ?? this.date,
      batchRef: batchRef ?? this.batchRef,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workerId.present) {
      map['worker_id'] = Variable<int>(workerId.value);
    }
    if (workerTransactionId.present) {
      map['worker_transaction_id'] = Variable<int>(workerTransactionId.value);
    }
    if (outputItemId.present) {
      map['output_item_id'] = Variable<int>(outputItemId.value);
    }
    if (outputQty.present) {
      map['output_qty'] = Variable<double>(outputQty.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (batchRef.present) {
      map['batch_ref'] = Variable<String>(batchRef.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductionRecordsCompanion(')
          ..write('id: $id, ')
          ..write('workerId: $workerId, ')
          ..write('workerTransactionId: $workerTransactionId, ')
          ..write('outputItemId: $outputItemId, ')
          ..write('outputQty: $outputQty, ')
          ..write('date: $date, ')
          ..write('batchRef: $batchRef, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ProductionInputsTable extends ProductionInputs
    with TableInfo<$ProductionInputsTable, ProductionInputEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductionInputsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _productionRecordIdMeta =
      const VerificationMeta('productionRecordId');
  @override
  late final GeneratedColumn<int> productionRecordId = GeneratedColumn<int>(
    'production_record_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityUsedMeta = const VerificationMeta(
    'quantityUsed',
  );
  @override
  late final GeneratedColumn<double> quantityUsed = GeneratedColumn<double>(
    'quantity_used',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityReturnedMeta = const VerificationMeta(
    'quantityReturned',
  );
  @override
  late final GeneratedColumn<double> quantityReturned = GeneratedColumn<double>(
    'quantity_returned',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productionRecordId,
    itemId,
    quantityUsed,
    quantityReturned,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'production_inputs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductionInputEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('production_record_id')) {
      context.handle(
        _productionRecordIdMeta,
        productionRecordId.isAcceptableOrUnknown(
          data['production_record_id']!,
          _productionRecordIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productionRecordIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('quantity_used')) {
      context.handle(
        _quantityUsedMeta,
        quantityUsed.isAcceptableOrUnknown(
          data['quantity_used']!,
          _quantityUsedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityUsedMeta);
    }
    if (data.containsKey('quantity_returned')) {
      context.handle(
        _quantityReturnedMeta,
        quantityReturned.isAcceptableOrUnknown(
          data['quantity_returned']!,
          _quantityReturnedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductionInputEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductionInputEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      productionRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}production_record_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
      quantityUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity_used'],
      )!,
      quantityReturned: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity_returned'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ProductionInputsTable createAlias(String alias) {
    return $ProductionInputsTable(attachedDatabase, alias);
  }
}

class ProductionInputEntity extends DataClass
    implements Insertable<ProductionInputEntity> {
  final int id;
  final int productionRecordId;
  final int itemId;
  final double quantityUsed;
  final double quantityReturned;
  final DateTime createdAt;
  const ProductionInputEntity({
    required this.id,
    required this.productionRecordId,
    required this.itemId,
    required this.quantityUsed,
    required this.quantityReturned,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['production_record_id'] = Variable<int>(productionRecordId);
    map['item_id'] = Variable<int>(itemId);
    map['quantity_used'] = Variable<double>(quantityUsed);
    map['quantity_returned'] = Variable<double>(quantityReturned);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProductionInputsCompanion toCompanion(bool nullToAbsent) {
    return ProductionInputsCompanion(
      id: Value(id),
      productionRecordId: Value(productionRecordId),
      itemId: Value(itemId),
      quantityUsed: Value(quantityUsed),
      quantityReturned: Value(quantityReturned),
      createdAt: Value(createdAt),
    );
  }

  factory ProductionInputEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductionInputEntity(
      id: serializer.fromJson<int>(json['id']),
      productionRecordId: serializer.fromJson<int>(json['productionRecordId']),
      itemId: serializer.fromJson<int>(json['itemId']),
      quantityUsed: serializer.fromJson<double>(json['quantityUsed']),
      quantityReturned: serializer.fromJson<double>(json['quantityReturned']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productionRecordId': serializer.toJson<int>(productionRecordId),
      'itemId': serializer.toJson<int>(itemId),
      'quantityUsed': serializer.toJson<double>(quantityUsed),
      'quantityReturned': serializer.toJson<double>(quantityReturned),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ProductionInputEntity copyWith({
    int? id,
    int? productionRecordId,
    int? itemId,
    double? quantityUsed,
    double? quantityReturned,
    DateTime? createdAt,
  }) => ProductionInputEntity(
    id: id ?? this.id,
    productionRecordId: productionRecordId ?? this.productionRecordId,
    itemId: itemId ?? this.itemId,
    quantityUsed: quantityUsed ?? this.quantityUsed,
    quantityReturned: quantityReturned ?? this.quantityReturned,
    createdAt: createdAt ?? this.createdAt,
  );
  ProductionInputEntity copyWithCompanion(ProductionInputsCompanion data) {
    return ProductionInputEntity(
      id: data.id.present ? data.id.value : this.id,
      productionRecordId: data.productionRecordId.present
          ? data.productionRecordId.value
          : this.productionRecordId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      quantityUsed: data.quantityUsed.present
          ? data.quantityUsed.value
          : this.quantityUsed,
      quantityReturned: data.quantityReturned.present
          ? data.quantityReturned.value
          : this.quantityReturned,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductionInputEntity(')
          ..write('id: $id, ')
          ..write('productionRecordId: $productionRecordId, ')
          ..write('itemId: $itemId, ')
          ..write('quantityUsed: $quantityUsed, ')
          ..write('quantityReturned: $quantityReturned, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productionRecordId,
    itemId,
    quantityUsed,
    quantityReturned,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductionInputEntity &&
          other.id == this.id &&
          other.productionRecordId == this.productionRecordId &&
          other.itemId == this.itemId &&
          other.quantityUsed == this.quantityUsed &&
          other.quantityReturned == this.quantityReturned &&
          other.createdAt == this.createdAt);
}

class ProductionInputsCompanion extends UpdateCompanion<ProductionInputEntity> {
  final Value<int> id;
  final Value<int> productionRecordId;
  final Value<int> itemId;
  final Value<double> quantityUsed;
  final Value<double> quantityReturned;
  final Value<DateTime> createdAt;
  const ProductionInputsCompanion({
    this.id = const Value.absent(),
    this.productionRecordId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.quantityUsed = const Value.absent(),
    this.quantityReturned = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ProductionInputsCompanion.insert({
    this.id = const Value.absent(),
    required int productionRecordId,
    required int itemId,
    required double quantityUsed,
    this.quantityReturned = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : productionRecordId = Value(productionRecordId),
       itemId = Value(itemId),
       quantityUsed = Value(quantityUsed);
  static Insertable<ProductionInputEntity> custom({
    Expression<int>? id,
    Expression<int>? productionRecordId,
    Expression<int>? itemId,
    Expression<double>? quantityUsed,
    Expression<double>? quantityReturned,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productionRecordId != null)
        'production_record_id': productionRecordId,
      if (itemId != null) 'item_id': itemId,
      if (quantityUsed != null) 'quantity_used': quantityUsed,
      if (quantityReturned != null) 'quantity_returned': quantityReturned,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ProductionInputsCompanion copyWith({
    Value<int>? id,
    Value<int>? productionRecordId,
    Value<int>? itemId,
    Value<double>? quantityUsed,
    Value<double>? quantityReturned,
    Value<DateTime>? createdAt,
  }) {
    return ProductionInputsCompanion(
      id: id ?? this.id,
      productionRecordId: productionRecordId ?? this.productionRecordId,
      itemId: itemId ?? this.itemId,
      quantityUsed: quantityUsed ?? this.quantityUsed,
      quantityReturned: quantityReturned ?? this.quantityReturned,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productionRecordId.present) {
      map['production_record_id'] = Variable<int>(productionRecordId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (quantityUsed.present) {
      map['quantity_used'] = Variable<double>(quantityUsed.value);
    }
    if (quantityReturned.present) {
      map['quantity_returned'] = Variable<double>(quantityReturned.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductionInputsCompanion(')
          ..write('id: $id, ')
          ..write('productionRecordId: $productionRecordId, ')
          ..write('itemId: $itemId, ')
          ..write('quantityUsed: $quantityUsed, ')
          ..write('quantityReturned: $quantityReturned, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BillsTable extends Bills with TableInfo<$BillsTable, BillEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _billNumberMeta = const VerificationMeta(
    'billNumber',
  );
  @override
  late final GeneratedColumn<String> billNumber = GeneratedColumn<String>(
    'bill_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _saleChannelMeta = const VerificationMeta(
    'saleChannel',
  );
  @override
  late final GeneratedColumn<String> saleChannel = GeneratedColumn<String>(
    'sale_channel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('invoice'),
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _billDateMeta = const VerificationMeta(
    'billDate',
  );
  @override
  late final GeneratedColumn<DateTime> billDate = GeneratedColumn<DateTime>(
    'bill_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountMeta = const VerificationMeta(
    'discount',
  );
  @override
  late final GeneratedColumn<double> discount = GeneratedColumn<double>(
    'discount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _otherChargesMeta = const VerificationMeta(
    'otherCharges',
  );
  @override
  late final GeneratedColumn<double> otherCharges = GeneratedColumn<double>(
    'other_charges',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _previousOutstandingSnapshotMeta =
      const VerificationMeta('previousOutstandingSnapshot');
  @override
  late final GeneratedColumn<double> previousOutstandingSnapshot =
      GeneratedColumn<double>(
        'previous_outstanding_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _currentBalanceSnapshotMeta =
      const VerificationMeta('currentBalanceSnapshot');
  @override
  late final GeneratedColumn<double> currentBalanceSnapshot =
      GeneratedColumn<double>(
        'current_balance_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _grandTotalMeta = const VerificationMeta(
    'grandTotal',
  );
  @override
  late final GeneratedColumn<double> grandTotal = GeneratedColumn<double>(
    'grand_total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaidMeta = const VerificationMeta(
    'amountPaid',
  );
  @override
  late final GeneratedColumn<double> amountPaid = GeneratedColumn<double>(
    'amount_paid',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _advanceAppliedMeta = const VerificationMeta(
    'advanceApplied',
  );
  @override
  late final GeneratedColumn<double> advanceApplied = GeneratedColumn<double>(
    'advance_applied',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _gstEnabledMeta = const VerificationMeta(
    'gstEnabled',
  );
  @override
  late final GeneratedColumn<bool> gstEnabled = GeneratedColumn<bool>(
    'gst_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("gst_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _gstPercentMeta = const VerificationMeta(
    'gstPercent',
  );
  @override
  late final GeneratedColumn<double> gstPercent = GeneratedColumn<double>(
    'gst_percent',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taxableAmountMeta = const VerificationMeta(
    'taxableAmount',
  );
  @override
  late final GeneratedColumn<double> taxableAmount = GeneratedColumn<double>(
    'taxable_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _gstAmountMeta = const VerificationMeta(
    'gstAmount',
  );
  @override
  late final GeneratedColumn<double> gstAmount = GeneratedColumn<double>(
    'gst_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _remainingBalanceMeta = const VerificationMeta(
    'remainingBalance',
  );
  @override
  late final GeneratedColumn<double> remainingBalance = GeneratedColumn<double>(
    'remaining_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _voidReasonMeta = const VerificationMeta(
    'voidReason',
  );
  @override
  late final GeneratedColumn<String> voidReason = GeneratedColumn<String>(
    'void_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidedAtMeta = const VerificationMeta(
    'voidedAt',
  );
  @override
  late final GeneratedColumn<DateTime> voidedAt = GeneratedColumn<DateTime>(
    'voided_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isWholesaleBillMeta = const VerificationMeta(
    'isWholesaleBill',
  );
  @override
  late final GeneratedColumn<bool> isWholesaleBill = GeneratedColumn<bool>(
    'is_wholesale_bill',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_wholesale_bill" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    billNumber,
    saleChannel,
    customerId,
    billDate,
    subtotal,
    discount,
    otherCharges,
    previousOutstandingSnapshot,
    currentBalanceSnapshot,
    grandTotal,
    amountPaid,
    advanceApplied,
    gstEnabled,
    gstPercent,
    taxableAmount,
    gstAmount,
    remainingBalance,
    status,
    voidReason,
    voidedAt,
    isWholesaleBill,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bills';
  @override
  VerificationContext validateIntegrity(
    Insertable<BillEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bill_number')) {
      context.handle(
        _billNumberMeta,
        billNumber.isAcceptableOrUnknown(data['bill_number']!, _billNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_billNumberMeta);
    }
    if (data.containsKey('sale_channel')) {
      context.handle(
        _saleChannelMeta,
        saleChannel.isAcceptableOrUnknown(
          data['sale_channel']!,
          _saleChannelMeta,
        ),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('bill_date')) {
      context.handle(
        _billDateMeta,
        billDate.isAcceptableOrUnknown(data['bill_date']!, _billDateMeta),
      );
    } else if (isInserting) {
      context.missing(_billDateMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('discount')) {
      context.handle(
        _discountMeta,
        discount.isAcceptableOrUnknown(data['discount']!, _discountMeta),
      );
    }
    if (data.containsKey('other_charges')) {
      context.handle(
        _otherChargesMeta,
        otherCharges.isAcceptableOrUnknown(
          data['other_charges']!,
          _otherChargesMeta,
        ),
      );
    }
    if (data.containsKey('previous_outstanding_snapshot')) {
      context.handle(
        _previousOutstandingSnapshotMeta,
        previousOutstandingSnapshot.isAcceptableOrUnknown(
          data['previous_outstanding_snapshot']!,
          _previousOutstandingSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('current_balance_snapshot')) {
      context.handle(
        _currentBalanceSnapshotMeta,
        currentBalanceSnapshot.isAcceptableOrUnknown(
          data['current_balance_snapshot']!,
          _currentBalanceSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('grand_total')) {
      context.handle(
        _grandTotalMeta,
        grandTotal.isAcceptableOrUnknown(data['grand_total']!, _grandTotalMeta),
      );
    } else if (isInserting) {
      context.missing(_grandTotalMeta);
    }
    if (data.containsKey('amount_paid')) {
      context.handle(
        _amountPaidMeta,
        amountPaid.isAcceptableOrUnknown(data['amount_paid']!, _amountPaidMeta),
      );
    }
    if (data.containsKey('advance_applied')) {
      context.handle(
        _advanceAppliedMeta,
        advanceApplied.isAcceptableOrUnknown(
          data['advance_applied']!,
          _advanceAppliedMeta,
        ),
      );
    }
    if (data.containsKey('gst_enabled')) {
      context.handle(
        _gstEnabledMeta,
        gstEnabled.isAcceptableOrUnknown(data['gst_enabled']!, _gstEnabledMeta),
      );
    }
    if (data.containsKey('gst_percent')) {
      context.handle(
        _gstPercentMeta,
        gstPercent.isAcceptableOrUnknown(data['gst_percent']!, _gstPercentMeta),
      );
    }
    if (data.containsKey('taxable_amount')) {
      context.handle(
        _taxableAmountMeta,
        taxableAmount.isAcceptableOrUnknown(
          data['taxable_amount']!,
          _taxableAmountMeta,
        ),
      );
    }
    if (data.containsKey('gst_amount')) {
      context.handle(
        _gstAmountMeta,
        gstAmount.isAcceptableOrUnknown(data['gst_amount']!, _gstAmountMeta),
      );
    }
    if (data.containsKey('remaining_balance')) {
      context.handle(
        _remainingBalanceMeta,
        remainingBalance.isAcceptableOrUnknown(
          data['remaining_balance']!,
          _remainingBalanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remainingBalanceMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('void_reason')) {
      context.handle(
        _voidReasonMeta,
        voidReason.isAcceptableOrUnknown(data['void_reason']!, _voidReasonMeta),
      );
    }
    if (data.containsKey('voided_at')) {
      context.handle(
        _voidedAtMeta,
        voidedAt.isAcceptableOrUnknown(data['voided_at']!, _voidedAtMeta),
      );
    }
    if (data.containsKey('is_wholesale_bill')) {
      context.handle(
        _isWholesaleBillMeta,
        isWholesaleBill.isAcceptableOrUnknown(
          data['is_wholesale_bill']!,
          _isWholesaleBillMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BillEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BillEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      billNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bill_number'],
      )!,
      saleChannel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_channel'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      ),
      billDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}bill_date'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      discount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount'],
      )!,
      otherCharges: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}other_charges'],
      )!,
      previousOutstandingSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}previous_outstanding_snapshot'],
      )!,
      currentBalanceSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_balance_snapshot'],
      ),
      grandTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grand_total'],
      )!,
      amountPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_paid'],
      )!,
      advanceApplied: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}advance_applied'],
      )!,
      gstEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}gst_enabled'],
      )!,
      gstPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gst_percent'],
      ),
      taxableAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}taxable_amount'],
      )!,
      gstAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gst_amount'],
      )!,
      remainingBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}remaining_balance'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      voidReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}void_reason'],
      ),
      voidedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}voided_at'],
      ),
      isWholesaleBill: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_wholesale_bill'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BillsTable createAlias(String alias) {
    return $BillsTable(attachedDatabase, alias);
  }
}

class BillEntity extends DataClass implements Insertable<BillEntity> {
  final int id;
  final String billNumber;
  final String saleChannel;
  final int? customerId;
  final DateTime billDate;
  final double subtotal;
  final double discount;
  final double otherCharges;
  final double previousOutstandingSnapshot;
  final double? currentBalanceSnapshot;
  final double grandTotal;
  final double amountPaid;
  final double advanceApplied;
  final bool gstEnabled;
  final double? gstPercent;
  final double taxableAmount;
  final double gstAmount;
  final double remainingBalance;
  final String status;
  final String? voidReason;
  final DateTime? voidedAt;
  final bool isWholesaleBill;
  final String? notes;
  final DateTime createdAt;
  const BillEntity({
    required this.id,
    required this.billNumber,
    required this.saleChannel,
    this.customerId,
    required this.billDate,
    required this.subtotal,
    required this.discount,
    required this.otherCharges,
    required this.previousOutstandingSnapshot,
    this.currentBalanceSnapshot,
    required this.grandTotal,
    required this.amountPaid,
    required this.advanceApplied,
    required this.gstEnabled,
    this.gstPercent,
    required this.taxableAmount,
    required this.gstAmount,
    required this.remainingBalance,
    required this.status,
    this.voidReason,
    this.voidedAt,
    required this.isWholesaleBill,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bill_number'] = Variable<String>(billNumber);
    map['sale_channel'] = Variable<String>(saleChannel);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<int>(customerId);
    }
    map['bill_date'] = Variable<DateTime>(billDate);
    map['subtotal'] = Variable<double>(subtotal);
    map['discount'] = Variable<double>(discount);
    map['other_charges'] = Variable<double>(otherCharges);
    map['previous_outstanding_snapshot'] = Variable<double>(
      previousOutstandingSnapshot,
    );
    if (!nullToAbsent || currentBalanceSnapshot != null) {
      map['current_balance_snapshot'] = Variable<double>(
        currentBalanceSnapshot,
      );
    }
    map['grand_total'] = Variable<double>(grandTotal);
    map['amount_paid'] = Variable<double>(amountPaid);
    map['advance_applied'] = Variable<double>(advanceApplied);
    map['gst_enabled'] = Variable<bool>(gstEnabled);
    if (!nullToAbsent || gstPercent != null) {
      map['gst_percent'] = Variable<double>(gstPercent);
    }
    map['taxable_amount'] = Variable<double>(taxableAmount);
    map['gst_amount'] = Variable<double>(gstAmount);
    map['remaining_balance'] = Variable<double>(remainingBalance);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || voidReason != null) {
      map['void_reason'] = Variable<String>(voidReason);
    }
    if (!nullToAbsent || voidedAt != null) {
      map['voided_at'] = Variable<DateTime>(voidedAt);
    }
    map['is_wholesale_bill'] = Variable<bool>(isWholesaleBill);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BillsCompanion toCompanion(bool nullToAbsent) {
    return BillsCompanion(
      id: Value(id),
      billNumber: Value(billNumber),
      saleChannel: Value(saleChannel),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      billDate: Value(billDate),
      subtotal: Value(subtotal),
      discount: Value(discount),
      otherCharges: Value(otherCharges),
      previousOutstandingSnapshot: Value(previousOutstandingSnapshot),
      currentBalanceSnapshot: currentBalanceSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(currentBalanceSnapshot),
      grandTotal: Value(grandTotal),
      amountPaid: Value(amountPaid),
      advanceApplied: Value(advanceApplied),
      gstEnabled: Value(gstEnabled),
      gstPercent: gstPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(gstPercent),
      taxableAmount: Value(taxableAmount),
      gstAmount: Value(gstAmount),
      remainingBalance: Value(remainingBalance),
      status: Value(status),
      voidReason: voidReason == null && nullToAbsent
          ? const Value.absent()
          : Value(voidReason),
      voidedAt: voidedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(voidedAt),
      isWholesaleBill: Value(isWholesaleBill),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory BillEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BillEntity(
      id: serializer.fromJson<int>(json['id']),
      billNumber: serializer.fromJson<String>(json['billNumber']),
      saleChannel: serializer.fromJson<String>(json['saleChannel']),
      customerId: serializer.fromJson<int?>(json['customerId']),
      billDate: serializer.fromJson<DateTime>(json['billDate']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      discount: serializer.fromJson<double>(json['discount']),
      otherCharges: serializer.fromJson<double>(json['otherCharges']),
      previousOutstandingSnapshot: serializer.fromJson<double>(
        json['previousOutstandingSnapshot'],
      ),
      currentBalanceSnapshot: serializer.fromJson<double?>(
        json['currentBalanceSnapshot'],
      ),
      grandTotal: serializer.fromJson<double>(json['grandTotal']),
      amountPaid: serializer.fromJson<double>(json['amountPaid']),
      advanceApplied: serializer.fromJson<double>(json['advanceApplied']),
      gstEnabled: serializer.fromJson<bool>(json['gstEnabled']),
      gstPercent: serializer.fromJson<double?>(json['gstPercent']),
      taxableAmount: serializer.fromJson<double>(json['taxableAmount']),
      gstAmount: serializer.fromJson<double>(json['gstAmount']),
      remainingBalance: serializer.fromJson<double>(json['remainingBalance']),
      status: serializer.fromJson<String>(json['status']),
      voidReason: serializer.fromJson<String?>(json['voidReason']),
      voidedAt: serializer.fromJson<DateTime?>(json['voidedAt']),
      isWholesaleBill: serializer.fromJson<bool>(json['isWholesaleBill']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'billNumber': serializer.toJson<String>(billNumber),
      'saleChannel': serializer.toJson<String>(saleChannel),
      'customerId': serializer.toJson<int?>(customerId),
      'billDate': serializer.toJson<DateTime>(billDate),
      'subtotal': serializer.toJson<double>(subtotal),
      'discount': serializer.toJson<double>(discount),
      'otherCharges': serializer.toJson<double>(otherCharges),
      'previousOutstandingSnapshot': serializer.toJson<double>(
        previousOutstandingSnapshot,
      ),
      'currentBalanceSnapshot': serializer.toJson<double?>(
        currentBalanceSnapshot,
      ),
      'grandTotal': serializer.toJson<double>(grandTotal),
      'amountPaid': serializer.toJson<double>(amountPaid),
      'advanceApplied': serializer.toJson<double>(advanceApplied),
      'gstEnabled': serializer.toJson<bool>(gstEnabled),
      'gstPercent': serializer.toJson<double?>(gstPercent),
      'taxableAmount': serializer.toJson<double>(taxableAmount),
      'gstAmount': serializer.toJson<double>(gstAmount),
      'remainingBalance': serializer.toJson<double>(remainingBalance),
      'status': serializer.toJson<String>(status),
      'voidReason': serializer.toJson<String?>(voidReason),
      'voidedAt': serializer.toJson<DateTime?>(voidedAt),
      'isWholesaleBill': serializer.toJson<bool>(isWholesaleBill),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BillEntity copyWith({
    int? id,
    String? billNumber,
    String? saleChannel,
    Value<int?> customerId = const Value.absent(),
    DateTime? billDate,
    double? subtotal,
    double? discount,
    double? otherCharges,
    double? previousOutstandingSnapshot,
    Value<double?> currentBalanceSnapshot = const Value.absent(),
    double? grandTotal,
    double? amountPaid,
    double? advanceApplied,
    bool? gstEnabled,
    Value<double?> gstPercent = const Value.absent(),
    double? taxableAmount,
    double? gstAmount,
    double? remainingBalance,
    String? status,
    Value<String?> voidReason = const Value.absent(),
    Value<DateTime?> voidedAt = const Value.absent(),
    bool? isWholesaleBill,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => BillEntity(
    id: id ?? this.id,
    billNumber: billNumber ?? this.billNumber,
    saleChannel: saleChannel ?? this.saleChannel,
    customerId: customerId.present ? customerId.value : this.customerId,
    billDate: billDate ?? this.billDate,
    subtotal: subtotal ?? this.subtotal,
    discount: discount ?? this.discount,
    otherCharges: otherCharges ?? this.otherCharges,
    previousOutstandingSnapshot:
        previousOutstandingSnapshot ?? this.previousOutstandingSnapshot,
    currentBalanceSnapshot: currentBalanceSnapshot.present
        ? currentBalanceSnapshot.value
        : this.currentBalanceSnapshot,
    grandTotal: grandTotal ?? this.grandTotal,
    amountPaid: amountPaid ?? this.amountPaid,
    advanceApplied: advanceApplied ?? this.advanceApplied,
    gstEnabled: gstEnabled ?? this.gstEnabled,
    gstPercent: gstPercent.present ? gstPercent.value : this.gstPercent,
    taxableAmount: taxableAmount ?? this.taxableAmount,
    gstAmount: gstAmount ?? this.gstAmount,
    remainingBalance: remainingBalance ?? this.remainingBalance,
    status: status ?? this.status,
    voidReason: voidReason.present ? voidReason.value : this.voidReason,
    voidedAt: voidedAt.present ? voidedAt.value : this.voidedAt,
    isWholesaleBill: isWholesaleBill ?? this.isWholesaleBill,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  BillEntity copyWithCompanion(BillsCompanion data) {
    return BillEntity(
      id: data.id.present ? data.id.value : this.id,
      billNumber: data.billNumber.present
          ? data.billNumber.value
          : this.billNumber,
      saleChannel: data.saleChannel.present
          ? data.saleChannel.value
          : this.saleChannel,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      billDate: data.billDate.present ? data.billDate.value : this.billDate,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      discount: data.discount.present ? data.discount.value : this.discount,
      otherCharges: data.otherCharges.present
          ? data.otherCharges.value
          : this.otherCharges,
      previousOutstandingSnapshot: data.previousOutstandingSnapshot.present
          ? data.previousOutstandingSnapshot.value
          : this.previousOutstandingSnapshot,
      currentBalanceSnapshot: data.currentBalanceSnapshot.present
          ? data.currentBalanceSnapshot.value
          : this.currentBalanceSnapshot,
      grandTotal: data.grandTotal.present
          ? data.grandTotal.value
          : this.grandTotal,
      amountPaid: data.amountPaid.present
          ? data.amountPaid.value
          : this.amountPaid,
      advanceApplied: data.advanceApplied.present
          ? data.advanceApplied.value
          : this.advanceApplied,
      gstEnabled: data.gstEnabled.present
          ? data.gstEnabled.value
          : this.gstEnabled,
      gstPercent: data.gstPercent.present
          ? data.gstPercent.value
          : this.gstPercent,
      taxableAmount: data.taxableAmount.present
          ? data.taxableAmount.value
          : this.taxableAmount,
      gstAmount: data.gstAmount.present ? data.gstAmount.value : this.gstAmount,
      remainingBalance: data.remainingBalance.present
          ? data.remainingBalance.value
          : this.remainingBalance,
      status: data.status.present ? data.status.value : this.status,
      voidReason: data.voidReason.present
          ? data.voidReason.value
          : this.voidReason,
      voidedAt: data.voidedAt.present ? data.voidedAt.value : this.voidedAt,
      isWholesaleBill: data.isWholesaleBill.present
          ? data.isWholesaleBill.value
          : this.isWholesaleBill,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BillEntity(')
          ..write('id: $id, ')
          ..write('billNumber: $billNumber, ')
          ..write('saleChannel: $saleChannel, ')
          ..write('customerId: $customerId, ')
          ..write('billDate: $billDate, ')
          ..write('subtotal: $subtotal, ')
          ..write('discount: $discount, ')
          ..write('otherCharges: $otherCharges, ')
          ..write('previousOutstandingSnapshot: $previousOutstandingSnapshot, ')
          ..write('currentBalanceSnapshot: $currentBalanceSnapshot, ')
          ..write('grandTotal: $grandTotal, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('advanceApplied: $advanceApplied, ')
          ..write('gstEnabled: $gstEnabled, ')
          ..write('gstPercent: $gstPercent, ')
          ..write('taxableAmount: $taxableAmount, ')
          ..write('gstAmount: $gstAmount, ')
          ..write('remainingBalance: $remainingBalance, ')
          ..write('status: $status, ')
          ..write('voidReason: $voidReason, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('isWholesaleBill: $isWholesaleBill, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    billNumber,
    saleChannel,
    customerId,
    billDate,
    subtotal,
    discount,
    otherCharges,
    previousOutstandingSnapshot,
    currentBalanceSnapshot,
    grandTotal,
    amountPaid,
    advanceApplied,
    gstEnabled,
    gstPercent,
    taxableAmount,
    gstAmount,
    remainingBalance,
    status,
    voidReason,
    voidedAt,
    isWholesaleBill,
    notes,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BillEntity &&
          other.id == this.id &&
          other.billNumber == this.billNumber &&
          other.saleChannel == this.saleChannel &&
          other.customerId == this.customerId &&
          other.billDate == this.billDate &&
          other.subtotal == this.subtotal &&
          other.discount == this.discount &&
          other.otherCharges == this.otherCharges &&
          other.previousOutstandingSnapshot ==
              this.previousOutstandingSnapshot &&
          other.currentBalanceSnapshot == this.currentBalanceSnapshot &&
          other.grandTotal == this.grandTotal &&
          other.amountPaid == this.amountPaid &&
          other.advanceApplied == this.advanceApplied &&
          other.gstEnabled == this.gstEnabled &&
          other.gstPercent == this.gstPercent &&
          other.taxableAmount == this.taxableAmount &&
          other.gstAmount == this.gstAmount &&
          other.remainingBalance == this.remainingBalance &&
          other.status == this.status &&
          other.voidReason == this.voidReason &&
          other.voidedAt == this.voidedAt &&
          other.isWholesaleBill == this.isWholesaleBill &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class BillsCompanion extends UpdateCompanion<BillEntity> {
  final Value<int> id;
  final Value<String> billNumber;
  final Value<String> saleChannel;
  final Value<int?> customerId;
  final Value<DateTime> billDate;
  final Value<double> subtotal;
  final Value<double> discount;
  final Value<double> otherCharges;
  final Value<double> previousOutstandingSnapshot;
  final Value<double?> currentBalanceSnapshot;
  final Value<double> grandTotal;
  final Value<double> amountPaid;
  final Value<double> advanceApplied;
  final Value<bool> gstEnabled;
  final Value<double?> gstPercent;
  final Value<double> taxableAmount;
  final Value<double> gstAmount;
  final Value<double> remainingBalance;
  final Value<String> status;
  final Value<String?> voidReason;
  final Value<DateTime?> voidedAt;
  final Value<bool> isWholesaleBill;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const BillsCompanion({
    this.id = const Value.absent(),
    this.billNumber = const Value.absent(),
    this.saleChannel = const Value.absent(),
    this.customerId = const Value.absent(),
    this.billDate = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.discount = const Value.absent(),
    this.otherCharges = const Value.absent(),
    this.previousOutstandingSnapshot = const Value.absent(),
    this.currentBalanceSnapshot = const Value.absent(),
    this.grandTotal = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.advanceApplied = const Value.absent(),
    this.gstEnabled = const Value.absent(),
    this.gstPercent = const Value.absent(),
    this.taxableAmount = const Value.absent(),
    this.gstAmount = const Value.absent(),
    this.remainingBalance = const Value.absent(),
    this.status = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.isWholesaleBill = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BillsCompanion.insert({
    this.id = const Value.absent(),
    required String billNumber,
    this.saleChannel = const Value.absent(),
    this.customerId = const Value.absent(),
    required DateTime billDate,
    required double subtotal,
    this.discount = const Value.absent(),
    this.otherCharges = const Value.absent(),
    this.previousOutstandingSnapshot = const Value.absent(),
    this.currentBalanceSnapshot = const Value.absent(),
    required double grandTotal,
    this.amountPaid = const Value.absent(),
    this.advanceApplied = const Value.absent(),
    this.gstEnabled = const Value.absent(),
    this.gstPercent = const Value.absent(),
    this.taxableAmount = const Value.absent(),
    this.gstAmount = const Value.absent(),
    required double remainingBalance,
    this.status = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.isWholesaleBill = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : billNumber = Value(billNumber),
       billDate = Value(billDate),
       subtotal = Value(subtotal),
       grandTotal = Value(grandTotal),
       remainingBalance = Value(remainingBalance);
  static Insertable<BillEntity> custom({
    Expression<int>? id,
    Expression<String>? billNumber,
    Expression<String>? saleChannel,
    Expression<int>? customerId,
    Expression<DateTime>? billDate,
    Expression<double>? subtotal,
    Expression<double>? discount,
    Expression<double>? otherCharges,
    Expression<double>? previousOutstandingSnapshot,
    Expression<double>? currentBalanceSnapshot,
    Expression<double>? grandTotal,
    Expression<double>? amountPaid,
    Expression<double>? advanceApplied,
    Expression<bool>? gstEnabled,
    Expression<double>? gstPercent,
    Expression<double>? taxableAmount,
    Expression<double>? gstAmount,
    Expression<double>? remainingBalance,
    Expression<String>? status,
    Expression<String>? voidReason,
    Expression<DateTime>? voidedAt,
    Expression<bool>? isWholesaleBill,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (billNumber != null) 'bill_number': billNumber,
      if (saleChannel != null) 'sale_channel': saleChannel,
      if (customerId != null) 'customer_id': customerId,
      if (billDate != null) 'bill_date': billDate,
      if (subtotal != null) 'subtotal': subtotal,
      if (discount != null) 'discount': discount,
      if (otherCharges != null) 'other_charges': otherCharges,
      if (previousOutstandingSnapshot != null)
        'previous_outstanding_snapshot': previousOutstandingSnapshot,
      if (currentBalanceSnapshot != null)
        'current_balance_snapshot': currentBalanceSnapshot,
      if (grandTotal != null) 'grand_total': grandTotal,
      if (amountPaid != null) 'amount_paid': amountPaid,
      if (advanceApplied != null) 'advance_applied': advanceApplied,
      if (gstEnabled != null) 'gst_enabled': gstEnabled,
      if (gstPercent != null) 'gst_percent': gstPercent,
      if (taxableAmount != null) 'taxable_amount': taxableAmount,
      if (gstAmount != null) 'gst_amount': gstAmount,
      if (remainingBalance != null) 'remaining_balance': remainingBalance,
      if (status != null) 'status': status,
      if (voidReason != null) 'void_reason': voidReason,
      if (voidedAt != null) 'voided_at': voidedAt,
      if (isWholesaleBill != null) 'is_wholesale_bill': isWholesaleBill,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BillsCompanion copyWith({
    Value<int>? id,
    Value<String>? billNumber,
    Value<String>? saleChannel,
    Value<int?>? customerId,
    Value<DateTime>? billDate,
    Value<double>? subtotal,
    Value<double>? discount,
    Value<double>? otherCharges,
    Value<double>? previousOutstandingSnapshot,
    Value<double?>? currentBalanceSnapshot,
    Value<double>? grandTotal,
    Value<double>? amountPaid,
    Value<double>? advanceApplied,
    Value<bool>? gstEnabled,
    Value<double?>? gstPercent,
    Value<double>? taxableAmount,
    Value<double>? gstAmount,
    Value<double>? remainingBalance,
    Value<String>? status,
    Value<String?>? voidReason,
    Value<DateTime?>? voidedAt,
    Value<bool>? isWholesaleBill,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return BillsCompanion(
      id: id ?? this.id,
      billNumber: billNumber ?? this.billNumber,
      saleChannel: saleChannel ?? this.saleChannel,
      customerId: customerId ?? this.customerId,
      billDate: billDate ?? this.billDate,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      otherCharges: otherCharges ?? this.otherCharges,
      previousOutstandingSnapshot:
          previousOutstandingSnapshot ?? this.previousOutstandingSnapshot,
      currentBalanceSnapshot:
          currentBalanceSnapshot ?? this.currentBalanceSnapshot,
      grandTotal: grandTotal ?? this.grandTotal,
      amountPaid: amountPaid ?? this.amountPaid,
      advanceApplied: advanceApplied ?? this.advanceApplied,
      gstEnabled: gstEnabled ?? this.gstEnabled,
      gstPercent: gstPercent ?? this.gstPercent,
      taxableAmount: taxableAmount ?? this.taxableAmount,
      gstAmount: gstAmount ?? this.gstAmount,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      status: status ?? this.status,
      voidReason: voidReason ?? this.voidReason,
      voidedAt: voidedAt ?? this.voidedAt,
      isWholesaleBill: isWholesaleBill ?? this.isWholesaleBill,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (billNumber.present) {
      map['bill_number'] = Variable<String>(billNumber.value);
    }
    if (saleChannel.present) {
      map['sale_channel'] = Variable<String>(saleChannel.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (billDate.present) {
      map['bill_date'] = Variable<DateTime>(billDate.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (discount.present) {
      map['discount'] = Variable<double>(discount.value);
    }
    if (otherCharges.present) {
      map['other_charges'] = Variable<double>(otherCharges.value);
    }
    if (previousOutstandingSnapshot.present) {
      map['previous_outstanding_snapshot'] = Variable<double>(
        previousOutstandingSnapshot.value,
      );
    }
    if (currentBalanceSnapshot.present) {
      map['current_balance_snapshot'] = Variable<double>(
        currentBalanceSnapshot.value,
      );
    }
    if (grandTotal.present) {
      map['grand_total'] = Variable<double>(grandTotal.value);
    }
    if (amountPaid.present) {
      map['amount_paid'] = Variable<double>(amountPaid.value);
    }
    if (advanceApplied.present) {
      map['advance_applied'] = Variable<double>(advanceApplied.value);
    }
    if (gstEnabled.present) {
      map['gst_enabled'] = Variable<bool>(gstEnabled.value);
    }
    if (gstPercent.present) {
      map['gst_percent'] = Variable<double>(gstPercent.value);
    }
    if (taxableAmount.present) {
      map['taxable_amount'] = Variable<double>(taxableAmount.value);
    }
    if (gstAmount.present) {
      map['gst_amount'] = Variable<double>(gstAmount.value);
    }
    if (remainingBalance.present) {
      map['remaining_balance'] = Variable<double>(remainingBalance.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (voidReason.present) {
      map['void_reason'] = Variable<String>(voidReason.value);
    }
    if (voidedAt.present) {
      map['voided_at'] = Variable<DateTime>(voidedAt.value);
    }
    if (isWholesaleBill.present) {
      map['is_wholesale_bill'] = Variable<bool>(isWholesaleBill.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BillsCompanion(')
          ..write('id: $id, ')
          ..write('billNumber: $billNumber, ')
          ..write('saleChannel: $saleChannel, ')
          ..write('customerId: $customerId, ')
          ..write('billDate: $billDate, ')
          ..write('subtotal: $subtotal, ')
          ..write('discount: $discount, ')
          ..write('otherCharges: $otherCharges, ')
          ..write('previousOutstandingSnapshot: $previousOutstandingSnapshot, ')
          ..write('currentBalanceSnapshot: $currentBalanceSnapshot, ')
          ..write('grandTotal: $grandTotal, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('advanceApplied: $advanceApplied, ')
          ..write('gstEnabled: $gstEnabled, ')
          ..write('gstPercent: $gstPercent, ')
          ..write('taxableAmount: $taxableAmount, ')
          ..write('gstAmount: $gstAmount, ')
          ..write('remainingBalance: $remainingBalance, ')
          ..write('status: $status, ')
          ..write('voidReason: $voidReason, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('isWholesaleBill: $isWholesaleBill, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BillItemsTable extends BillItems
    with TableInfo<$BillItemsTable, BillItemEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BillItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _billIdMeta = const VerificationMeta('billId');
  @override
  late final GeneratedColumn<int> billId = GeneratedColumn<int>(
    'bill_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sellingProductIdMeta = const VerificationMeta(
    'sellingProductId',
  );
  @override
  late final GeneratedColumn<int> sellingProductId = GeneratedColumn<int>(
    'selling_product_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
    'rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mrpRateAtSaleMeta = const VerificationMeta(
    'mrpRateAtSale',
  );
  @override
  late final GeneratedColumn<double> mrpRateAtSale = GeneratedColumn<double>(
    'mrp_rate_at_sale',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    billId,
    itemId,
    sellingProductId,
    productName,
    quantity,
    unit,
    rate,
    mrpRateAtSale,
    amount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bill_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<BillItemEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bill_id')) {
      context.handle(
        _billIdMeta,
        billId.isAcceptableOrUnknown(data['bill_id']!, _billIdMeta),
      );
    } else if (isInserting) {
      context.missing(_billIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    }
    if (data.containsKey('selling_product_id')) {
      context.handle(
        _sellingProductIdMeta,
        sellingProductId.isAcceptableOrUnknown(
          data['selling_product_id']!,
          _sellingProductIdMeta,
        ),
      );
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    if (data.containsKey('mrp_rate_at_sale')) {
      context.handle(
        _mrpRateAtSaleMeta,
        mrpRateAtSale.isAcceptableOrUnknown(
          data['mrp_rate_at_sale']!,
          _mrpRateAtSaleMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BillItemEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BillItemEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      billId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bill_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      ),
      sellingProductId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selling_product_id'],
      ),
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate'],
      )!,
      mrpRateAtSale: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mrp_rate_at_sale'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
    );
  }

  @override
  $BillItemsTable createAlias(String alias) {
    return $BillItemsTable(attachedDatabase, alias);
  }
}

class BillItemEntity extends DataClass implements Insertable<BillItemEntity> {
  final int id;
  final int billId;
  final int? itemId;
  final int? sellingProductId;
  final String? productName;
  final double quantity;
  final String unit;
  final double rate;
  final double? mrpRateAtSale;
  final double amount;
  const BillItemEntity({
    required this.id,
    required this.billId,
    this.itemId,
    this.sellingProductId,
    this.productName,
    required this.quantity,
    required this.unit,
    required this.rate,
    this.mrpRateAtSale,
    required this.amount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bill_id'] = Variable<int>(billId);
    if (!nullToAbsent || itemId != null) {
      map['item_id'] = Variable<int>(itemId);
    }
    if (!nullToAbsent || sellingProductId != null) {
      map['selling_product_id'] = Variable<int>(sellingProductId);
    }
    if (!nullToAbsent || productName != null) {
      map['product_name'] = Variable<String>(productName);
    }
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    map['rate'] = Variable<double>(rate);
    if (!nullToAbsent || mrpRateAtSale != null) {
      map['mrp_rate_at_sale'] = Variable<double>(mrpRateAtSale);
    }
    map['amount'] = Variable<double>(amount);
    return map;
  }

  BillItemsCompanion toCompanion(bool nullToAbsent) {
    return BillItemsCompanion(
      id: Value(id),
      billId: Value(billId),
      itemId: itemId == null && nullToAbsent
          ? const Value.absent()
          : Value(itemId),
      sellingProductId: sellingProductId == null && nullToAbsent
          ? const Value.absent()
          : Value(sellingProductId),
      productName: productName == null && nullToAbsent
          ? const Value.absent()
          : Value(productName),
      quantity: Value(quantity),
      unit: Value(unit),
      rate: Value(rate),
      mrpRateAtSale: mrpRateAtSale == null && nullToAbsent
          ? const Value.absent()
          : Value(mrpRateAtSale),
      amount: Value(amount),
    );
  }

  factory BillItemEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BillItemEntity(
      id: serializer.fromJson<int>(json['id']),
      billId: serializer.fromJson<int>(json['billId']),
      itemId: serializer.fromJson<int?>(json['itemId']),
      sellingProductId: serializer.fromJson<int?>(json['sellingProductId']),
      productName: serializer.fromJson<String?>(json['productName']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      rate: serializer.fromJson<double>(json['rate']),
      mrpRateAtSale: serializer.fromJson<double?>(json['mrpRateAtSale']),
      amount: serializer.fromJson<double>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'billId': serializer.toJson<int>(billId),
      'itemId': serializer.toJson<int?>(itemId),
      'sellingProductId': serializer.toJson<int?>(sellingProductId),
      'productName': serializer.toJson<String?>(productName),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'rate': serializer.toJson<double>(rate),
      'mrpRateAtSale': serializer.toJson<double?>(mrpRateAtSale),
      'amount': serializer.toJson<double>(amount),
    };
  }

  BillItemEntity copyWith({
    int? id,
    int? billId,
    Value<int?> itemId = const Value.absent(),
    Value<int?> sellingProductId = const Value.absent(),
    Value<String?> productName = const Value.absent(),
    double? quantity,
    String? unit,
    double? rate,
    Value<double?> mrpRateAtSale = const Value.absent(),
    double? amount,
  }) => BillItemEntity(
    id: id ?? this.id,
    billId: billId ?? this.billId,
    itemId: itemId.present ? itemId.value : this.itemId,
    sellingProductId: sellingProductId.present
        ? sellingProductId.value
        : this.sellingProductId,
    productName: productName.present ? productName.value : this.productName,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    rate: rate ?? this.rate,
    mrpRateAtSale: mrpRateAtSale.present
        ? mrpRateAtSale.value
        : this.mrpRateAtSale,
    amount: amount ?? this.amount,
  );
  BillItemEntity copyWithCompanion(BillItemsCompanion data) {
    return BillItemEntity(
      id: data.id.present ? data.id.value : this.id,
      billId: data.billId.present ? data.billId.value : this.billId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      sellingProductId: data.sellingProductId.present
          ? data.sellingProductId.value
          : this.sellingProductId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      rate: data.rate.present ? data.rate.value : this.rate,
      mrpRateAtSale: data.mrpRateAtSale.present
          ? data.mrpRateAtSale.value
          : this.mrpRateAtSale,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BillItemEntity(')
          ..write('id: $id, ')
          ..write('billId: $billId, ')
          ..write('itemId: $itemId, ')
          ..write('sellingProductId: $sellingProductId, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('rate: $rate, ')
          ..write('mrpRateAtSale: $mrpRateAtSale, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    billId,
    itemId,
    sellingProductId,
    productName,
    quantity,
    unit,
    rate,
    mrpRateAtSale,
    amount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BillItemEntity &&
          other.id == this.id &&
          other.billId == this.billId &&
          other.itemId == this.itemId &&
          other.sellingProductId == this.sellingProductId &&
          other.productName == this.productName &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.rate == this.rate &&
          other.mrpRateAtSale == this.mrpRateAtSale &&
          other.amount == this.amount);
}

class BillItemsCompanion extends UpdateCompanion<BillItemEntity> {
  final Value<int> id;
  final Value<int> billId;
  final Value<int?> itemId;
  final Value<int?> sellingProductId;
  final Value<String?> productName;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<double> rate;
  final Value<double?> mrpRateAtSale;
  final Value<double> amount;
  const BillItemsCompanion({
    this.id = const Value.absent(),
    this.billId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.sellingProductId = const Value.absent(),
    this.productName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.rate = const Value.absent(),
    this.mrpRateAtSale = const Value.absent(),
    this.amount = const Value.absent(),
  });
  BillItemsCompanion.insert({
    this.id = const Value.absent(),
    required int billId,
    this.itemId = const Value.absent(),
    this.sellingProductId = const Value.absent(),
    this.productName = const Value.absent(),
    required double quantity,
    required String unit,
    required double rate,
    this.mrpRateAtSale = const Value.absent(),
    required double amount,
  }) : billId = Value(billId),
       quantity = Value(quantity),
       unit = Value(unit),
       rate = Value(rate),
       amount = Value(amount);
  static Insertable<BillItemEntity> custom({
    Expression<int>? id,
    Expression<int>? billId,
    Expression<int>? itemId,
    Expression<int>? sellingProductId,
    Expression<String>? productName,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<double>? rate,
    Expression<double>? mrpRateAtSale,
    Expression<double>? amount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (billId != null) 'bill_id': billId,
      if (itemId != null) 'item_id': itemId,
      if (sellingProductId != null) 'selling_product_id': sellingProductId,
      if (productName != null) 'product_name': productName,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (rate != null) 'rate': rate,
      if (mrpRateAtSale != null) 'mrp_rate_at_sale': mrpRateAtSale,
      if (amount != null) 'amount': amount,
    });
  }

  BillItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? billId,
    Value<int?>? itemId,
    Value<int?>? sellingProductId,
    Value<String?>? productName,
    Value<double>? quantity,
    Value<String>? unit,
    Value<double>? rate,
    Value<double?>? mrpRateAtSale,
    Value<double>? amount,
  }) {
    return BillItemsCompanion(
      id: id ?? this.id,
      billId: billId ?? this.billId,
      itemId: itemId ?? this.itemId,
      sellingProductId: sellingProductId ?? this.sellingProductId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      rate: rate ?? this.rate,
      mrpRateAtSale: mrpRateAtSale ?? this.mrpRateAtSale,
      amount: amount ?? this.amount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (billId.present) {
      map['bill_id'] = Variable<int>(billId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (sellingProductId.present) {
      map['selling_product_id'] = Variable<int>(sellingProductId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    if (mrpRateAtSale.present) {
      map['mrp_rate_at_sale'] = Variable<double>(mrpRateAtSale.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BillItemsCompanion(')
          ..write('id: $id, ')
          ..write('billId: $billId, ')
          ..write('itemId: $itemId, ')
          ..write('sellingProductId: $sellingProductId, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('rate: $rate, ')
          ..write('mrpRateAtSale: $mrpRateAtSale, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments
    with TableInfo<$PaymentsTable, PaymentEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _billIdMeta = const VerificationMeta('billId');
  @override
  late final GeneratedColumn<int> billId = GeneratedColumn<int>(
    'bill_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('bill_payment'),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    billId,
    amount,
    method,
    type,
    date,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('bill_id')) {
      context.handle(
        _billIdMeta,
        billId.isAcceptableOrUnknown(data['bill_id']!, _billIdMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      )!,
      billId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bill_id'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class PaymentEntity extends DataClass implements Insertable<PaymentEntity> {
  final int id;
  final int customerId;
  final int? billId;
  final double amount;
  final String method;
  final String type;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
  const PaymentEntity({
    required this.id,
    required this.customerId,
    this.billId,
    required this.amount,
    required this.method,
    required this.type,
    required this.date,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_id'] = Variable<int>(customerId);
    if (!nullToAbsent || billId != null) {
      map['bill_id'] = Variable<int>(billId);
    }
    map['amount'] = Variable<double>(amount);
    map['method'] = Variable<String>(method);
    map['type'] = Variable<String>(type);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      customerId: Value(customerId),
      billId: billId == null && nullToAbsent
          ? const Value.absent()
          : Value(billId),
      amount: Value(amount),
      method: Value(method),
      type: Value(type),
      date: Value(date),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory PaymentEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentEntity(
      id: serializer.fromJson<int>(json['id']),
      customerId: serializer.fromJson<int>(json['customerId']),
      billId: serializer.fromJson<int?>(json['billId']),
      amount: serializer.fromJson<double>(json['amount']),
      method: serializer.fromJson<String>(json['method']),
      type: serializer.fromJson<String>(json['type']),
      date: serializer.fromJson<DateTime>(json['date']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerId': serializer.toJson<int>(customerId),
      'billId': serializer.toJson<int?>(billId),
      'amount': serializer.toJson<double>(amount),
      'method': serializer.toJson<String>(method),
      'type': serializer.toJson<String>(type),
      'date': serializer.toJson<DateTime>(date),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PaymentEntity copyWith({
    int? id,
    int? customerId,
    Value<int?> billId = const Value.absent(),
    double? amount,
    String? method,
    String? type,
    DateTime? date,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => PaymentEntity(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    billId: billId.present ? billId.value : this.billId,
    amount: amount ?? this.amount,
    method: method ?? this.method,
    type: type ?? this.type,
    date: date ?? this.date,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  PaymentEntity copyWithCompanion(PaymentsCompanion data) {
    return PaymentEntity(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      billId: data.billId.present ? data.billId.value : this.billId,
      amount: data.amount.present ? data.amount.value : this.amount,
      method: data.method.present ? data.method.value : this.method,
      type: data.type.present ? data.type.value : this.type,
      date: data.date.present ? data.date.value : this.date,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentEntity(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('billId: $billId, ')
          ..write('amount: $amount, ')
          ..write('method: $method, ')
          ..write('type: $type, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    billId,
    amount,
    method,
    type,
    date,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentEntity &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.billId == this.billId &&
          other.amount == this.amount &&
          other.method == this.method &&
          other.type == this.type &&
          other.date == this.date &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class PaymentsCompanion extends UpdateCompanion<PaymentEntity> {
  final Value<int> id;
  final Value<int> customerId;
  final Value<int?> billId;
  final Value<double> amount;
  final Value<String> method;
  final Value<String> type;
  final Value<DateTime> date;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.billId = const Value.absent(),
    this.amount = const Value.absent(),
    this.method = const Value.absent(),
    this.type = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PaymentsCompanion.insert({
    this.id = const Value.absent(),
    required int customerId,
    this.billId = const Value.absent(),
    required double amount,
    required String method,
    this.type = const Value.absent(),
    required DateTime date,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : customerId = Value(customerId),
       amount = Value(amount),
       method = Value(method),
       date = Value(date);
  static Insertable<PaymentEntity> custom({
    Expression<int>? id,
    Expression<int>? customerId,
    Expression<int>? billId,
    Expression<double>? amount,
    Expression<String>? method,
    Expression<String>? type,
    Expression<DateTime>? date,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (billId != null) 'bill_id': billId,
      if (amount != null) 'amount': amount,
      if (method != null) 'method': method,
      if (type != null) 'type': type,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PaymentsCompanion copyWith({
    Value<int>? id,
    Value<int>? customerId,
    Value<int?>? billId,
    Value<double>? amount,
    Value<String>? method,
    Value<String>? type,
    Value<DateTime>? date,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      billId: billId ?? this.billId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      type: type ?? this.type,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (billId.present) {
      map['bill_id'] = Variable<int>(billId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('billId: $billId, ')
          ..write('amount: $amount, ')
          ..write('method: $method, ')
          ..write('type: $type, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $LedgerEntriesTable extends LedgerEntries
    with TableInfo<$LedgerEntriesTable, LedgerEntryEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceIdMeta = const VerificationMeta(
    'referenceId',
  );
  @override
  late final GeneratedColumn<int> referenceId = GeneratedColumn<int>(
    'reference_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _debitMeta = const VerificationMeta('debit');
  @override
  late final GeneratedColumn<double> debit = GeneratedColumn<double>(
    'debit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _creditMeta = const VerificationMeta('credit');
  @override
  late final GeneratedColumn<double> credit = GeneratedColumn<double>(
    'credit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _runningBalanceMeta = const VerificationMeta(
    'runningBalance',
  );
  @override
  late final GeneratedColumn<double> runningBalance = GeneratedColumn<double>(
    'running_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    date,
    type,
    referenceId,
    debit,
    credit,
    runningBalance,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LedgerEntryEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('reference_id')) {
      context.handle(
        _referenceIdMeta,
        referenceId.isAcceptableOrUnknown(
          data['reference_id']!,
          _referenceIdMeta,
        ),
      );
    }
    if (data.containsKey('debit')) {
      context.handle(
        _debitMeta,
        debit.isAcceptableOrUnknown(data['debit']!, _debitMeta),
      );
    }
    if (data.containsKey('credit')) {
      context.handle(
        _creditMeta,
        credit.isAcceptableOrUnknown(data['credit']!, _creditMeta),
      );
    }
    if (data.containsKey('running_balance')) {
      context.handle(
        _runningBalanceMeta,
        runningBalance.isAcceptableOrUnknown(
          data['running_balance']!,
          _runningBalanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_runningBalanceMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerEntryEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerEntryEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      referenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reference_id'],
      ),
      debit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}debit'],
      )!,
      credit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credit'],
      )!,
      runningBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}running_balance'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LedgerEntriesTable createAlias(String alias) {
    return $LedgerEntriesTable(attachedDatabase, alias);
  }
}

class LedgerEntryEntity extends DataClass
    implements Insertable<LedgerEntryEntity> {
  final int id;
  final int customerId;
  final DateTime date;
  final String type;
  final int? referenceId;
  final double debit;
  final double credit;
  final double runningBalance;
  final DateTime createdAt;
  const LedgerEntryEntity({
    required this.id,
    required this.customerId,
    required this.date,
    required this.type,
    this.referenceId,
    required this.debit,
    required this.credit,
    required this.runningBalance,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_id'] = Variable<int>(customerId);
    map['date'] = Variable<DateTime>(date);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || referenceId != null) {
      map['reference_id'] = Variable<int>(referenceId);
    }
    map['debit'] = Variable<double>(debit);
    map['credit'] = Variable<double>(credit);
    map['running_balance'] = Variable<double>(runningBalance);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LedgerEntriesCompanion toCompanion(bool nullToAbsent) {
    return LedgerEntriesCompanion(
      id: Value(id),
      customerId: Value(customerId),
      date: Value(date),
      type: Value(type),
      referenceId: referenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceId),
      debit: Value(debit),
      credit: Value(credit),
      runningBalance: Value(runningBalance),
      createdAt: Value(createdAt),
    );
  }

  factory LedgerEntryEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerEntryEntity(
      id: serializer.fromJson<int>(json['id']),
      customerId: serializer.fromJson<int>(json['customerId']),
      date: serializer.fromJson<DateTime>(json['date']),
      type: serializer.fromJson<String>(json['type']),
      referenceId: serializer.fromJson<int?>(json['referenceId']),
      debit: serializer.fromJson<double>(json['debit']),
      credit: serializer.fromJson<double>(json['credit']),
      runningBalance: serializer.fromJson<double>(json['runningBalance']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerId': serializer.toJson<int>(customerId),
      'date': serializer.toJson<DateTime>(date),
      'type': serializer.toJson<String>(type),
      'referenceId': serializer.toJson<int?>(referenceId),
      'debit': serializer.toJson<double>(debit),
      'credit': serializer.toJson<double>(credit),
      'runningBalance': serializer.toJson<double>(runningBalance),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LedgerEntryEntity copyWith({
    int? id,
    int? customerId,
    DateTime? date,
    String? type,
    Value<int?> referenceId = const Value.absent(),
    double? debit,
    double? credit,
    double? runningBalance,
    DateTime? createdAt,
  }) => LedgerEntryEntity(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    date: date ?? this.date,
    type: type ?? this.type,
    referenceId: referenceId.present ? referenceId.value : this.referenceId,
    debit: debit ?? this.debit,
    credit: credit ?? this.credit,
    runningBalance: runningBalance ?? this.runningBalance,
    createdAt: createdAt ?? this.createdAt,
  );
  LedgerEntryEntity copyWithCompanion(LedgerEntriesCompanion data) {
    return LedgerEntryEntity(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      referenceId: data.referenceId.present
          ? data.referenceId.value
          : this.referenceId,
      debit: data.debit.present ? data.debit.value : this.debit,
      credit: data.credit.present ? data.credit.value : this.credit,
      runningBalance: data.runningBalance.present
          ? data.runningBalance.value
          : this.runningBalance,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntryEntity(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('referenceId: $referenceId, ')
          ..write('debit: $debit, ')
          ..write('credit: $credit, ')
          ..write('runningBalance: $runningBalance, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    date,
    type,
    referenceId,
    debit,
    credit,
    runningBalance,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerEntryEntity &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.date == this.date &&
          other.type == this.type &&
          other.referenceId == this.referenceId &&
          other.debit == this.debit &&
          other.credit == this.credit &&
          other.runningBalance == this.runningBalance &&
          other.createdAt == this.createdAt);
}

class LedgerEntriesCompanion extends UpdateCompanion<LedgerEntryEntity> {
  final Value<int> id;
  final Value<int> customerId;
  final Value<DateTime> date;
  final Value<String> type;
  final Value<int?> referenceId;
  final Value<double> debit;
  final Value<double> credit;
  final Value<double> runningBalance;
  final Value<DateTime> createdAt;
  const LedgerEntriesCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.debit = const Value.absent(),
    this.credit = const Value.absent(),
    this.runningBalance = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LedgerEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int customerId,
    required DateTime date,
    required String type,
    this.referenceId = const Value.absent(),
    this.debit = const Value.absent(),
    this.credit = const Value.absent(),
    required double runningBalance,
    this.createdAt = const Value.absent(),
  }) : customerId = Value(customerId),
       date = Value(date),
       type = Value(type),
       runningBalance = Value(runningBalance);
  static Insertable<LedgerEntryEntity> custom({
    Expression<int>? id,
    Expression<int>? customerId,
    Expression<DateTime>? date,
    Expression<String>? type,
    Expression<int>? referenceId,
    Expression<double>? debit,
    Expression<double>? credit,
    Expression<double>? runningBalance,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (referenceId != null) 'reference_id': referenceId,
      if (debit != null) 'debit': debit,
      if (credit != null) 'credit': credit,
      if (runningBalance != null) 'running_balance': runningBalance,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LedgerEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? customerId,
    Value<DateTime>? date,
    Value<String>? type,
    Value<int?>? referenceId,
    Value<double>? debit,
    Value<double>? credit,
    Value<double>? runningBalance,
    Value<DateTime>? createdAt,
  }) {
    return LedgerEntriesCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      date: date ?? this.date,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
      runningBalance: runningBalance ?? this.runningBalance,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<int>(referenceId.value);
    }
    if (debit.present) {
      map['debit'] = Variable<double>(debit.value);
    }
    if (credit.present) {
      map['credit'] = Variable<double>(credit.value);
    }
    if (runningBalance.present) {
      map['running_balance'] = Variable<double>(runningBalance.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntriesCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('referenceId: $referenceId, ')
          ..write('debit: $debit, ')
          ..write('credit: $credit, ')
          ..write('runningBalance: $runningBalance, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, SettingEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingEntity(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }
}

class SettingEntity extends DataClass implements Insertable<SettingEntity> {
  final String key;
  final String? value;
  const SettingEntity({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory SettingEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingEntity(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  SettingEntity copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => SettingEntity(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  SettingEntity copyWithCompanion(SettingsTableCompanion data) {
    return SettingEntity(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingEntity(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingEntity &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsTableCompanion extends UpdateCompanion<SettingEntity> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const SettingsTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<SettingEntity> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsTableCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return SettingsTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkWorkEntriesTable extends WorkWorkEntries
    with TableInfo<$WorkWorkEntriesTable, WorkWorkEntryEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkWorkEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _workerIdMeta = const VerificationMeta(
    'workerId',
  );
  @override
  late final GeneratedColumn<int> workerId = GeneratedColumn<int>(
    'worker_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workDescriptionMeta = const VerificationMeta(
    'workDescription',
  );
  @override
  late final GeneratedColumn<String> workDescription = GeneratedColumn<String>(
    'work_description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hoursMeta = const VerificationMeta('hours');
  @override
  late final GeneratedColumn<double> hours = GeneratedColumn<double>(
    'hours',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hourRateMeta = const VerificationMeta(
    'hourRate',
  );
  @override
  late final GeneratedColumn<double> hourRate = GeneratedColumn<double>(
    'hour_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hourAmountMeta = const VerificationMeta(
    'hourAmount',
  );
  @override
  late final GeneratedColumn<double> hourAmount = GeneratedColumn<double>(
    'hour_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _nagQtyMeta = const VerificationMeta('nagQty');
  @override
  late final GeneratedColumn<double> nagQty = GeneratedColumn<double>(
    'nag_qty',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nagRateMeta = const VerificationMeta(
    'nagRate',
  );
  @override
  late final GeneratedColumn<double> nagRate = GeneratedColumn<double>(
    'nag_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nagAmountMeta = const VerificationMeta(
    'nagAmount',
  );
  @override
  late final GeneratedColumn<double> nagAmount = GeneratedColumn<double>(
    'nag_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _advanceMeta = const VerificationMeta(
    'advance',
  );
  @override
  late final GeneratedColumn<double> advance = GeneratedColumn<double>(
    'advance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _finalPayableMeta = const VerificationMeta(
    'finalPayable',
  );
  @override
  late final GeneratedColumn<double> finalPayable = GeneratedColumn<double>(
    'final_payable',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workerId,
    date,
    workDescription,
    hours,
    hourRate,
    hourAmount,
    nagQty,
    nagRate,
    nagAmount,
    totalAmount,
    advance,
    finalPayable,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_work_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkWorkEntryEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('worker_id')) {
      context.handle(
        _workerIdMeta,
        workerId.isAcceptableOrUnknown(data['worker_id']!, _workerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workerIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('work_description')) {
      context.handle(
        _workDescriptionMeta,
        workDescription.isAcceptableOrUnknown(
          data['work_description']!,
          _workDescriptionMeta,
        ),
      );
    }
    if (data.containsKey('hours')) {
      context.handle(
        _hoursMeta,
        hours.isAcceptableOrUnknown(data['hours']!, _hoursMeta),
      );
    }
    if (data.containsKey('hour_rate')) {
      context.handle(
        _hourRateMeta,
        hourRate.isAcceptableOrUnknown(data['hour_rate']!, _hourRateMeta),
      );
    }
    if (data.containsKey('hour_amount')) {
      context.handle(
        _hourAmountMeta,
        hourAmount.isAcceptableOrUnknown(data['hour_amount']!, _hourAmountMeta),
      );
    }
    if (data.containsKey('nag_qty')) {
      context.handle(
        _nagQtyMeta,
        nagQty.isAcceptableOrUnknown(data['nag_qty']!, _nagQtyMeta),
      );
    }
    if (data.containsKey('nag_rate')) {
      context.handle(
        _nagRateMeta,
        nagRate.isAcceptableOrUnknown(data['nag_rate']!, _nagRateMeta),
      );
    }
    if (data.containsKey('nag_amount')) {
      context.handle(
        _nagAmountMeta,
        nagAmount.isAcceptableOrUnknown(data['nag_amount']!, _nagAmountMeta),
      );
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    }
    if (data.containsKey('advance')) {
      context.handle(
        _advanceMeta,
        advance.isAcceptableOrUnknown(data['advance']!, _advanceMeta),
      );
    }
    if (data.containsKey('final_payable')) {
      context.handle(
        _finalPayableMeta,
        finalPayable.isAcceptableOrUnknown(
          data['final_payable']!,
          _finalPayableMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkWorkEntryEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkWorkEntryEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}worker_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      workDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_description'],
      ),
      hours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hours'],
      ),
      hourRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hour_rate'],
      ),
      hourAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hour_amount'],
      )!,
      nagQty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}nag_qty'],
      ),
      nagRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}nag_rate'],
      ),
      nagAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}nag_amount'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      advance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}advance'],
      )!,
      finalPayable: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}final_payable'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WorkWorkEntriesTable createAlias(String alias) {
    return $WorkWorkEntriesTable(attachedDatabase, alias);
  }
}

class WorkWorkEntryEntity extends DataClass
    implements Insertable<WorkWorkEntryEntity> {
  final int id;
  final int workerId;
  final DateTime date;
  final String? workDescription;
  final double? hours;
  final double? hourRate;
  final double hourAmount;
  final double? nagQty;
  final double? nagRate;
  final double nagAmount;
  final double totalAmount;
  final double advance;
  final double finalPayable;
  final String? notes;
  final DateTime createdAt;
  const WorkWorkEntryEntity({
    required this.id,
    required this.workerId,
    required this.date,
    this.workDescription,
    this.hours,
    this.hourRate,
    required this.hourAmount,
    this.nagQty,
    this.nagRate,
    required this.nagAmount,
    required this.totalAmount,
    required this.advance,
    required this.finalPayable,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['worker_id'] = Variable<int>(workerId);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || workDescription != null) {
      map['work_description'] = Variable<String>(workDescription);
    }
    if (!nullToAbsent || hours != null) {
      map['hours'] = Variable<double>(hours);
    }
    if (!nullToAbsent || hourRate != null) {
      map['hour_rate'] = Variable<double>(hourRate);
    }
    map['hour_amount'] = Variable<double>(hourAmount);
    if (!nullToAbsent || nagQty != null) {
      map['nag_qty'] = Variable<double>(nagQty);
    }
    if (!nullToAbsent || nagRate != null) {
      map['nag_rate'] = Variable<double>(nagRate);
    }
    map['nag_amount'] = Variable<double>(nagAmount);
    map['total_amount'] = Variable<double>(totalAmount);
    map['advance'] = Variable<double>(advance);
    map['final_payable'] = Variable<double>(finalPayable);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WorkWorkEntriesCompanion toCompanion(bool nullToAbsent) {
    return WorkWorkEntriesCompanion(
      id: Value(id),
      workerId: Value(workerId),
      date: Value(date),
      workDescription: workDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(workDescription),
      hours: hours == null && nullToAbsent
          ? const Value.absent()
          : Value(hours),
      hourRate: hourRate == null && nullToAbsent
          ? const Value.absent()
          : Value(hourRate),
      hourAmount: Value(hourAmount),
      nagQty: nagQty == null && nullToAbsent
          ? const Value.absent()
          : Value(nagQty),
      nagRate: nagRate == null && nullToAbsent
          ? const Value.absent()
          : Value(nagRate),
      nagAmount: Value(nagAmount),
      totalAmount: Value(totalAmount),
      advance: Value(advance),
      finalPayable: Value(finalPayable),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory WorkWorkEntryEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkWorkEntryEntity(
      id: serializer.fromJson<int>(json['id']),
      workerId: serializer.fromJson<int>(json['workerId']),
      date: serializer.fromJson<DateTime>(json['date']),
      workDescription: serializer.fromJson<String?>(json['workDescription']),
      hours: serializer.fromJson<double?>(json['hours']),
      hourRate: serializer.fromJson<double?>(json['hourRate']),
      hourAmount: serializer.fromJson<double>(json['hourAmount']),
      nagQty: serializer.fromJson<double?>(json['nagQty']),
      nagRate: serializer.fromJson<double?>(json['nagRate']),
      nagAmount: serializer.fromJson<double>(json['nagAmount']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      advance: serializer.fromJson<double>(json['advance']),
      finalPayable: serializer.fromJson<double>(json['finalPayable']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workerId': serializer.toJson<int>(workerId),
      'date': serializer.toJson<DateTime>(date),
      'workDescription': serializer.toJson<String?>(workDescription),
      'hours': serializer.toJson<double?>(hours),
      'hourRate': serializer.toJson<double?>(hourRate),
      'hourAmount': serializer.toJson<double>(hourAmount),
      'nagQty': serializer.toJson<double?>(nagQty),
      'nagRate': serializer.toJson<double?>(nagRate),
      'nagAmount': serializer.toJson<double>(nagAmount),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'advance': serializer.toJson<double>(advance),
      'finalPayable': serializer.toJson<double>(finalPayable),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WorkWorkEntryEntity copyWith({
    int? id,
    int? workerId,
    DateTime? date,
    Value<String?> workDescription = const Value.absent(),
    Value<double?> hours = const Value.absent(),
    Value<double?> hourRate = const Value.absent(),
    double? hourAmount,
    Value<double?> nagQty = const Value.absent(),
    Value<double?> nagRate = const Value.absent(),
    double? nagAmount,
    double? totalAmount,
    double? advance,
    double? finalPayable,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => WorkWorkEntryEntity(
    id: id ?? this.id,
    workerId: workerId ?? this.workerId,
    date: date ?? this.date,
    workDescription: workDescription.present
        ? workDescription.value
        : this.workDescription,
    hours: hours.present ? hours.value : this.hours,
    hourRate: hourRate.present ? hourRate.value : this.hourRate,
    hourAmount: hourAmount ?? this.hourAmount,
    nagQty: nagQty.present ? nagQty.value : this.nagQty,
    nagRate: nagRate.present ? nagRate.value : this.nagRate,
    nagAmount: nagAmount ?? this.nagAmount,
    totalAmount: totalAmount ?? this.totalAmount,
    advance: advance ?? this.advance,
    finalPayable: finalPayable ?? this.finalPayable,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  WorkWorkEntryEntity copyWithCompanion(WorkWorkEntriesCompanion data) {
    return WorkWorkEntryEntity(
      id: data.id.present ? data.id.value : this.id,
      workerId: data.workerId.present ? data.workerId.value : this.workerId,
      date: data.date.present ? data.date.value : this.date,
      workDescription: data.workDescription.present
          ? data.workDescription.value
          : this.workDescription,
      hours: data.hours.present ? data.hours.value : this.hours,
      hourRate: data.hourRate.present ? data.hourRate.value : this.hourRate,
      hourAmount: data.hourAmount.present
          ? data.hourAmount.value
          : this.hourAmount,
      nagQty: data.nagQty.present ? data.nagQty.value : this.nagQty,
      nagRate: data.nagRate.present ? data.nagRate.value : this.nagRate,
      nagAmount: data.nagAmount.present ? data.nagAmount.value : this.nagAmount,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      advance: data.advance.present ? data.advance.value : this.advance,
      finalPayable: data.finalPayable.present
          ? data.finalPayable.value
          : this.finalPayable,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkWorkEntryEntity(')
          ..write('id: $id, ')
          ..write('workerId: $workerId, ')
          ..write('date: $date, ')
          ..write('workDescription: $workDescription, ')
          ..write('hours: $hours, ')
          ..write('hourRate: $hourRate, ')
          ..write('hourAmount: $hourAmount, ')
          ..write('nagQty: $nagQty, ')
          ..write('nagRate: $nagRate, ')
          ..write('nagAmount: $nagAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('advance: $advance, ')
          ..write('finalPayable: $finalPayable, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workerId,
    date,
    workDescription,
    hours,
    hourRate,
    hourAmount,
    nagQty,
    nagRate,
    nagAmount,
    totalAmount,
    advance,
    finalPayable,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkWorkEntryEntity &&
          other.id == this.id &&
          other.workerId == this.workerId &&
          other.date == this.date &&
          other.workDescription == this.workDescription &&
          other.hours == this.hours &&
          other.hourRate == this.hourRate &&
          other.hourAmount == this.hourAmount &&
          other.nagQty == this.nagQty &&
          other.nagRate == this.nagRate &&
          other.nagAmount == this.nagAmount &&
          other.totalAmount == this.totalAmount &&
          other.advance == this.advance &&
          other.finalPayable == this.finalPayable &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class WorkWorkEntriesCompanion extends UpdateCompanion<WorkWorkEntryEntity> {
  final Value<int> id;
  final Value<int> workerId;
  final Value<DateTime> date;
  final Value<String?> workDescription;
  final Value<double?> hours;
  final Value<double?> hourRate;
  final Value<double> hourAmount;
  final Value<double?> nagQty;
  final Value<double?> nagRate;
  final Value<double> nagAmount;
  final Value<double> totalAmount;
  final Value<double> advance;
  final Value<double> finalPayable;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const WorkWorkEntriesCompanion({
    this.id = const Value.absent(),
    this.workerId = const Value.absent(),
    this.date = const Value.absent(),
    this.workDescription = const Value.absent(),
    this.hours = const Value.absent(),
    this.hourRate = const Value.absent(),
    this.hourAmount = const Value.absent(),
    this.nagQty = const Value.absent(),
    this.nagRate = const Value.absent(),
    this.nagAmount = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.advance = const Value.absent(),
    this.finalPayable = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WorkWorkEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int workerId,
    required DateTime date,
    this.workDescription = const Value.absent(),
    this.hours = const Value.absent(),
    this.hourRate = const Value.absent(),
    this.hourAmount = const Value.absent(),
    this.nagQty = const Value.absent(),
    this.nagRate = const Value.absent(),
    this.nagAmount = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.advance = const Value.absent(),
    this.finalPayable = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : workerId = Value(workerId),
       date = Value(date);
  static Insertable<WorkWorkEntryEntity> custom({
    Expression<int>? id,
    Expression<int>? workerId,
    Expression<DateTime>? date,
    Expression<String>? workDescription,
    Expression<double>? hours,
    Expression<double>? hourRate,
    Expression<double>? hourAmount,
    Expression<double>? nagQty,
    Expression<double>? nagRate,
    Expression<double>? nagAmount,
    Expression<double>? totalAmount,
    Expression<double>? advance,
    Expression<double>? finalPayable,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workerId != null) 'worker_id': workerId,
      if (date != null) 'date': date,
      if (workDescription != null) 'work_description': workDescription,
      if (hours != null) 'hours': hours,
      if (hourRate != null) 'hour_rate': hourRate,
      if (hourAmount != null) 'hour_amount': hourAmount,
      if (nagQty != null) 'nag_qty': nagQty,
      if (nagRate != null) 'nag_rate': nagRate,
      if (nagAmount != null) 'nag_amount': nagAmount,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (advance != null) 'advance': advance,
      if (finalPayable != null) 'final_payable': finalPayable,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WorkWorkEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? workerId,
    Value<DateTime>? date,
    Value<String?>? workDescription,
    Value<double?>? hours,
    Value<double?>? hourRate,
    Value<double>? hourAmount,
    Value<double?>? nagQty,
    Value<double?>? nagRate,
    Value<double>? nagAmount,
    Value<double>? totalAmount,
    Value<double>? advance,
    Value<double>? finalPayable,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return WorkWorkEntriesCompanion(
      id: id ?? this.id,
      workerId: workerId ?? this.workerId,
      date: date ?? this.date,
      workDescription: workDescription ?? this.workDescription,
      hours: hours ?? this.hours,
      hourRate: hourRate ?? this.hourRate,
      hourAmount: hourAmount ?? this.hourAmount,
      nagQty: nagQty ?? this.nagQty,
      nagRate: nagRate ?? this.nagRate,
      nagAmount: nagAmount ?? this.nagAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      advance: advance ?? this.advance,
      finalPayable: finalPayable ?? this.finalPayable,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workerId.present) {
      map['worker_id'] = Variable<int>(workerId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (workDescription.present) {
      map['work_description'] = Variable<String>(workDescription.value);
    }
    if (hours.present) {
      map['hours'] = Variable<double>(hours.value);
    }
    if (hourRate.present) {
      map['hour_rate'] = Variable<double>(hourRate.value);
    }
    if (hourAmount.present) {
      map['hour_amount'] = Variable<double>(hourAmount.value);
    }
    if (nagQty.present) {
      map['nag_qty'] = Variable<double>(nagQty.value);
    }
    if (nagRate.present) {
      map['nag_rate'] = Variable<double>(nagRate.value);
    }
    if (nagAmount.present) {
      map['nag_amount'] = Variable<double>(nagAmount.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (advance.present) {
      map['advance'] = Variable<double>(advance.value);
    }
    if (finalPayable.present) {
      map['final_payable'] = Variable<double>(finalPayable.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkWorkEntriesCompanion(')
          ..write('id: $id, ')
          ..write('workerId: $workerId, ')
          ..write('date: $date, ')
          ..write('workDescription: $workDescription, ')
          ..write('hours: $hours, ')
          ..write('hourRate: $hourRate, ')
          ..write('hourAmount: $hourAmount, ')
          ..write('nagQty: $nagQty, ')
          ..write('nagRate: $nagRate, ')
          ..write('nagAmount: $nagAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('advance: $advance, ')
          ..write('finalPayable: $finalPayable, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WorkerCuttingEntriesTable extends WorkerCuttingEntries
    with TableInfo<$WorkerCuttingEntriesTable, WorkerCuttingEntryEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkerCuttingEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _workerIdMeta = const VerificationMeta(
    'workerId',
  );
  @override
  late final GeneratedColumn<int> workerId = GeneratedColumn<int>(
    'worker_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
    'rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  @override
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
    'remark',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workerId,
    itemId,
    date,
    quantity,
    rate,
    totalAmount,
    remark,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'worker_cutting_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkerCuttingEntryEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('worker_id')) {
      context.handle(
        _workerIdMeta,
        workerId.isAcceptableOrUnknown(data['worker_id']!, _workerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workerIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    }
    if (data.containsKey('remark')) {
      context.handle(
        _remarkMeta,
        remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkerCuttingEntryEntity map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkerCuttingEntryEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}worker_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      remark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remark'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WorkerCuttingEntriesTable createAlias(String alias) {
    return $WorkerCuttingEntriesTable(attachedDatabase, alias);
  }
}

class WorkerCuttingEntryEntity extends DataClass
    implements Insertable<WorkerCuttingEntryEntity> {
  final int id;
  final int workerId;
  final int itemId;
  final DateTime date;
  final double quantity;
  final double rate;
  final double totalAmount;
  final String? remark;
  final DateTime createdAt;
  const WorkerCuttingEntryEntity({
    required this.id,
    required this.workerId,
    required this.itemId,
    required this.date,
    required this.quantity,
    required this.rate,
    required this.totalAmount,
    this.remark,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['worker_id'] = Variable<int>(workerId);
    map['item_id'] = Variable<int>(itemId);
    map['date'] = Variable<DateTime>(date);
    map['quantity'] = Variable<double>(quantity);
    map['rate'] = Variable<double>(rate);
    map['total_amount'] = Variable<double>(totalAmount);
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WorkerCuttingEntriesCompanion toCompanion(bool nullToAbsent) {
    return WorkerCuttingEntriesCompanion(
      id: Value(id),
      workerId: Value(workerId),
      itemId: Value(itemId),
      date: Value(date),
      quantity: Value(quantity),
      rate: Value(rate),
      totalAmount: Value(totalAmount),
      remark: remark == null && nullToAbsent
          ? const Value.absent()
          : Value(remark),
      createdAt: Value(createdAt),
    );
  }

  factory WorkerCuttingEntryEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkerCuttingEntryEntity(
      id: serializer.fromJson<int>(json['id']),
      workerId: serializer.fromJson<int>(json['workerId']),
      itemId: serializer.fromJson<int>(json['itemId']),
      date: serializer.fromJson<DateTime>(json['date']),
      quantity: serializer.fromJson<double>(json['quantity']),
      rate: serializer.fromJson<double>(json['rate']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      remark: serializer.fromJson<String?>(json['remark']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workerId': serializer.toJson<int>(workerId),
      'itemId': serializer.toJson<int>(itemId),
      'date': serializer.toJson<DateTime>(date),
      'quantity': serializer.toJson<double>(quantity),
      'rate': serializer.toJson<double>(rate),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'remark': serializer.toJson<String?>(remark),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WorkerCuttingEntryEntity copyWith({
    int? id,
    int? workerId,
    int? itemId,
    DateTime? date,
    double? quantity,
    double? rate,
    double? totalAmount,
    Value<String?> remark = const Value.absent(),
    DateTime? createdAt,
  }) => WorkerCuttingEntryEntity(
    id: id ?? this.id,
    workerId: workerId ?? this.workerId,
    itemId: itemId ?? this.itemId,
    date: date ?? this.date,
    quantity: quantity ?? this.quantity,
    rate: rate ?? this.rate,
    totalAmount: totalAmount ?? this.totalAmount,
    remark: remark.present ? remark.value : this.remark,
    createdAt: createdAt ?? this.createdAt,
  );
  WorkerCuttingEntryEntity copyWithCompanion(
    WorkerCuttingEntriesCompanion data,
  ) {
    return WorkerCuttingEntryEntity(
      id: data.id.present ? data.id.value : this.id,
      workerId: data.workerId.present ? data.workerId.value : this.workerId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      date: data.date.present ? data.date.value : this.date,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      rate: data.rate.present ? data.rate.value : this.rate,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      remark: data.remark.present ? data.remark.value : this.remark,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkerCuttingEntryEntity(')
          ..write('id: $id, ')
          ..write('workerId: $workerId, ')
          ..write('itemId: $itemId, ')
          ..write('date: $date, ')
          ..write('quantity: $quantity, ')
          ..write('rate: $rate, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('remark: $remark, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workerId,
    itemId,
    date,
    quantity,
    rate,
    totalAmount,
    remark,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkerCuttingEntryEntity &&
          other.id == this.id &&
          other.workerId == this.workerId &&
          other.itemId == this.itemId &&
          other.date == this.date &&
          other.quantity == this.quantity &&
          other.rate == this.rate &&
          other.totalAmount == this.totalAmount &&
          other.remark == this.remark &&
          other.createdAt == this.createdAt);
}

class WorkerCuttingEntriesCompanion
    extends UpdateCompanion<WorkerCuttingEntryEntity> {
  final Value<int> id;
  final Value<int> workerId;
  final Value<int> itemId;
  final Value<DateTime> date;
  final Value<double> quantity;
  final Value<double> rate;
  final Value<double> totalAmount;
  final Value<String?> remark;
  final Value<DateTime> createdAt;
  const WorkerCuttingEntriesCompanion({
    this.id = const Value.absent(),
    this.workerId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.date = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rate = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.remark = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WorkerCuttingEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int workerId,
    required int itemId,
    required DateTime date,
    required double quantity,
    required double rate,
    this.totalAmount = const Value.absent(),
    this.remark = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : workerId = Value(workerId),
       itemId = Value(itemId),
       date = Value(date),
       quantity = Value(quantity),
       rate = Value(rate);
  static Insertable<WorkerCuttingEntryEntity> custom({
    Expression<int>? id,
    Expression<int>? workerId,
    Expression<int>? itemId,
    Expression<DateTime>? date,
    Expression<double>? quantity,
    Expression<double>? rate,
    Expression<double>? totalAmount,
    Expression<String>? remark,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workerId != null) 'worker_id': workerId,
      if (itemId != null) 'item_id': itemId,
      if (date != null) 'date': date,
      if (quantity != null) 'quantity': quantity,
      if (rate != null) 'rate': rate,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (remark != null) 'remark': remark,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WorkerCuttingEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? workerId,
    Value<int>? itemId,
    Value<DateTime>? date,
    Value<double>? quantity,
    Value<double>? rate,
    Value<double>? totalAmount,
    Value<String?>? remark,
    Value<DateTime>? createdAt,
  }) {
    return WorkerCuttingEntriesCompanion(
      id: id ?? this.id,
      workerId: workerId ?? this.workerId,
      itemId: itemId ?? this.itemId,
      date: date ?? this.date,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      totalAmount: totalAmount ?? this.totalAmount,
      remark: remark ?? this.remark,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workerId.present) {
      map['worker_id'] = Variable<int>(workerId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkerCuttingEntriesCompanion(')
          ..write('id: $id, ')
          ..write('workerId: $workerId, ')
          ..write('itemId: $itemId, ')
          ..write('date: $date, ')
          ..write('quantity: $quantity, ')
          ..write('rate: $rate, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('remark: $remark, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SellingProductsTable extends SellingProducts
    with TableInfo<$SellingProductsTable, SellingProductEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SellingProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _wholesalePriceMeta = const VerificationMeta(
    'wholesalePrice',
  );
  @override
  late final GeneratedColumn<double> wholesalePrice = GeneratedColumn<double>(
    'wholesale_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    price,
    wholesalePrice,
    photoPath,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'selling_products';
  @override
  VerificationContext validateIntegrity(
    Insertable<SellingProductEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    if (data.containsKey('wholesale_price')) {
      context.handle(
        _wholesalePriceMeta,
        wholesalePrice.isAcceptableOrUnknown(
          data['wholesale_price']!,
          _wholesalePriceMeta,
        ),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SellingProductEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SellingProductEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      wholesalePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}wholesale_price'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $SellingProductsTable createAlias(String alias) {
    return $SellingProductsTable(attachedDatabase, alias);
  }
}

class SellingProductEntity extends DataClass
    implements Insertable<SellingProductEntity> {
  final int id;
  final String name;
  final String? description;
  final double price;
  final double? wholesalePrice;
  final String? photoPath;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const SellingProductEntity({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.wholesalePrice,
    this.photoPath,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['price'] = Variable<double>(price);
    if (!nullToAbsent || wholesalePrice != null) {
      map['wholesale_price'] = Variable<double>(wholesalePrice);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  SellingProductsCompanion toCompanion(bool nullToAbsent) {
    return SellingProductsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      price: Value(price),
      wholesalePrice: wholesalePrice == null && nullToAbsent
          ? const Value.absent()
          : Value(wholesalePrice),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory SellingProductEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SellingProductEntity(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      price: serializer.fromJson<double>(json['price']),
      wholesalePrice: serializer.fromJson<double?>(json['wholesalePrice']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'price': serializer.toJson<double>(price),
      'wholesalePrice': serializer.toJson<double?>(wholesalePrice),
      'photoPath': serializer.toJson<String?>(photoPath),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  SellingProductEntity copyWith({
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    double? price,
    Value<double?> wholesalePrice = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => SellingProductEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    price: price ?? this.price,
    wholesalePrice: wholesalePrice.present
        ? wholesalePrice.value
        : this.wholesalePrice,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  SellingProductEntity copyWithCompanion(SellingProductsCompanion data) {
    return SellingProductEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      price: data.price.present ? data.price.value : this.price,
      wholesalePrice: data.wholesalePrice.present
          ? data.wholesalePrice.value
          : this.wholesalePrice,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SellingProductEntity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('wholesalePrice: $wholesalePrice, ')
          ..write('photoPath: $photoPath, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    price,
    wholesalePrice,
    photoPath,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SellingProductEntity &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.price == this.price &&
          other.wholesalePrice == this.wholesalePrice &&
          other.photoPath == this.photoPath &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SellingProductsCompanion extends UpdateCompanion<SellingProductEntity> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<double> price;
  final Value<double?> wholesalePrice;
  final Value<String?> photoPath;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  const SellingProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.price = const Value.absent(),
    this.wholesalePrice = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SellingProductsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.price = const Value.absent(),
    this.wholesalePrice = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<SellingProductEntity> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<double>? price,
    Expression<double>? wholesalePrice,
    Expression<String>? photoPath,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (wholesalePrice != null) 'wholesale_price': wholesalePrice,
      if (photoPath != null) 'photo_path': photoPath,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SellingProductsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<double>? price,
    Value<double?>? wholesalePrice,
    Value<String?>? photoPath,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
  }) {
    return SellingProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      photoPath: photoPath ?? this.photoPath,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (wholesalePrice.present) {
      map['wholesale_price'] = Variable<double>(wholesalePrice.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SellingProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('wholesalePrice: $wholesalePrice, ')
          ..write('photoPath: $photoPath, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $StockTransactionsTable stockTransactions =
      $StockTransactionsTable(this);
  late final $WorkersTable workers = $WorkersTable(this);
  late final $WorkerTransactionsTable workerTransactions =
      $WorkerTransactionsTable(this);
  late final $ProductionRecordsTable productionRecords =
      $ProductionRecordsTable(this);
  late final $ProductionInputsTable productionInputs = $ProductionInputsTable(
    this,
  );
  late final $BillsTable bills = $BillsTable(this);
  late final $BillItemsTable billItems = $BillItemsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $LedgerEntriesTable ledgerEntries = $LedgerEntriesTable(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  late final $WorkWorkEntriesTable workWorkEntries = $WorkWorkEntriesTable(
    this,
  );
  late final $WorkerCuttingEntriesTable workerCuttingEntries =
      $WorkerCuttingEntriesTable(this);
  late final $SellingProductsTable sellingProducts = $SellingProductsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    customers,
    items,
    stockTransactions,
    workers,
    workerTransactions,
    productionRecords,
    productionInputs,
    bills,
    billItems,
    payments,
    ledgerEntries,
    settingsTable,
    workWorkEntries,
    workerCuttingEntries,
    sellingProducts,
  ];
}

typedef $$CustomersTableCreateCompanionBuilder =
    CustomersCompanion Function({
      Value<int> id,
      required String name,
      required String mobile,
      Value<String?> address,
      Value<String?> gstInfo,
      Value<double> openingBalance,
      Value<String?> notes,
      Value<bool> isWholesale,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });
typedef $$CustomersTableUpdateCompanionBuilder =
    CustomersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> mobile,
      Value<String?> address,
      Value<String?> gstInfo,
      Value<double> openingBalance,
      Value<String?> notes,
      Value<bool> isWholesale,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobile => $composableBuilder(
    column: $table.mobile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gstInfo => $composableBuilder(
    column: $table.gstInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWholesale => $composableBuilder(
    column: $table.isWholesale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobile => $composableBuilder(
    column: $table.mobile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gstInfo => $composableBuilder(
    column: $table.gstInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWholesale => $composableBuilder(
    column: $table.isWholesale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get mobile =>
      $composableBuilder(column: $table.mobile, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get gstInfo =>
      $composableBuilder(column: $table.gstInfo, builder: (column) => column);

  GeneratedColumn<double> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isWholesale => $composableBuilder(
    column: $table.isWholesale,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          CustomerEntity,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (
            CustomerEntity,
            BaseReferences<_$AppDatabase, $CustomersTable, CustomerEntity>,
          ),
          CustomerEntity,
          PrefetchHooks Function()
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> mobile = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> gstInfo = const Value.absent(),
                Value<double> openingBalance = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isWholesale = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                name: name,
                mobile: mobile,
                address: address,
                gstInfo: gstInfo,
                openingBalance: openingBalance,
                notes: notes,
                isWholesale: isWholesale,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String mobile,
                Value<String?> address = const Value.absent(),
                Value<String?> gstInfo = const Value.absent(),
                Value<double> openingBalance = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isWholesale = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                name: name,
                mobile: mobile,
                address: address,
                gstInfo: gstInfo,
                openingBalance: openingBalance,
                notes: notes,
                isWholesale: isWholesale,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      CustomerEntity,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (
        CustomerEntity,
        BaseReferences<_$AppDatabase, $CustomersTable, CustomerEntity>,
      ),
      CustomerEntity,
      PrefetchHooks Function()
    >;
typedef $$ItemsTableCreateCompanionBuilder =
    ItemsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> category,
      Value<String?> sku,
      required String type,
      required String unit,
      Value<double> purchaseRate,
      Value<double> sellingRate,
      Value<double?> wholesaleRate,
      Value<double> openingQty,
      Value<double> currentQty,
      Value<double> minStockLevel,
      Value<String?> supplierInfo,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });
typedef $$ItemsTableUpdateCompanionBuilder =
    ItemsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> category,
      Value<String?> sku,
      Value<String> type,
      Value<String> unit,
      Value<double> purchaseRate,
      Value<double> sellingRate,
      Value<double?> wholesaleRate,
      Value<double> openingQty,
      Value<double> currentQty,
      Value<double> minStockLevel,
      Value<String?> supplierInfo,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get purchaseRate => $composableBuilder(
    column: $table.purchaseRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sellingRate => $composableBuilder(
    column: $table.sellingRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get wholesaleRate => $composableBuilder(
    column: $table.wholesaleRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get openingQty => $composableBuilder(
    column: $table.openingQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentQty => $composableBuilder(
    column: $table.currentQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minStockLevel => $composableBuilder(
    column: $table.minStockLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplierInfo => $composableBuilder(
    column: $table.supplierInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get purchaseRate => $composableBuilder(
    column: $table.purchaseRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sellingRate => $composableBuilder(
    column: $table.sellingRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get wholesaleRate => $composableBuilder(
    column: $table.wholesaleRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get openingQty => $composableBuilder(
    column: $table.openingQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentQty => $composableBuilder(
    column: $table.currentQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minStockLevel => $composableBuilder(
    column: $table.minStockLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplierInfo => $composableBuilder(
    column: $table.supplierInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get purchaseRate => $composableBuilder(
    column: $table.purchaseRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sellingRate => $composableBuilder(
    column: $table.sellingRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get wholesaleRate => $composableBuilder(
    column: $table.wholesaleRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get openingQty => $composableBuilder(
    column: $table.openingQty,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentQty => $composableBuilder(
    column: $table.currentQty,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minStockLevel => $composableBuilder(
    column: $table.minStockLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplierInfo => $composableBuilder(
    column: $table.supplierInfo,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemsTable,
          ItemEntity,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (ItemEntity, BaseReferences<_$AppDatabase, $ItemsTable, ItemEntity>),
          ItemEntity,
          PrefetchHooks Function()
        > {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> sku = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> purchaseRate = const Value.absent(),
                Value<double> sellingRate = const Value.absent(),
                Value<double?> wholesaleRate = const Value.absent(),
                Value<double> openingQty = const Value.absent(),
                Value<double> currentQty = const Value.absent(),
                Value<double> minStockLevel = const Value.absent(),
                Value<String?> supplierInfo = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ItemsCompanion(
                id: id,
                name: name,
                category: category,
                sku: sku,
                type: type,
                unit: unit,
                purchaseRate: purchaseRate,
                sellingRate: sellingRate,
                wholesaleRate: wholesaleRate,
                openingQty: openingQty,
                currentQty: currentQty,
                minStockLevel: minStockLevel,
                supplierInfo: supplierInfo,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> category = const Value.absent(),
                Value<String?> sku = const Value.absent(),
                required String type,
                required String unit,
                Value<double> purchaseRate = const Value.absent(),
                Value<double> sellingRate = const Value.absent(),
                Value<double?> wholesaleRate = const Value.absent(),
                Value<double> openingQty = const Value.absent(),
                Value<double> currentQty = const Value.absent(),
                Value<double> minStockLevel = const Value.absent(),
                Value<String?> supplierInfo = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ItemsCompanion.insert(
                id: id,
                name: name,
                category: category,
                sku: sku,
                type: type,
                unit: unit,
                purchaseRate: purchaseRate,
                sellingRate: sellingRate,
                wholesaleRate: wholesaleRate,
                openingQty: openingQty,
                currentQty: currentQty,
                minStockLevel: minStockLevel,
                supplierInfo: supplierInfo,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemsTable,
      ItemEntity,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (ItemEntity, BaseReferences<_$AppDatabase, $ItemsTable, ItemEntity>),
      ItemEntity,
      PrefetchHooks Function()
    >;
typedef $$StockTransactionsTableCreateCompanionBuilder =
    StockTransactionsCompanion Function({
      Value<int> id,
      required int itemId,
      required String type,
      required double quantity,
      Value<double?> unitRate,
      Value<String?> referenceType,
      Value<int?> referenceId,
      required DateTime date,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$StockTransactionsTableUpdateCompanionBuilder =
    StockTransactionsCompanion Function({
      Value<int> id,
      Value<int> itemId,
      Value<String> type,
      Value<double> quantity,
      Value<double?> unitRate,
      Value<String?> referenceType,
      Value<int?> referenceId,
      Value<DateTime> date,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

class $$StockTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $StockTransactionsTable> {
  $$StockTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitRate => $composableBuilder(
    column: $table.unitRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceType => $composableBuilder(
    column: $table.referenceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StockTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockTransactionsTable> {
  $$StockTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitRate => $composableBuilder(
    column: $table.unitRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceType => $composableBuilder(
    column: $table.referenceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StockTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockTransactionsTable> {
  $$StockTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitRate =>
      $composableBuilder(column: $table.unitRate, builder: (column) => column);

  GeneratedColumn<String> get referenceType => $composableBuilder(
    column: $table.referenceType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$StockTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockTransactionsTable,
          StockTransactionEntity,
          $$StockTransactionsTableFilterComposer,
          $$StockTransactionsTableOrderingComposer,
          $$StockTransactionsTableAnnotationComposer,
          $$StockTransactionsTableCreateCompanionBuilder,
          $$StockTransactionsTableUpdateCompanionBuilder,
          (
            StockTransactionEntity,
            BaseReferences<
              _$AppDatabase,
              $StockTransactionsTable,
              StockTransactionEntity
            >,
          ),
          StockTransactionEntity,
          PrefetchHooks Function()
        > {
  $$StockTransactionsTableTableManager(
    _$AppDatabase db,
    $StockTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double?> unitRate = const Value.absent(),
                Value<String?> referenceType = const Value.absent(),
                Value<int?> referenceId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => StockTransactionsCompanion(
                id: id,
                itemId: itemId,
                type: type,
                quantity: quantity,
                unitRate: unitRate,
                referenceType: referenceType,
                referenceId: referenceId,
                date: date,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int itemId,
                required String type,
                required double quantity,
                Value<double?> unitRate = const Value.absent(),
                Value<String?> referenceType = const Value.absent(),
                Value<int?> referenceId = const Value.absent(),
                required DateTime date,
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => StockTransactionsCompanion.insert(
                id: id,
                itemId: itemId,
                type: type,
                quantity: quantity,
                unitRate: unitRate,
                referenceType: referenceType,
                referenceId: referenceId,
                date: date,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StockTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockTransactionsTable,
      StockTransactionEntity,
      $$StockTransactionsTableFilterComposer,
      $$StockTransactionsTableOrderingComposer,
      $$StockTransactionsTableAnnotationComposer,
      $$StockTransactionsTableCreateCompanionBuilder,
      $$StockTransactionsTableUpdateCompanionBuilder,
      (
        StockTransactionEntity,
        BaseReferences<
          _$AppDatabase,
          $StockTransactionsTable,
          StockTransactionEntity
        >,
      ),
      StockTransactionEntity,
      PrefetchHooks Function()
    >;
typedef $$WorkersTableCreateCompanionBuilder =
    WorkersCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> mobile,
      Value<String?> address,
      Value<String?> workType,
      Value<bool> isActive,
      Value<String?> notes,
      Value<DateTime?> joiningDate,
      Value<String?> paymentType,
      Value<double?> defaultHourRate,
      Value<double?> defaultNagRate,
      Value<DateTime> createdAt,
    });
typedef $$WorkersTableUpdateCompanionBuilder =
    WorkersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> mobile,
      Value<String?> address,
      Value<String?> workType,
      Value<bool> isActive,
      Value<String?> notes,
      Value<DateTime?> joiningDate,
      Value<String?> paymentType,
      Value<double?> defaultHourRate,
      Value<double?> defaultNagRate,
      Value<DateTime> createdAt,
    });

class $$WorkersTableFilterComposer
    extends Composer<_$AppDatabase, $WorkersTable> {
  $$WorkersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobile => $composableBuilder(
    column: $table.mobile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workType => $composableBuilder(
    column: $table.workType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joiningDate => $composableBuilder(
    column: $table.joiningDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultHourRate => $composableBuilder(
    column: $table.defaultHourRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultNagRate => $composableBuilder(
    column: $table.defaultNagRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkersTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkersTable> {
  $$WorkersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobile => $composableBuilder(
    column: $table.mobile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workType => $composableBuilder(
    column: $table.workType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joiningDate => $composableBuilder(
    column: $table.joiningDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultHourRate => $composableBuilder(
    column: $table.defaultHourRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultNagRate => $composableBuilder(
    column: $table.defaultNagRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkersTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkersTable> {
  $$WorkersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get mobile =>
      $composableBuilder(column: $table.mobile, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get workType =>
      $composableBuilder(column: $table.workType, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get joiningDate => $composableBuilder(
    column: $table.joiningDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get defaultHourRate => $composableBuilder(
    column: $table.defaultHourRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get defaultNagRate => $composableBuilder(
    column: $table.defaultNagRate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WorkersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkersTable,
          WorkerEntity,
          $$WorkersTableFilterComposer,
          $$WorkersTableOrderingComposer,
          $$WorkersTableAnnotationComposer,
          $$WorkersTableCreateCompanionBuilder,
          $$WorkersTableUpdateCompanionBuilder,
          (
            WorkerEntity,
            BaseReferences<_$AppDatabase, $WorkersTable, WorkerEntity>,
          ),
          WorkerEntity,
          PrefetchHooks Function()
        > {
  $$WorkersTableTableManager(_$AppDatabase db, $WorkersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> mobile = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> workType = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> joiningDate = const Value.absent(),
                Value<String?> paymentType = const Value.absent(),
                Value<double?> defaultHourRate = const Value.absent(),
                Value<double?> defaultNagRate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WorkersCompanion(
                id: id,
                name: name,
                mobile: mobile,
                address: address,
                workType: workType,
                isActive: isActive,
                notes: notes,
                joiningDate: joiningDate,
                paymentType: paymentType,
                defaultHourRate: defaultHourRate,
                defaultNagRate: defaultNagRate,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> mobile = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> workType = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> joiningDate = const Value.absent(),
                Value<String?> paymentType = const Value.absent(),
                Value<double?> defaultHourRate = const Value.absent(),
                Value<double?> defaultNagRate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WorkersCompanion.insert(
                id: id,
                name: name,
                mobile: mobile,
                address: address,
                workType: workType,
                isActive: isActive,
                notes: notes,
                joiningDate: joiningDate,
                paymentType: paymentType,
                defaultHourRate: defaultHourRate,
                defaultNagRate: defaultNagRate,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkersTable,
      WorkerEntity,
      $$WorkersTableFilterComposer,
      $$WorkersTableOrderingComposer,
      $$WorkersTableAnnotationComposer,
      $$WorkersTableCreateCompanionBuilder,
      $$WorkersTableUpdateCompanionBuilder,
      (
        WorkerEntity,
        BaseReferences<_$AppDatabase, $WorkersTable, WorkerEntity>,
      ),
      WorkerEntity,
      PrefetchHooks Function()
    >;
typedef $$WorkerTransactionsTableCreateCompanionBuilder =
    WorkerTransactionsCompanion Function({
      Value<int> id,
      required int workerId,
      required int itemId,
      required double quantityIssued,
      required DateTime date,
      required String status,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$WorkerTransactionsTableUpdateCompanionBuilder =
    WorkerTransactionsCompanion Function({
      Value<int> id,
      Value<int> workerId,
      Value<int> itemId,
      Value<double> quantityIssued,
      Value<DateTime> date,
      Value<String> status,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

class $$WorkerTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkerTransactionsTable> {
  $$WorkerTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workerId => $composableBuilder(
    column: $table.workerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantityIssued => $composableBuilder(
    column: $table.quantityIssued,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkerTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkerTransactionsTable> {
  $$WorkerTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workerId => $composableBuilder(
    column: $table.workerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantityIssued => $composableBuilder(
    column: $table.quantityIssued,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkerTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkerTransactionsTable> {
  $$WorkerTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get workerId =>
      $composableBuilder(column: $table.workerId, builder: (column) => column);

  GeneratedColumn<int> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<double> get quantityIssued => $composableBuilder(
    column: $table.quantityIssued,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WorkerTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkerTransactionsTable,
          WorkerTransactionEntity,
          $$WorkerTransactionsTableFilterComposer,
          $$WorkerTransactionsTableOrderingComposer,
          $$WorkerTransactionsTableAnnotationComposer,
          $$WorkerTransactionsTableCreateCompanionBuilder,
          $$WorkerTransactionsTableUpdateCompanionBuilder,
          (
            WorkerTransactionEntity,
            BaseReferences<
              _$AppDatabase,
              $WorkerTransactionsTable,
              WorkerTransactionEntity
            >,
          ),
          WorkerTransactionEntity,
          PrefetchHooks Function()
        > {
  $$WorkerTransactionsTableTableManager(
    _$AppDatabase db,
    $WorkerTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkerTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkerTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkerTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> workerId = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<double> quantityIssued = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WorkerTransactionsCompanion(
                id: id,
                workerId: workerId,
                itemId: itemId,
                quantityIssued: quantityIssued,
                date: date,
                status: status,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int workerId,
                required int itemId,
                required double quantityIssued,
                required DateTime date,
                required String status,
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WorkerTransactionsCompanion.insert(
                id: id,
                workerId: workerId,
                itemId: itemId,
                quantityIssued: quantityIssued,
                date: date,
                status: status,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkerTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkerTransactionsTable,
      WorkerTransactionEntity,
      $$WorkerTransactionsTableFilterComposer,
      $$WorkerTransactionsTableOrderingComposer,
      $$WorkerTransactionsTableAnnotationComposer,
      $$WorkerTransactionsTableCreateCompanionBuilder,
      $$WorkerTransactionsTableUpdateCompanionBuilder,
      (
        WorkerTransactionEntity,
        BaseReferences<
          _$AppDatabase,
          $WorkerTransactionsTable,
          WorkerTransactionEntity
        >,
      ),
      WorkerTransactionEntity,
      PrefetchHooks Function()
    >;
typedef $$ProductionRecordsTableCreateCompanionBuilder =
    ProductionRecordsCompanion Function({
      Value<int> id,
      required int workerId,
      Value<int?> workerTransactionId,
      required int outputItemId,
      required double outputQty,
      required DateTime date,
      Value<String?> batchRef,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$ProductionRecordsTableUpdateCompanionBuilder =
    ProductionRecordsCompanion Function({
      Value<int> id,
      Value<int> workerId,
      Value<int?> workerTransactionId,
      Value<int> outputItemId,
      Value<double> outputQty,
      Value<DateTime> date,
      Value<String?> batchRef,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

class $$ProductionRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductionRecordsTable> {
  $$ProductionRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workerId => $composableBuilder(
    column: $table.workerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workerTransactionId => $composableBuilder(
    column: $table.workerTransactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get outputItemId => $composableBuilder(
    column: $table.outputItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get outputQty => $composableBuilder(
    column: $table.outputQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchRef => $composableBuilder(
    column: $table.batchRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductionRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductionRecordsTable> {
  $$ProductionRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workerId => $composableBuilder(
    column: $table.workerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workerTransactionId => $composableBuilder(
    column: $table.workerTransactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get outputItemId => $composableBuilder(
    column: $table.outputItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get outputQty => $composableBuilder(
    column: $table.outputQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchRef => $composableBuilder(
    column: $table.batchRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductionRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductionRecordsTable> {
  $$ProductionRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get workerId =>
      $composableBuilder(column: $table.workerId, builder: (column) => column);

  GeneratedColumn<int> get workerTransactionId => $composableBuilder(
    column: $table.workerTransactionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get outputItemId => $composableBuilder(
    column: $table.outputItemId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get outputQty =>
      $composableBuilder(column: $table.outputQty, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get batchRef =>
      $composableBuilder(column: $table.batchRef, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ProductionRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductionRecordsTable,
          ProductionRecordEntity,
          $$ProductionRecordsTableFilterComposer,
          $$ProductionRecordsTableOrderingComposer,
          $$ProductionRecordsTableAnnotationComposer,
          $$ProductionRecordsTableCreateCompanionBuilder,
          $$ProductionRecordsTableUpdateCompanionBuilder,
          (
            ProductionRecordEntity,
            BaseReferences<
              _$AppDatabase,
              $ProductionRecordsTable,
              ProductionRecordEntity
            >,
          ),
          ProductionRecordEntity,
          PrefetchHooks Function()
        > {
  $$ProductionRecordsTableTableManager(
    _$AppDatabase db,
    $ProductionRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductionRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductionRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductionRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> workerId = const Value.absent(),
                Value<int?> workerTransactionId = const Value.absent(),
                Value<int> outputItemId = const Value.absent(),
                Value<double> outputQty = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> batchRef = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ProductionRecordsCompanion(
                id: id,
                workerId: workerId,
                workerTransactionId: workerTransactionId,
                outputItemId: outputItemId,
                outputQty: outputQty,
                date: date,
                batchRef: batchRef,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int workerId,
                Value<int?> workerTransactionId = const Value.absent(),
                required int outputItemId,
                required double outputQty,
                required DateTime date,
                Value<String?> batchRef = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ProductionRecordsCompanion.insert(
                id: id,
                workerId: workerId,
                workerTransactionId: workerTransactionId,
                outputItemId: outputItemId,
                outputQty: outputQty,
                date: date,
                batchRef: batchRef,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductionRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductionRecordsTable,
      ProductionRecordEntity,
      $$ProductionRecordsTableFilterComposer,
      $$ProductionRecordsTableOrderingComposer,
      $$ProductionRecordsTableAnnotationComposer,
      $$ProductionRecordsTableCreateCompanionBuilder,
      $$ProductionRecordsTableUpdateCompanionBuilder,
      (
        ProductionRecordEntity,
        BaseReferences<
          _$AppDatabase,
          $ProductionRecordsTable,
          ProductionRecordEntity
        >,
      ),
      ProductionRecordEntity,
      PrefetchHooks Function()
    >;
typedef $$ProductionInputsTableCreateCompanionBuilder =
    ProductionInputsCompanion Function({
      Value<int> id,
      required int productionRecordId,
      required int itemId,
      required double quantityUsed,
      Value<double> quantityReturned,
      Value<DateTime> createdAt,
    });
typedef $$ProductionInputsTableUpdateCompanionBuilder =
    ProductionInputsCompanion Function({
      Value<int> id,
      Value<int> productionRecordId,
      Value<int> itemId,
      Value<double> quantityUsed,
      Value<double> quantityReturned,
      Value<DateTime> createdAt,
    });

class $$ProductionInputsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductionInputsTable> {
  $$ProductionInputsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productionRecordId => $composableBuilder(
    column: $table.productionRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantityUsed => $composableBuilder(
    column: $table.quantityUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantityReturned => $composableBuilder(
    column: $table.quantityReturned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductionInputsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductionInputsTable> {
  $$ProductionInputsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productionRecordId => $composableBuilder(
    column: $table.productionRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantityUsed => $composableBuilder(
    column: $table.quantityUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantityReturned => $composableBuilder(
    column: $table.quantityReturned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductionInputsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductionInputsTable> {
  $$ProductionInputsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get productionRecordId => $composableBuilder(
    column: $table.productionRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<double> get quantityUsed => $composableBuilder(
    column: $table.quantityUsed,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantityReturned => $composableBuilder(
    column: $table.quantityReturned,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ProductionInputsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductionInputsTable,
          ProductionInputEntity,
          $$ProductionInputsTableFilterComposer,
          $$ProductionInputsTableOrderingComposer,
          $$ProductionInputsTableAnnotationComposer,
          $$ProductionInputsTableCreateCompanionBuilder,
          $$ProductionInputsTableUpdateCompanionBuilder,
          (
            ProductionInputEntity,
            BaseReferences<
              _$AppDatabase,
              $ProductionInputsTable,
              ProductionInputEntity
            >,
          ),
          ProductionInputEntity,
          PrefetchHooks Function()
        > {
  $$ProductionInputsTableTableManager(
    _$AppDatabase db,
    $ProductionInputsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductionInputsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductionInputsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductionInputsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> productionRecordId = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<double> quantityUsed = const Value.absent(),
                Value<double> quantityReturned = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ProductionInputsCompanion(
                id: id,
                productionRecordId: productionRecordId,
                itemId: itemId,
                quantityUsed: quantityUsed,
                quantityReturned: quantityReturned,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int productionRecordId,
                required int itemId,
                required double quantityUsed,
                Value<double> quantityReturned = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ProductionInputsCompanion.insert(
                id: id,
                productionRecordId: productionRecordId,
                itemId: itemId,
                quantityUsed: quantityUsed,
                quantityReturned: quantityReturned,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductionInputsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductionInputsTable,
      ProductionInputEntity,
      $$ProductionInputsTableFilterComposer,
      $$ProductionInputsTableOrderingComposer,
      $$ProductionInputsTableAnnotationComposer,
      $$ProductionInputsTableCreateCompanionBuilder,
      $$ProductionInputsTableUpdateCompanionBuilder,
      (
        ProductionInputEntity,
        BaseReferences<
          _$AppDatabase,
          $ProductionInputsTable,
          ProductionInputEntity
        >,
      ),
      ProductionInputEntity,
      PrefetchHooks Function()
    >;
typedef $$BillsTableCreateCompanionBuilder =
    BillsCompanion Function({
      Value<int> id,
      required String billNumber,
      Value<String> saleChannel,
      Value<int?> customerId,
      required DateTime billDate,
      required double subtotal,
      Value<double> discount,
      Value<double> otherCharges,
      Value<double> previousOutstandingSnapshot,
      Value<double?> currentBalanceSnapshot,
      required double grandTotal,
      Value<double> amountPaid,
      Value<double> advanceApplied,
      Value<bool> gstEnabled,
      Value<double?> gstPercent,
      Value<double> taxableAmount,
      Value<double> gstAmount,
      required double remainingBalance,
      Value<String> status,
      Value<String?> voidReason,
      Value<DateTime?> voidedAt,
      Value<bool> isWholesaleBill,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$BillsTableUpdateCompanionBuilder =
    BillsCompanion Function({
      Value<int> id,
      Value<String> billNumber,
      Value<String> saleChannel,
      Value<int?> customerId,
      Value<DateTime> billDate,
      Value<double> subtotal,
      Value<double> discount,
      Value<double> otherCharges,
      Value<double> previousOutstandingSnapshot,
      Value<double?> currentBalanceSnapshot,
      Value<double> grandTotal,
      Value<double> amountPaid,
      Value<double> advanceApplied,
      Value<bool> gstEnabled,
      Value<double?> gstPercent,
      Value<double> taxableAmount,
      Value<double> gstAmount,
      Value<double> remainingBalance,
      Value<String> status,
      Value<String?> voidReason,
      Value<DateTime?> voidedAt,
      Value<bool> isWholesaleBill,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

class $$BillsTableFilterComposer extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get billNumber => $composableBuilder(
    column: $table.billNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saleChannel => $composableBuilder(
    column: $table.saleChannel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get billDate => $composableBuilder(
    column: $table.billDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discount => $composableBuilder(
    column: $table.discount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get otherCharges => $composableBuilder(
    column: $table.otherCharges,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get previousOutstandingSnapshot => $composableBuilder(
    column: $table.previousOutstandingSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentBalanceSnapshot => $composableBuilder(
    column: $table.currentBalanceSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grandTotal => $composableBuilder(
    column: $table.grandTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get advanceApplied => $composableBuilder(
    column: $table.advanceApplied,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get gstEnabled => $composableBuilder(
    column: $table.gstEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gstPercent => $composableBuilder(
    column: $table.gstPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxableAmount => $composableBuilder(
    column: $table.taxableAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gstAmount => $composableBuilder(
    column: $table.gstAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get remainingBalance => $composableBuilder(
    column: $table.remainingBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWholesaleBill => $composableBuilder(
    column: $table.isWholesaleBill,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BillsTableOrderingComposer
    extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get billNumber => $composableBuilder(
    column: $table.billNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saleChannel => $composableBuilder(
    column: $table.saleChannel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get billDate => $composableBuilder(
    column: $table.billDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discount => $composableBuilder(
    column: $table.discount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get otherCharges => $composableBuilder(
    column: $table.otherCharges,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get previousOutstandingSnapshot => $composableBuilder(
    column: $table.previousOutstandingSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentBalanceSnapshot => $composableBuilder(
    column: $table.currentBalanceSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grandTotal => $composableBuilder(
    column: $table.grandTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get advanceApplied => $composableBuilder(
    column: $table.advanceApplied,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get gstEnabled => $composableBuilder(
    column: $table.gstEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gstPercent => $composableBuilder(
    column: $table.gstPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxableAmount => $composableBuilder(
    column: $table.taxableAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gstAmount => $composableBuilder(
    column: $table.gstAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get remainingBalance => $composableBuilder(
    column: $table.remainingBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWholesaleBill => $composableBuilder(
    column: $table.isWholesaleBill,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BillsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get billNumber => $composableBuilder(
    column: $table.billNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get saleChannel => $composableBuilder(
    column: $table.saleChannel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get billDate =>
      $composableBuilder(column: $table.billDate, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<double> get otherCharges => $composableBuilder(
    column: $table.otherCharges,
    builder: (column) => column,
  );

  GeneratedColumn<double> get previousOutstandingSnapshot => $composableBuilder(
    column: $table.previousOutstandingSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentBalanceSnapshot => $composableBuilder(
    column: $table.currentBalanceSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<double> get grandTotal => $composableBuilder(
    column: $table.grandTotal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => column,
  );

  GeneratedColumn<double> get advanceApplied => $composableBuilder(
    column: $table.advanceApplied,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get gstEnabled => $composableBuilder(
    column: $table.gstEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gstPercent => $composableBuilder(
    column: $table.gstPercent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get taxableAmount => $composableBuilder(
    column: $table.taxableAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gstAmount =>
      $composableBuilder(column: $table.gstAmount, builder: (column) => column);

  GeneratedColumn<double> get remainingBalance => $composableBuilder(
    column: $table.remainingBalance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get voidedAt =>
      $composableBuilder(column: $table.voidedAt, builder: (column) => column);

  GeneratedColumn<bool> get isWholesaleBill => $composableBuilder(
    column: $table.isWholesaleBill,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BillsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BillsTable,
          BillEntity,
          $$BillsTableFilterComposer,
          $$BillsTableOrderingComposer,
          $$BillsTableAnnotationComposer,
          $$BillsTableCreateCompanionBuilder,
          $$BillsTableUpdateCompanionBuilder,
          (BillEntity, BaseReferences<_$AppDatabase, $BillsTable, BillEntity>),
          BillEntity,
          PrefetchHooks Function()
        > {
  $$BillsTableTableManager(_$AppDatabase db, $BillsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> billNumber = const Value.absent(),
                Value<String> saleChannel = const Value.absent(),
                Value<int?> customerId = const Value.absent(),
                Value<DateTime> billDate = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double> discount = const Value.absent(),
                Value<double> otherCharges = const Value.absent(),
                Value<double> previousOutstandingSnapshot =
                    const Value.absent(),
                Value<double?> currentBalanceSnapshot = const Value.absent(),
                Value<double> grandTotal = const Value.absent(),
                Value<double> amountPaid = const Value.absent(),
                Value<double> advanceApplied = const Value.absent(),
                Value<bool> gstEnabled = const Value.absent(),
                Value<double?> gstPercent = const Value.absent(),
                Value<double> taxableAmount = const Value.absent(),
                Value<double> gstAmount = const Value.absent(),
                Value<double> remainingBalance = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<DateTime?> voidedAt = const Value.absent(),
                Value<bool> isWholesaleBill = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BillsCompanion(
                id: id,
                billNumber: billNumber,
                saleChannel: saleChannel,
                customerId: customerId,
                billDate: billDate,
                subtotal: subtotal,
                discount: discount,
                otherCharges: otherCharges,
                previousOutstandingSnapshot: previousOutstandingSnapshot,
                currentBalanceSnapshot: currentBalanceSnapshot,
                grandTotal: grandTotal,
                amountPaid: amountPaid,
                advanceApplied: advanceApplied,
                gstEnabled: gstEnabled,
                gstPercent: gstPercent,
                taxableAmount: taxableAmount,
                gstAmount: gstAmount,
                remainingBalance: remainingBalance,
                status: status,
                voidReason: voidReason,
                voidedAt: voidedAt,
                isWholesaleBill: isWholesaleBill,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String billNumber,
                Value<String> saleChannel = const Value.absent(),
                Value<int?> customerId = const Value.absent(),
                required DateTime billDate,
                required double subtotal,
                Value<double> discount = const Value.absent(),
                Value<double> otherCharges = const Value.absent(),
                Value<double> previousOutstandingSnapshot =
                    const Value.absent(),
                Value<double?> currentBalanceSnapshot = const Value.absent(),
                required double grandTotal,
                Value<double> amountPaid = const Value.absent(),
                Value<double> advanceApplied = const Value.absent(),
                Value<bool> gstEnabled = const Value.absent(),
                Value<double?> gstPercent = const Value.absent(),
                Value<double> taxableAmount = const Value.absent(),
                Value<double> gstAmount = const Value.absent(),
                required double remainingBalance,
                Value<String> status = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<DateTime?> voidedAt = const Value.absent(),
                Value<bool> isWholesaleBill = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BillsCompanion.insert(
                id: id,
                billNumber: billNumber,
                saleChannel: saleChannel,
                customerId: customerId,
                billDate: billDate,
                subtotal: subtotal,
                discount: discount,
                otherCharges: otherCharges,
                previousOutstandingSnapshot: previousOutstandingSnapshot,
                currentBalanceSnapshot: currentBalanceSnapshot,
                grandTotal: grandTotal,
                amountPaid: amountPaid,
                advanceApplied: advanceApplied,
                gstEnabled: gstEnabled,
                gstPercent: gstPercent,
                taxableAmount: taxableAmount,
                gstAmount: gstAmount,
                remainingBalance: remainingBalance,
                status: status,
                voidReason: voidReason,
                voidedAt: voidedAt,
                isWholesaleBill: isWholesaleBill,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BillsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BillsTable,
      BillEntity,
      $$BillsTableFilterComposer,
      $$BillsTableOrderingComposer,
      $$BillsTableAnnotationComposer,
      $$BillsTableCreateCompanionBuilder,
      $$BillsTableUpdateCompanionBuilder,
      (BillEntity, BaseReferences<_$AppDatabase, $BillsTable, BillEntity>),
      BillEntity,
      PrefetchHooks Function()
    >;
typedef $$BillItemsTableCreateCompanionBuilder =
    BillItemsCompanion Function({
      Value<int> id,
      required int billId,
      Value<int?> itemId,
      Value<int?> sellingProductId,
      Value<String?> productName,
      required double quantity,
      required String unit,
      required double rate,
      Value<double?> mrpRateAtSale,
      required double amount,
    });
typedef $$BillItemsTableUpdateCompanionBuilder =
    BillItemsCompanion Function({
      Value<int> id,
      Value<int> billId,
      Value<int?> itemId,
      Value<int?> sellingProductId,
      Value<String?> productName,
      Value<double> quantity,
      Value<String> unit,
      Value<double> rate,
      Value<double?> mrpRateAtSale,
      Value<double> amount,
    });

class $$BillItemsTableFilterComposer
    extends Composer<_$AppDatabase, $BillItemsTable> {
  $$BillItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get billId => $composableBuilder(
    column: $table.billId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sellingProductId => $composableBuilder(
    column: $table.sellingProductId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mrpRateAtSale => $composableBuilder(
    column: $table.mrpRateAtSale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BillItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $BillItemsTable> {
  $$BillItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get billId => $composableBuilder(
    column: $table.billId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sellingProductId => $composableBuilder(
    column: $table.sellingProductId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mrpRateAtSale => $composableBuilder(
    column: $table.mrpRateAtSale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BillItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BillItemsTable> {
  $$BillItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get billId =>
      $composableBuilder(column: $table.billId, builder: (column) => column);

  GeneratedColumn<int> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<int> get sellingProductId => $composableBuilder(
    column: $table.sellingProductId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<double> get mrpRateAtSale => $composableBuilder(
    column: $table.mrpRateAtSale,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);
}

class $$BillItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BillItemsTable,
          BillItemEntity,
          $$BillItemsTableFilterComposer,
          $$BillItemsTableOrderingComposer,
          $$BillItemsTableAnnotationComposer,
          $$BillItemsTableCreateCompanionBuilder,
          $$BillItemsTableUpdateCompanionBuilder,
          (
            BillItemEntity,
            BaseReferences<_$AppDatabase, $BillItemsTable, BillItemEntity>,
          ),
          BillItemEntity,
          PrefetchHooks Function()
        > {
  $$BillItemsTableTableManager(_$AppDatabase db, $BillItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BillItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BillItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BillItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> billId = const Value.absent(),
                Value<int?> itemId = const Value.absent(),
                Value<int?> sellingProductId = const Value.absent(),
                Value<String?> productName = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> rate = const Value.absent(),
                Value<double?> mrpRateAtSale = const Value.absent(),
                Value<double> amount = const Value.absent(),
              }) => BillItemsCompanion(
                id: id,
                billId: billId,
                itemId: itemId,
                sellingProductId: sellingProductId,
                productName: productName,
                quantity: quantity,
                unit: unit,
                rate: rate,
                mrpRateAtSale: mrpRateAtSale,
                amount: amount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int billId,
                Value<int?> itemId = const Value.absent(),
                Value<int?> sellingProductId = const Value.absent(),
                Value<String?> productName = const Value.absent(),
                required double quantity,
                required String unit,
                required double rate,
                Value<double?> mrpRateAtSale = const Value.absent(),
                required double amount,
              }) => BillItemsCompanion.insert(
                id: id,
                billId: billId,
                itemId: itemId,
                sellingProductId: sellingProductId,
                productName: productName,
                quantity: quantity,
                unit: unit,
                rate: rate,
                mrpRateAtSale: mrpRateAtSale,
                amount: amount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BillItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BillItemsTable,
      BillItemEntity,
      $$BillItemsTableFilterComposer,
      $$BillItemsTableOrderingComposer,
      $$BillItemsTableAnnotationComposer,
      $$BillItemsTableCreateCompanionBuilder,
      $$BillItemsTableUpdateCompanionBuilder,
      (
        BillItemEntity,
        BaseReferences<_$AppDatabase, $BillItemsTable, BillItemEntity>,
      ),
      BillItemEntity,
      PrefetchHooks Function()
    >;
typedef $$PaymentsTableCreateCompanionBuilder =
    PaymentsCompanion Function({
      Value<int> id,
      required int customerId,
      Value<int?> billId,
      required double amount,
      required String method,
      Value<String> type,
      required DateTime date,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$PaymentsTableUpdateCompanionBuilder =
    PaymentsCompanion Function({
      Value<int> id,
      Value<int> customerId,
      Value<int?> billId,
      Value<double> amount,
      Value<String> method,
      Value<String> type,
      Value<DateTime> date,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get billId => $composableBuilder(
    column: $table.billId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get billId => $composableBuilder(
    column: $table.billId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get billId =>
      $composableBuilder(column: $table.billId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          PaymentEntity,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (
            PaymentEntity,
            BaseReferences<_$AppDatabase, $PaymentsTable, PaymentEntity>,
          ),
          PaymentEntity,
          PrefetchHooks Function()
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<int?> billId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                customerId: customerId,
                billId: billId,
                amount: amount,
                method: method,
                type: type,
                date: date,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int customerId,
                Value<int?> billId = const Value.absent(),
                required double amount,
                required String method,
                Value<String> type = const Value.absent(),
                required DateTime date,
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                customerId: customerId,
                billId: billId,
                amount: amount,
                method: method,
                type: type,
                date: date,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      PaymentEntity,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (
        PaymentEntity,
        BaseReferences<_$AppDatabase, $PaymentsTable, PaymentEntity>,
      ),
      PaymentEntity,
      PrefetchHooks Function()
    >;
typedef $$LedgerEntriesTableCreateCompanionBuilder =
    LedgerEntriesCompanion Function({
      Value<int> id,
      required int customerId,
      required DateTime date,
      required String type,
      Value<int?> referenceId,
      Value<double> debit,
      Value<double> credit,
      required double runningBalance,
      Value<DateTime> createdAt,
    });
typedef $$LedgerEntriesTableUpdateCompanionBuilder =
    LedgerEntriesCompanion Function({
      Value<int> id,
      Value<int> customerId,
      Value<DateTime> date,
      Value<String> type,
      Value<int?> referenceId,
      Value<double> debit,
      Value<double> credit,
      Value<double> runningBalance,
      Value<DateTime> createdAt,
    });

class $$LedgerEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get debit => $composableBuilder(
    column: $table.debit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get credit => $composableBuilder(
    column: $table.credit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get runningBalance => $composableBuilder(
    column: $table.runningBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LedgerEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get debit => $composableBuilder(
    column: $table.debit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get credit => $composableBuilder(
    column: $table.credit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get runningBalance => $composableBuilder(
    column: $table.runningBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LedgerEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get debit =>
      $composableBuilder(column: $table.debit, builder: (column) => column);

  GeneratedColumn<double> get credit =>
      $composableBuilder(column: $table.credit, builder: (column) => column);

  GeneratedColumn<double> get runningBalance => $composableBuilder(
    column: $table.runningBalance,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LedgerEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LedgerEntriesTable,
          LedgerEntryEntity,
          $$LedgerEntriesTableFilterComposer,
          $$LedgerEntriesTableOrderingComposer,
          $$LedgerEntriesTableAnnotationComposer,
          $$LedgerEntriesTableCreateCompanionBuilder,
          $$LedgerEntriesTableUpdateCompanionBuilder,
          (
            LedgerEntryEntity,
            BaseReferences<
              _$AppDatabase,
              $LedgerEntriesTable,
              LedgerEntryEntity
            >,
          ),
          LedgerEntryEntity,
          PrefetchHooks Function()
        > {
  $$LedgerEntriesTableTableManager(_$AppDatabase db, $LedgerEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgerEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int?> referenceId = const Value.absent(),
                Value<double> debit = const Value.absent(),
                Value<double> credit = const Value.absent(),
                Value<double> runningBalance = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LedgerEntriesCompanion(
                id: id,
                customerId: customerId,
                date: date,
                type: type,
                referenceId: referenceId,
                debit: debit,
                credit: credit,
                runningBalance: runningBalance,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int customerId,
                required DateTime date,
                required String type,
                Value<int?> referenceId = const Value.absent(),
                Value<double> debit = const Value.absent(),
                Value<double> credit = const Value.absent(),
                required double runningBalance,
                Value<DateTime> createdAt = const Value.absent(),
              }) => LedgerEntriesCompanion.insert(
                id: id,
                customerId: customerId,
                date: date,
                type: type,
                referenceId: referenceId,
                debit: debit,
                credit: credit,
                runningBalance: runningBalance,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LedgerEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LedgerEntriesTable,
      LedgerEntryEntity,
      $$LedgerEntriesTableFilterComposer,
      $$LedgerEntriesTableOrderingComposer,
      $$LedgerEntriesTableAnnotationComposer,
      $$LedgerEntriesTableCreateCompanionBuilder,
      $$LedgerEntriesTableUpdateCompanionBuilder,
      (
        LedgerEntryEntity,
        BaseReferences<_$AppDatabase, $LedgerEntriesTable, LedgerEntryEntity>,
      ),
      LedgerEntryEntity,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableTableCreateCompanionBuilder =
    SettingsTableCompanion Function({
      required String key,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $$SettingsTableTableUpdateCompanionBuilder =
    SettingsTableCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<int> rowid,
    });

class $$SettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTableTable,
          SettingEntity,
          $$SettingsTableTableFilterComposer,
          $$SettingsTableTableOrderingComposer,
          $$SettingsTableTableAnnotationComposer,
          $$SettingsTableTableCreateCompanionBuilder,
          $$SettingsTableTableUpdateCompanionBuilder,
          (
            SettingEntity,
            BaseReferences<_$AppDatabase, $SettingsTableTable, SettingEntity>,
          ),
          SettingEntity,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  SettingsTableCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsTableCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTableTable,
      SettingEntity,
      $$SettingsTableTableFilterComposer,
      $$SettingsTableTableOrderingComposer,
      $$SettingsTableTableAnnotationComposer,
      $$SettingsTableTableCreateCompanionBuilder,
      $$SettingsTableTableUpdateCompanionBuilder,
      (
        SettingEntity,
        BaseReferences<_$AppDatabase, $SettingsTableTable, SettingEntity>,
      ),
      SettingEntity,
      PrefetchHooks Function()
    >;
typedef $$WorkWorkEntriesTableCreateCompanionBuilder =
    WorkWorkEntriesCompanion Function({
      Value<int> id,
      required int workerId,
      required DateTime date,
      Value<String?> workDescription,
      Value<double?> hours,
      Value<double?> hourRate,
      Value<double> hourAmount,
      Value<double?> nagQty,
      Value<double?> nagRate,
      Value<double> nagAmount,
      Value<double> totalAmount,
      Value<double> advance,
      Value<double> finalPayable,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$WorkWorkEntriesTableUpdateCompanionBuilder =
    WorkWorkEntriesCompanion Function({
      Value<int> id,
      Value<int> workerId,
      Value<DateTime> date,
      Value<String?> workDescription,
      Value<double?> hours,
      Value<double?> hourRate,
      Value<double> hourAmount,
      Value<double?> nagQty,
      Value<double?> nagRate,
      Value<double> nagAmount,
      Value<double> totalAmount,
      Value<double> advance,
      Value<double> finalPayable,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

class $$WorkWorkEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkWorkEntriesTable> {
  $$WorkWorkEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workerId => $composableBuilder(
    column: $table.workerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workDescription => $composableBuilder(
    column: $table.workDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hours => $composableBuilder(
    column: $table.hours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hourRate => $composableBuilder(
    column: $table.hourRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hourAmount => $composableBuilder(
    column: $table.hourAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get nagQty => $composableBuilder(
    column: $table.nagQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get nagRate => $composableBuilder(
    column: $table.nagRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get nagAmount => $composableBuilder(
    column: $table.nagAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get advance => $composableBuilder(
    column: $table.advance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get finalPayable => $composableBuilder(
    column: $table.finalPayable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkWorkEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkWorkEntriesTable> {
  $$WorkWorkEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workerId => $composableBuilder(
    column: $table.workerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workDescription => $composableBuilder(
    column: $table.workDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hours => $composableBuilder(
    column: $table.hours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hourRate => $composableBuilder(
    column: $table.hourRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hourAmount => $composableBuilder(
    column: $table.hourAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get nagQty => $composableBuilder(
    column: $table.nagQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get nagRate => $composableBuilder(
    column: $table.nagRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get nagAmount => $composableBuilder(
    column: $table.nagAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get advance => $composableBuilder(
    column: $table.advance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get finalPayable => $composableBuilder(
    column: $table.finalPayable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkWorkEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkWorkEntriesTable> {
  $$WorkWorkEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get workerId =>
      $composableBuilder(column: $table.workerId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get workDescription => $composableBuilder(
    column: $table.workDescription,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hours =>
      $composableBuilder(column: $table.hours, builder: (column) => column);

  GeneratedColumn<double> get hourRate =>
      $composableBuilder(column: $table.hourRate, builder: (column) => column);

  GeneratedColumn<double> get hourAmount => $composableBuilder(
    column: $table.hourAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get nagQty =>
      $composableBuilder(column: $table.nagQty, builder: (column) => column);

  GeneratedColumn<double> get nagRate =>
      $composableBuilder(column: $table.nagRate, builder: (column) => column);

  GeneratedColumn<double> get nagAmount =>
      $composableBuilder(column: $table.nagAmount, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get advance =>
      $composableBuilder(column: $table.advance, builder: (column) => column);

  GeneratedColumn<double> get finalPayable => $composableBuilder(
    column: $table.finalPayable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WorkWorkEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkWorkEntriesTable,
          WorkWorkEntryEntity,
          $$WorkWorkEntriesTableFilterComposer,
          $$WorkWorkEntriesTableOrderingComposer,
          $$WorkWorkEntriesTableAnnotationComposer,
          $$WorkWorkEntriesTableCreateCompanionBuilder,
          $$WorkWorkEntriesTableUpdateCompanionBuilder,
          (
            WorkWorkEntryEntity,
            BaseReferences<
              _$AppDatabase,
              $WorkWorkEntriesTable,
              WorkWorkEntryEntity
            >,
          ),
          WorkWorkEntryEntity,
          PrefetchHooks Function()
        > {
  $$WorkWorkEntriesTableTableManager(
    _$AppDatabase db,
    $WorkWorkEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkWorkEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkWorkEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkWorkEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> workerId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> workDescription = const Value.absent(),
                Value<double?> hours = const Value.absent(),
                Value<double?> hourRate = const Value.absent(),
                Value<double> hourAmount = const Value.absent(),
                Value<double?> nagQty = const Value.absent(),
                Value<double?> nagRate = const Value.absent(),
                Value<double> nagAmount = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<double> advance = const Value.absent(),
                Value<double> finalPayable = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WorkWorkEntriesCompanion(
                id: id,
                workerId: workerId,
                date: date,
                workDescription: workDescription,
                hours: hours,
                hourRate: hourRate,
                hourAmount: hourAmount,
                nagQty: nagQty,
                nagRate: nagRate,
                nagAmount: nagAmount,
                totalAmount: totalAmount,
                advance: advance,
                finalPayable: finalPayable,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int workerId,
                required DateTime date,
                Value<String?> workDescription = const Value.absent(),
                Value<double?> hours = const Value.absent(),
                Value<double?> hourRate = const Value.absent(),
                Value<double> hourAmount = const Value.absent(),
                Value<double?> nagQty = const Value.absent(),
                Value<double?> nagRate = const Value.absent(),
                Value<double> nagAmount = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<double> advance = const Value.absent(),
                Value<double> finalPayable = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WorkWorkEntriesCompanion.insert(
                id: id,
                workerId: workerId,
                date: date,
                workDescription: workDescription,
                hours: hours,
                hourRate: hourRate,
                hourAmount: hourAmount,
                nagQty: nagQty,
                nagRate: nagRate,
                nagAmount: nagAmount,
                totalAmount: totalAmount,
                advance: advance,
                finalPayable: finalPayable,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkWorkEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkWorkEntriesTable,
      WorkWorkEntryEntity,
      $$WorkWorkEntriesTableFilterComposer,
      $$WorkWorkEntriesTableOrderingComposer,
      $$WorkWorkEntriesTableAnnotationComposer,
      $$WorkWorkEntriesTableCreateCompanionBuilder,
      $$WorkWorkEntriesTableUpdateCompanionBuilder,
      (
        WorkWorkEntryEntity,
        BaseReferences<
          _$AppDatabase,
          $WorkWorkEntriesTable,
          WorkWorkEntryEntity
        >,
      ),
      WorkWorkEntryEntity,
      PrefetchHooks Function()
    >;
typedef $$WorkerCuttingEntriesTableCreateCompanionBuilder =
    WorkerCuttingEntriesCompanion Function({
      Value<int> id,
      required int workerId,
      required int itemId,
      required DateTime date,
      required double quantity,
      required double rate,
      Value<double> totalAmount,
      Value<String?> remark,
      Value<DateTime> createdAt,
    });
typedef $$WorkerCuttingEntriesTableUpdateCompanionBuilder =
    WorkerCuttingEntriesCompanion Function({
      Value<int> id,
      Value<int> workerId,
      Value<int> itemId,
      Value<DateTime> date,
      Value<double> quantity,
      Value<double> rate,
      Value<double> totalAmount,
      Value<String?> remark,
      Value<DateTime> createdAt,
    });

class $$WorkerCuttingEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkerCuttingEntriesTable> {
  $$WorkerCuttingEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workerId => $composableBuilder(
    column: $table.workerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkerCuttingEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkerCuttingEntriesTable> {
  $$WorkerCuttingEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workerId => $composableBuilder(
    column: $table.workerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkerCuttingEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkerCuttingEntriesTable> {
  $$WorkerCuttingEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get workerId =>
      $composableBuilder(column: $table.workerId, builder: (column) => column);

  GeneratedColumn<int> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WorkerCuttingEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkerCuttingEntriesTable,
          WorkerCuttingEntryEntity,
          $$WorkerCuttingEntriesTableFilterComposer,
          $$WorkerCuttingEntriesTableOrderingComposer,
          $$WorkerCuttingEntriesTableAnnotationComposer,
          $$WorkerCuttingEntriesTableCreateCompanionBuilder,
          $$WorkerCuttingEntriesTableUpdateCompanionBuilder,
          (
            WorkerCuttingEntryEntity,
            BaseReferences<
              _$AppDatabase,
              $WorkerCuttingEntriesTable,
              WorkerCuttingEntryEntity
            >,
          ),
          WorkerCuttingEntryEntity,
          PrefetchHooks Function()
        > {
  $$WorkerCuttingEntriesTableTableManager(
    _$AppDatabase db,
    $WorkerCuttingEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkerCuttingEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkerCuttingEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WorkerCuttingEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> workerId = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> rate = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<String?> remark = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WorkerCuttingEntriesCompanion(
                id: id,
                workerId: workerId,
                itemId: itemId,
                date: date,
                quantity: quantity,
                rate: rate,
                totalAmount: totalAmount,
                remark: remark,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int workerId,
                required int itemId,
                required DateTime date,
                required double quantity,
                required double rate,
                Value<double> totalAmount = const Value.absent(),
                Value<String?> remark = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WorkerCuttingEntriesCompanion.insert(
                id: id,
                workerId: workerId,
                itemId: itemId,
                date: date,
                quantity: quantity,
                rate: rate,
                totalAmount: totalAmount,
                remark: remark,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkerCuttingEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkerCuttingEntriesTable,
      WorkerCuttingEntryEntity,
      $$WorkerCuttingEntriesTableFilterComposer,
      $$WorkerCuttingEntriesTableOrderingComposer,
      $$WorkerCuttingEntriesTableAnnotationComposer,
      $$WorkerCuttingEntriesTableCreateCompanionBuilder,
      $$WorkerCuttingEntriesTableUpdateCompanionBuilder,
      (
        WorkerCuttingEntryEntity,
        BaseReferences<
          _$AppDatabase,
          $WorkerCuttingEntriesTable,
          WorkerCuttingEntryEntity
        >,
      ),
      WorkerCuttingEntryEntity,
      PrefetchHooks Function()
    >;
typedef $$SellingProductsTableCreateCompanionBuilder =
    SellingProductsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> description,
      Value<double> price,
      Value<double?> wholesalePrice,
      Value<String?> photoPath,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
    });
typedef $$SellingProductsTableUpdateCompanionBuilder =
    SellingProductsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> description,
      Value<double> price,
      Value<double?> wholesalePrice,
      Value<String?> photoPath,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
    });

class $$SellingProductsTableFilterComposer
    extends Composer<_$AppDatabase, $SellingProductsTable> {
  $$SellingProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get wholesalePrice => $composableBuilder(
    column: $table.wholesalePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SellingProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $SellingProductsTable> {
  $$SellingProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get wholesalePrice => $composableBuilder(
    column: $table.wholesalePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SellingProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SellingProductsTable> {
  $$SellingProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get wholesalePrice => $composableBuilder(
    column: $table.wholesalePrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SellingProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SellingProductsTable,
          SellingProductEntity,
          $$SellingProductsTableFilterComposer,
          $$SellingProductsTableOrderingComposer,
          $$SellingProductsTableAnnotationComposer,
          $$SellingProductsTableCreateCompanionBuilder,
          $$SellingProductsTableUpdateCompanionBuilder,
          (
            SellingProductEntity,
            BaseReferences<
              _$AppDatabase,
              $SellingProductsTable,
              SellingProductEntity
            >,
          ),
          SellingProductEntity,
          PrefetchHooks Function()
        > {
  $$SellingProductsTableTableManager(
    _$AppDatabase db,
    $SellingProductsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SellingProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SellingProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SellingProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<double?> wholesalePrice = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => SellingProductsCompanion(
                id: id,
                name: name,
                description: description,
                price: price,
                wholesalePrice: wholesalePrice,
                photoPath: photoPath,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<double?> wholesalePrice = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => SellingProductsCompanion.insert(
                id: id,
                name: name,
                description: description,
                price: price,
                wholesalePrice: wholesalePrice,
                photoPath: photoPath,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SellingProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SellingProductsTable,
      SellingProductEntity,
      $$SellingProductsTableFilterComposer,
      $$SellingProductsTableOrderingComposer,
      $$SellingProductsTableAnnotationComposer,
      $$SellingProductsTableCreateCompanionBuilder,
      $$SellingProductsTableUpdateCompanionBuilder,
      (
        SellingProductEntity,
        BaseReferences<
          _$AppDatabase,
          $SellingProductsTable,
          SellingProductEntity
        >,
      ),
      SellingProductEntity,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$StockTransactionsTableTableManager get stockTransactions =>
      $$StockTransactionsTableTableManager(_db, _db.stockTransactions);
  $$WorkersTableTableManager get workers =>
      $$WorkersTableTableManager(_db, _db.workers);
  $$WorkerTransactionsTableTableManager get workerTransactions =>
      $$WorkerTransactionsTableTableManager(_db, _db.workerTransactions);
  $$ProductionRecordsTableTableManager get productionRecords =>
      $$ProductionRecordsTableTableManager(_db, _db.productionRecords);
  $$ProductionInputsTableTableManager get productionInputs =>
      $$ProductionInputsTableTableManager(_db, _db.productionInputs);
  $$BillsTableTableManager get bills =>
      $$BillsTableTableManager(_db, _db.bills);
  $$BillItemsTableTableManager get billItems =>
      $$BillItemsTableTableManager(_db, _db.billItems);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$LedgerEntriesTableTableManager get ledgerEntries =>
      $$LedgerEntriesTableTableManager(_db, _db.ledgerEntries);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
  $$WorkWorkEntriesTableTableManager get workWorkEntries =>
      $$WorkWorkEntriesTableTableManager(_db, _db.workWorkEntries);
  $$WorkerCuttingEntriesTableTableManager get workerCuttingEntries =>
      $$WorkerCuttingEntriesTableTableManager(_db, _db.workerCuttingEntries);
  $$SellingProductsTableTableManager get sellingProducts =>
      $$SellingProductsTableTableManager(_db, _db.sellingProducts);
}
