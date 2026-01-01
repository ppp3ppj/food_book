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

  const ItemState({this.items = const [], this.isLoading = false, this.error});

  // Getters for convenience
  bool get hasItems => items.isNotEmpty;
  int get itemCount => items.length;

  /// Create a copy of the state with updated fields
  /// This ensures immutability and proper state updates
  ItemState copyWith({List<ItemModel>? items, bool? isLoading, String? error}) {
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
  // Cache for recently loaded dates (max 7 days)
  final Map<String, List<ItemModel>> _dateCache = {};
  static const int _maxCacheSize = 7;

  // Cache for suggestions (5 minutes TTL)
  List<Map<String, dynamic>>? _suggestionsCache;
  DateTime? _suggestionsCacheTime;
  static const Duration _suggestionsCacheDuration = Duration(minutes: 5);

  @override
  ItemState build() {
    // Load items on initialization
    Future.microtask(() => loadItems());
    return const ItemState();
  }

  AppDatabase get _database => ref.read(databaseProvider);

  /// Load items for a specific date with caching
  Future<void> loadItems({String? date}) async {
    final dateFilter = date ?? _formatDate(DateTime.now());

    // Check cache first
    if (_dateCache.containsKey(dateFilter)) {
      debugPrint('📦 Using cached data for date: $dateFilter');
      state = state.copyWith(
        items: _dateCache[dateFilter]!,
        isLoading: false,
        error: null,
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = _database.query(
        'SELECT * FROM items WHERE date = ? ORDER BY created_at DESC',
        [dateFilter],
      );
      final itemList = result.map((row) => ItemModel.fromMap(row)).toList();

      // Add to cache
      _dateCache[dateFilter] = itemList;

      // Limit cache size
      if (_dateCache.length > _maxCacheSize) {
        final firstKey = _dateCache.keys.first;
        _dateCache.remove(firstKey);
        debugPrint('🗑️ Removed oldest cache: $firstKey');
      }

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

  /// Clear cache for a specific date (call after create/update/delete)
  void _clearDateCache(String date) {
    _dateCache.remove(date);
    debugPrint('🧹 Cleared cache for date: $date');
  }

  /// Clear suggestions cache (call after create/update/delete)
  void _clearSuggestionsCache() {
    _suggestionsCache = null;
    _suggestionsCacheTime = null;
    debugPrint('🧹 Cleared suggestions cache');
  }

  /// Format DateTime to YYYY-MM-DD string
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Create new item with date
  Future<bool> createItem(
    String name,
    double price, {
    String? date,
    String? reason,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final itemDate = date ?? _formatDate(DateTime.now());
      _database.execute(
        'INSERT INTO items (name, price, date, reason) VALUES (?, ?, ?, ?)',
        [name, price, itemDate, reason],
      );

      debugPrint('✅ Item created: $name - ฿$price for date: $itemDate');

      // Clear caches for this date
      _clearDateCache(itemDate);
      _clearSuggestionsCache();
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
  Future<bool> updateItem(
    int id,
    String name,
    double price, {
    String? date,
    String? reason,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final itemDate = date ?? _formatDate(DateTime.now());
      _database.execute(
        'UPDATE items SET name = ?, price = ?, date = ?, reason = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
        [name, price, itemDate, reason, id],
      );

      debugPrint('✅ Item updated: ID $id');

      // Clear caches for this date
      _clearDateCache(itemDate);
      _clearSuggestionsCache();
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

      // Clear all caches since we don't know the date
      _dateCache.clear();
      _clearSuggestionsCache();
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

  /// Get recent unique item names for autocomplete
  /// Returns distinct item names from recent history (last 30 days)
  /// Cached for 5 minutes to optimize performance
  Future<List<Map<String, dynamic>>> getRecentItemSuggestions() async {
    // Check cache first
    final now = DateTime.now();
    if (_suggestionsCache != null && _suggestionsCacheTime != null) {
      final cacheAge = now.difference(_suggestionsCacheTime!);
      if (cacheAge < _suggestionsCacheDuration) {
        debugPrint('📦 Using cached suggestions (age: ${cacheAge.inSeconds}s)');
        return _suggestionsCache!;
      }
    }

    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final dateStr = _formatDate(thirtyDaysAgo);

      // Get distinct items with their most recent price and count
      // Uses idx_items_name_lower index for fast Thai language grouping
      final result = _database.query(
        '''
        SELECT name, price, reason, COUNT(*) as usage_count, MAX(created_at) as last_used
        FROM items 
        WHERE date >= ?
        GROUP BY LOWER(name)
        ORDER BY usage_count DESC, last_used DESC
        LIMIT 20
        ''',
        [dateStr],
      );

      // Update cache
      _suggestionsCache = result.toList();
      _suggestionsCacheTime = now;
      debugPrint(
        '🔄 Suggestions cache updated (${_suggestionsCache!.length} items)',
      );

      return _suggestionsCache!;
    } catch (e) {
      debugPrint('❌ Error getting suggestions: $e');
      return [];
    }
  }

  /// Get all unique item names (for basic autocomplete)
  Future<List<String>> getAllItemNames() async {
    try {
      final result = _database.query('''
        SELECT DISTINCT name 
        FROM items 
        ORDER BY name
        ''');

      return result.map((row) => row['name'] as String).toList();
    } catch (e) {
      debugPrint('❌ Error getting item names: $e');
      return [];
    }
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
final filteredItemsProvider = Provider.family<List<ItemModel>, String>((
  ref,
  query,
) {
  final itemState = ref.watch(itemProvider);

  if (query.isEmpty) return itemState.items;

  final lowerQuery = query.toLowerCase();
  return itemState.items.where((item) {
    return item.name.toLowerCase().contains(lowerQuery);
  }).toList();
});
