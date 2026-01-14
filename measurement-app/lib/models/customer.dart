class Customer {
  final String? id;
  final String? userId;
  final String name;
  final String location;
  final String? phone;
  final String framework; // 'Inventa' or 'Optima'
  final String? glassType;
  final double? ratePerSqft;
  final bool isFinalMeasurement;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int syncStatus; // 0: Synced, 1: Created, 2: Updated, 3: Deleted
  final bool isDeleted;
  final int windowCount;
  final double totalSqFt;

  Customer({
    this.id,
    this.userId,
    required this.name,
    required this.location,
    this.phone,
    required this.framework,
    this.glassType,
    this.ratePerSqft,
    this.isFinalMeasurement = false,
    required this.createdAt,
    this.updatedAt,
    this.syncStatus = 1,
    this.isDeleted = false,
    this.windowCount = 0,
    this.totalSqFt = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'location': location,
      'phone': phone,
      'framework': framework,
      'glass_type': glassType,
      'rate_per_sqft': ratePerSqft,
      'is_final_measurement': isFinalMeasurement ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'sync_status': syncStatus,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as String?,
      userId: map['user_id'] as String?,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      phone: map['phone'],
      framework: map['framework'] ?? 'Inventa',
      glassType: map['glass_type'],
      ratePerSqft: map['rate_per_sqft'] != null
          ? (map['rate_per_sqft'] as num).toDouble()
          : null,
      isFinalMeasurement:
          map['is_final_measurement'] == 1 ||
          map['is_final_measurement'] == true,
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'])
          : null,
      syncStatus: map['sync_status'] as int? ?? 1,
      isDeleted: map['is_deleted'] == 1 || map['is_deleted'] == true,
      windowCount: map['window_count'] != null
          ? (map['window_count'] as num).toInt()
          : 0,
      totalSqFt: map['total_sqft'] != null
          ? (map['total_sqft'] as num).toDouble()
          : 0.0,
    );
  }

  Customer copyWith({
    String? id,
    String? userId,
    String? name,
    String? location,
    String? phone,
    String? framework,
    String? glassType,
    double? ratePerSqft,
    bool? isFinalMeasurement,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncStatus,
    bool? isDeleted,
    int? windowCount,
    double? totalSqFt,
  }) {
    return Customer(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      framework: framework ?? this.framework,
      glassType: glassType ?? this.glassType,
      ratePerSqft: ratePerSqft ?? this.ratePerSqft,
      isFinalMeasurement: isFinalMeasurement ?? this.isFinalMeasurement,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      windowCount: windowCount ?? this.windowCount,
      totalSqFt: totalSqFt ?? this.totalSqFt,
    );
  }
}
