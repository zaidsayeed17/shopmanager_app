import '../db/app_database.dart';

class WorkerModel {
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
  final DateTime? createdAt;
  final int pendingItemCount;

  const WorkerModel({
    required this.id,
    required this.name,
    this.mobile,
    this.address,
    this.workType,
    this.isActive = true,
    this.notes,
    this.joiningDate,
    this.paymentType,
    this.defaultHourRate,
    this.defaultNagRate,
    this.createdAt,
    this.pendingItemCount = 0,
  });

  String get formattedWorkerId => 'W-${id.toString().padLeft(4, '0')}';

  String get initials {
    final cleanName = name.replaceAll(RegExp(r'[\(\)\-]'), ' ').trim();
    final parts =
        cleanName.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'WR';
  }

  factory WorkerModel.fromEntity(WorkerEntity entity, {int pendingItemCount = 0}) {
    return WorkerModel(
      id: entity.id,
      name: entity.name,
      mobile: entity.mobile,
      address: entity.address,
      workType: entity.workType,
      isActive: entity.isActive,
      notes: entity.notes,
      joiningDate: entity.joiningDate,
      paymentType: entity.paymentType,
      defaultHourRate: entity.defaultHourRate,
      defaultNagRate: entity.defaultNagRate,
      createdAt: entity.createdAt,
      pendingItemCount: pendingItemCount,
    );
  }

  WorkerModel copyWith({
    int? id,
    String? name,
    String? mobile,
    String? address,
    String? workType,
    bool? isActive,
    String? notes,
    DateTime? joiningDate,
    String? paymentType,
    double? defaultHourRate,
    double? defaultNagRate,
    DateTime? createdAt,
    int? pendingItemCount,
  }) {
    return WorkerModel(
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
      pendingItemCount: pendingItemCount ?? this.pendingItemCount,
    );
  }
}
