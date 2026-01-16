import '../utils/window_calculator.dart';

class Window {
  final String? id;
  final String? userId;
  final String customerId;
  final String name; // e.g., 'W1'
  final double width;
  final double height;
  final String type; // e.g., '3T', '2T', 'LC', 'FIX'

  // New fields for L-Corner and Custom types
  final double? width2; // Second width for L-Corner
  final String? formula; // 'A' or 'B' for calculation logic
  final String? customName; // For 'Custom' type

  final int quantity;
  final bool isOnHold;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int syncStatus;
  final bool isDeleted;

  Window({
    this.id,
    this.userId,
    required this.customerId,
    required this.name,
    required this.width,
    required this.height,
    required this.type,
    this.width2,
    this.formula,
    this.customName,
    this.quantity = 1,
    this.isOnHold = false,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.syncStatus = 1,
    this.isDeleted = false,
  });

  // Calculated property for SqFt
  double get sqFt {
    // Basic fields are required
    if (width2 != null && (type == 'LC' || type == 'L-Corner')) {
      // L-Corner Logic
      return WindowCalculator.calculateDisplayedSqFt(
        width: width,
        height: height,
        quantity: 1.0, // Model sqFt is usually per unit or total?
        // Wait, the getter in original code was: ((width + width2!) * height) / 90903.0;
        // It didn't multiply by quantity.
        // But the WindowInputScreen multiplies by quantity.
        // Let's check original getter again.
        // Original: return ((width + width2!) * height) / 90903.0;
        // It does NOT multiply by quantity. Use quantity=1.
        width2: width2!,
        type: type,
        isFormulaA: formula == 'A' || formula == null,
      );
    }

    // Standard Calculation
    return WindowCalculator.calculateDisplayedSqFt(
      width: width,
      height: height,
      quantity: 1.0,
      type: type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'customer_id': customerId,
      'name': name,
      'width': width,
      'height': height,
      'type': type,
      'width2': width2,
      'formula': formula,
      'custom_name': customName,
      'quantity': quantity,
      'is_on_hold': isOnHold ? 1 : 0,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'sync_status': syncStatus,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory Window.fromMap(Map<String, dynamic> map) {
    return Window(
      id: map['id'] as String?,
      userId: map['user_id'] as String?,
      customerId: map['customer_id'] as String,
      name: map['name'] ?? '',
      width: (map['width'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      type: map['type'] ?? '',
      width2: map['width2'] != null ? (map['width2'] as num).toDouble() : null,
      formula: map['formula'],
      customName: map['custom_name'],
      quantity: map['quantity'] as int? ?? 1,
      isOnHold: map['is_on_hold'] == 1 || map['is_on_hold'] == true,
      notes: map['notes'],
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'])
          : null,
      syncStatus: map['sync_status'] as int? ?? 1,
      isDeleted: map['is_deleted'] == 1 || map['is_deleted'] == true,
    );
  }

  Window copyWith({
    String? id,
    String? userId,
    String? customerId,
    String? name,
    double? width,
    double? height,
    String? type,
    double? width2,
    String? formula,
    String? customName,
    int? quantity,
    bool? isOnHold,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncStatus,
    bool? isDeleted,
  }) {
    return Window(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      type: type ?? this.type,
      width2: width2 ?? this.width2,
      formula: formula ?? this.formula,
      customName: customName ?? this.customName,
      quantity: quantity ?? this.quantity,
      isOnHold: isOnHold ?? this.isOnHold,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
