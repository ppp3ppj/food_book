/// Model class for menu item
class ItemModel {
  final int? id;
  final String name;
  final double price;
  final String date; // Date in YYYY-MM-DD format
  final String? reason; // Optional reason/note (e.g., เผ็ดมาก)
  final String? createdAt;
  final String? updatedAt;

  ItemModel({
    this.id,
    required this.name,
    required this.price,
    required this.date,
    this.reason,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from database map
  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      date: map['date'] as String,
      reason: map['reason'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'date': date,
      'reason': reason,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Copy with modifications
  ItemModel copyWith({
    int? id,
    String? name,
    double? price,
    String? date,
    String? reason,
    String? createdAt,
    String? updatedAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      date: date ?? this.date,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ItemModel(id: $id, name: $name, price: $price)';
  }
}
