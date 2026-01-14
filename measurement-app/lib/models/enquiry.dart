import 'package:uuid/uuid.dart';

class Enquiry {
  final String? id;
  final String?
  userId; // For potential future multi-user support, primarily uses deviceId logic for now
  final String name;
  final String? phone;
  final String? location;
  final String? requirements;
  final String? expectedWindows;
  final String? notes;
  final String status; // 'pending', 'converted', 'archived'
  final DateTime? reminderDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int syncStatus; // 0: Synced, 1: Created, 2: Updated, 3: Deleted
  final bool isDeleted;

  Enquiry({
    this.id,
    this.userId,
    required this.name,
    this.phone,
    this.location,
    this.requirements,
    this.expectedWindows,
    this.notes,
    this.status = 'pending',
    this.reminderDate,
    required this.createdAt,
    this.updatedAt,
    this.syncStatus = 1,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'location': location,
      'requirements': requirements,
      'expected_windows': expectedWindows,
      'notes': notes,
      'status': status,
      'reminder_date': reminderDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'sync_status': syncStatus,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory Enquiry.fromMap(Map<String, dynamic> map) {
    return Enquiry(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'] ?? '',
      phone: map['phone'],
      location: map['location'],
      requirements: map['requirements'],
      expectedWindows: map['expected_windows']
          ?.toString(), // Handle slight type mismatches if any
      notes: map['notes'],
      status: map['status'] ?? 'pending',
      reminderDate: map['reminder_date'] != null
          ? DateTime.tryParse(map['reminder_date'])
          : null,
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'])
          : null,
      syncStatus: map['sync_status'] as int? ?? 1,
      isDeleted: map['is_deleted'] == 1 || map['is_deleted'] == true,
    );
  }

  Enquiry copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? location,
    String? requirements,
    String? expectedWindows,
    String? notes,
    String? status,
    DateTime? reminderDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncStatus,
    bool? isDeleted,
  }) {
    return Enquiry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      requirements: requirements ?? this.requirements,
      expectedWindows: expectedWindows ?? this.expectedWindows,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      reminderDate: reminderDate ?? this.reminderDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  static Enquiry create({
    required String name,
    String? phone,
    String? location,
    String? requirements,
    String? expectedWindows,
    String? notes,
    DateTime? reminderDate,
  }) {
    return Enquiry(
      id: const Uuid().v4(),
      name: name,
      phone: phone,
      location: location,
      requirements: requirements,
      expectedWindows: expectedWindows,
      notes: notes,
      reminderDate: reminderDate,
      createdAt: DateTime.now(),
      syncStatus: 1, // Created
    );
  }
}
