class Bag {
  final String id;
  final String name;
  final String? notes;
  final List<String> productIds;
  final DateTime createdAt;
  final bool isEmergencyBag;

  Bag({
    required this.id,
    required this.name,
    this.notes,
    List<String>? productIds,
    DateTime? createdAt,
    this.isEmergencyBag = false,
  })  : productIds = productIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  Bag copyWith({
    String? id,
    String? name,
    String? notes,
    List<String>? productIds,
    DateTime? createdAt,
    bool? isEmergencyBag,
  }) {
    return Bag(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      productIds: productIds ?? this.productIds,
      createdAt: createdAt ?? this.createdAt,
      isEmergencyBag: isEmergencyBag ?? this.isEmergencyBag,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
      'productIds': productIds,
      'createdAt': createdAt.toIso8601String(),
      'isEmergencyBag': isEmergencyBag,
    };
  }

  factory Bag.fromJson(Map<String, dynamic> json) {
    return Bag(
      id: json['id'],
      name: json['name'],
      notes: json['notes'],
      productIds: List<String>.from(json['productIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      isEmergencyBag: json['isEmergencyBag'] ?? false,
    );
  }
}
