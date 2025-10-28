import '../services/settings_service.dart';

enum StorageLocationType { bag, depot }

StorageLocationType? storageLocationTypeFromJson(String? value) {
  if (value == null) return null;
  for (final type in StorageLocationType.values) {
    if (type.name == value) {
      return type;
    }
  }
  return null;
}

class Product {
  final String id;
  final String name;
  final String categoryId;
  final DateTime expiryDate;
  final DateTime reminderDate;
  final String? notes;
  final String? location;
  final String? imagePath;
  final String? storageId;
  final StorageLocationType? storageType;
  final int stock;
  final bool isChecked;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.expiryDate,
    required this.reminderDate,
    this.notes,
    this.location,
    this.imagePath,
    this.storageId,
    this.storageType,
    this.stock = 1,
    this.isChecked = false,
    required this.createdAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);

  int get daysRemaining => expiryDate.difference(DateTime.now()).inDays;

  bool get isExpiringsSoon {
    final threshold = SettingsService.instance.expiryWarningDays;
    return daysRemaining > 0 && daysRemaining <= threshold;
  }

  Product copyWith({
    String? id,
    String? name,
    String? categoryId,
    DateTime? expiryDate,
    DateTime? reminderDate,
    String? notes,
    String? location,
    String? imagePath,
    String? storageId,
    StorageLocationType? storageType,
    int? stock,
    bool? isChecked,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      expiryDate: expiryDate ?? this.expiryDate,
      reminderDate: reminderDate ?? this.reminderDate,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      imagePath: imagePath ?? this.imagePath,
      storageId: storageId ?? this.storageId,
      storageType: storageType ?? this.storageType,
      stock: stock ?? this.stock,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'expiryDate': expiryDate.toIso8601String(),
      'reminderDate': reminderDate.toIso8601String(),
      'notes': notes,
      'location': location,
      'imagePath': imagePath,
      'storageId': storageId,
      'storageType': storageType?.name,
      'stock': stock,
      'isChecked': isChecked,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      categoryId: json['categoryId'] ?? json['category'],
      expiryDate: DateTime.parse(json['expiryDate']),
      reminderDate: DateTime.parse(json['reminderDate']),
      notes: json['notes'],
      location: json['location'],
      imagePath: json['imagePath'],
      storageId: json['storageId'],
      storageType: storageLocationTypeFromJson(json['storageType'] as String?),
      stock: json['stock'] ?? 1,
      isChecked: json['isChecked'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
