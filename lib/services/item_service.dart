import 'package:flutter/material.dart';
import '../data/app_database.dart';
import '../models/item_model.dart';

/// Service for managing menu items (CRUD operations)
class ItemService extends ChangeNotifier {
  final AppDatabase _database;
  List<ItemModel> _items = [];
  bool _isLoading = false;
  String? _error;

  ItemService(this._database) {
    loadItems();
  }

  // Getters
  List<ItemModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasItems => _items.isNotEmpty;
  int get itemCount => _items.length;

  /// Load all items from database
  Future<void> loadItems() async {
    _setLoading(true);
    _setError(null);

    try {
      final result = _database.query('SELECT * FROM items ORDER BY created_at DESC');
      _items = result.map((row) => ItemModel.fromMap(row)).toList();
      
      debugPrint('📋 Loaded ${_items.length} items');
    } catch (e) {
      _setError('Failed to load items: $e');
      debugPrint('❌ Error loading items: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create new item
  Future<bool> createItem(String name, double price, {int amount = 0}) async {
    _setLoading(true);
    _setError(null);

    try {
      _database.execute(
        'INSERT INTO items (name, price, amount) VALUES (?, ?, ?)',
        [name, price, amount],
      );
      
      debugPrint('✅ Item created: $name - ฿$price');
      
      await loadItems();
      return true;
    } catch (e) {
      _setError('Failed to create item: $e');
      debugPrint('❌ Error creating item: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Update existing item
  Future<bool> updateItem(int id, String name, double price, {int? amount}) async {
    _setLoading(true);
    _setError(null);

    try {
      _database.execute(
        'UPDATE items SET name = ?, price = ?, amount = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
        [name, price, amount ?? 0, id],
      );
      
      debugPrint('✅ Item updated: ID $id');
      
      await loadItems();
      return true;
    } catch (e) {
      _setError('Failed to update item: $e');
      debugPrint('❌ Error updating item: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Delete item
  Future<bool> deleteItem(int id) async {
    _setLoading(true);
    _setError(null);

    try {
      _database.execute('DELETE FROM items WHERE id = ?', [id]);
      
      debugPrint('✅ Item deleted: ID $id');
      
      await loadItems();
      return true;
    } catch (e) {
      _setError('Failed to delete item: $e');
      debugPrint('❌ Error deleting item: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Get item by ID
  ItemModel? getItemById(int id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Search items by name
  List<ItemModel> searchItems(String query) {
    if (query.isEmpty) return _items;
    
    final lowercaseQuery = query.toLowerCase();
    return _items.where((item) => 
      item.name.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}
