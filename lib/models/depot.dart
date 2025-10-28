class Depot {
  final String id;
  final String name;
  final String? notes;
  final List<String> productIds;
  final DateTime createdAt;

  Depot({
    required this.id,
    required this.name,
    this.notes,
    List<String>? productIds,
    DateTime? createdAt,
  })  : productIds = productIds ?? <String>[],
        createdAt = createdAt ?? DateTime.now();

  Depot copyWith({
    String? id,
    String? name,
    String? notes,
    List<String>? productIds,
    DateTime? createdAt,
  }) {
    return Depot(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      productIds: productIds ?? this.productIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
      'productIds': productIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Depot.fromJson(Map<String, dynamic> json) {
    return Depot(
      id: json['id'] as String,
      name: json['name'] as String,
      notes: json['notes'] as String?,
      productIds: List<String>.from(json['productIds'] ?? <String>[]),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
