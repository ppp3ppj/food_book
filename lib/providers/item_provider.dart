import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_database.dart';
import '../models/item_model.dart';
import 'database_provider.dart';

/// State class for item management
/// Immutable state object following Riverpod best practices
class ItemState {
  final List<ItemModel> items;
  final bool isLoading;
  final String? error;

  const ItemState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  // Getters for convenience
  bool get hasItems => items.isNotEmpty;
  int get itemCount => items.length;

  /// Create a copy of the state with updated fields
  /// This ensures immutability and proper state updates
  ItemState copyWith({
    List<ItemModel>? items,
    bool? isLoading,
    String? error,
  }) {
    return ItemState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing item state and business logic
/// Replaces the old ChangeNotifier-based ItemService for better performance
class ItemNotifier extends Notifier<ItemState> {
  @override
  ItemState build() {
    // Load items on initialization
    Future.microtask(() => loadItems());
    return const ItemState();
  }

  AppDatabase get _database => ref.read(databaseProvider);

  /// Load items for a specific date
  Future<void> loadItems({String? date}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final dateFilter = date ?? _formatDate(DateTime.now());
      final result = _database.query(
        'SELECT * FROM items WHERE date = ? ORDER BY created_at DESC',
        [dateFilter],
      );
      final itemList = result.map((row) => ItemModel.fromMap(row)).toList();
      
      state = state.copyWith(items: itemList, isLoading: false);
      debugPrint('📋 Loaded ${itemList.length} items for date: $dateFilter');
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load items: $e',
        isLoading: false,
      );
      debugPrint('❌ Error loading items: $e');
    }
  }

  /// Format DateTime to YYYY-MM-DD string
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Create new item with date
  Future<bool> createItem(String name, double price, {int amount = 0, String? date}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final itemDate = date ?? _formatDate(DateTime.now());
      _database.execute(
        'INSERT INTO items (name, price, amount, date) VALUES (?, ?, ?, ?)',
        [name, price, amount, itemDate],
      );
      
      debugPrint('✅ Item created: $name - ฿$price for date: $itemDate');
      
      await loadItems(date: itemDate);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to create item: $e',
        isLoading: false,
      );
      debugPrint('❌ Error creating item: $e');
      return false;
    }
  }

  /// Update existing item
  Future<bool> updateItem(int id, String name, double price, {int? amount, String? date}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final itemDate = date ?? _formatDate(DateTime.now());
      _database.execute(
        'UPDATE items SET name = ?, price = ?, amount = ?, date = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
        [name, price, amount ?? 0, itemDate, id],
      );
      
      debugPrint('✅ Item updated: ID $id');
      
      await loadItems(date: itemDate);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update item: $e',
        isLoading: false,
      );
      debugPrint('❌ Error updating item: $e');
      return false;
    }
  }

  /// Delete item
  Future<bool> deleteItem(int id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      _database.execute('DELETE FROM items WHERE id = ?', [id]);
      
      debugPrint('✅ Item deleted: ID $id');
      
      await loadItems();
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete item: $e',
        isLoading: false,
      );
      debugPrint('❌ Error deleting item: $e');
      return false;
    }
  }

  /// Search items by query (name search)
  List<ItemModel> searchItems(String query) {
    if (query.isEmpty) return state.items;
    
    final lowerQuery = query.toLowerCase();
    return state.items.where((item) {
      return item.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

/// Provider for the ItemNotifier
/// This is the main entry point for accessing item state and operations
/// Performance optimized with NotifierProvider
final itemProvider = NotifierProvider<ItemNotifier, ItemState>(() {
  return ItemNotifier();
});

/// Computed provider for filtered items based on search query
/// This demonstrates how to create derived state without rebuilding entire widget tree
final filteredItemsProvider = Provider.family<List<ItemModel>, String>((ref, query) {
  final itemState = ref.watch(itemProvider);
  
  if (query.isEmpty) return itemState.items;
  
  final lowerQuery = query.toLowerCase();
  return itemState.items.where((item) {
    return item.name.toLowerCase().contains(lowerQuery);
  }).toList();
});
