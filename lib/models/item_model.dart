/// Model class for menu item
class ItemModel {
  final int? id;
  final String name;
  final double price;
  final int amount;
  final String? createdAt;
  final String? updatedAt;

  ItemModel({
    this.id,
    required this.name,
    required this.price,
    this.amount = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from database map
  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      amount: map['amount'] as int? ?? 0,
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
      'amount': amount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Copy with modifications
  ItemModel copyWith({
    int? id,
    String? name,
    double? price,
    int? amount,
    String? createdAt,
    String? updatedAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ItemModel(id: $id, name: $name, price: $price, amount: $amount)';
  }
}
