import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/item_model.dart';
import '../providers/item_provider.dart';
import '../router/app_router.dart';

/// Item List Screen - Refactored with HookConsumerWidget for optimal performance
/// No StatefulWidget - Uses hooks for local state management
/// Declarative navigation with go_router
class ItemListScreen extends HookConsumerWidget {
  const ItemListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Local state management with hooks (no setState needed)
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();
    final searchQuery = useState('');
    
    // Watch item state from Riverpod provider
    final itemState = ref.watch(itemProvider);
    
    // Computed filtered items
    final filteredItems = useMemoized(
      () {
        if (searchQuery.value.isEmpty) return itemState.items;
        
        final lowerQuery = searchQuery.value.toLowerCase();
        return itemState.items.where((item) {
          return item.name.toLowerCase().contains(lowerQuery);
        }).toList();
      },
      [itemState.items, searchQuery.value],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Items'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(itemProvider.notifier).loadItems(),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Unfocus when tapping outside
          searchFocusNode.unfocus();
        },
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                focusNode: searchFocusNode,
                autofocus: false,
                decoration: InputDecoration(
                  labelText: 'Search items',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            searchQuery.value = '';
                            searchFocusNode.unfocus();
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  searchQuery.value = value;
                },
              ),
            ),
            // Items list
            Expanded(
              child: _buildItemList(
                context,
              ref,
              itemState,
              filteredItems,
              searchQuery.value,
            ),
          ),
        ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addItem),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  /// Build item list based on state
  /// Separated for better code organization and readability
  Widget _buildItemList(
    BuildContext context,
    WidgetRef ref,
    ItemState itemState,
    List<ItemModel> filteredItems,
    String searchQuery,
  ) {
    // Loading state
    if (itemState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (itemState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${itemState.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(itemProvider.notifier).loadItems(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? 'No items yet. Add your first item!'
                  : 'No items found for "$searchQuery"',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Items list
    return ListView.builder(
      itemCount: filteredItems.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildItemCard(context, item);
      },
    );
  }

  /// Build individual item card
  /// Separated for reusability and cleaner code
  Widget _buildItemCard(BuildContext context, ItemModel item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            item.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: ฿${item.price.toStringAsFixed(2)}'),
            if (item.amount > 0) Text('Amount: ${item.amount}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              color: Colors.blue,
              onPressed: () => context.push(
                AppRoutes.editItem,
                extra: item,
              ),
            ),
          ],
        ),
        onTap: () => context.push(
          AppRoutes.editItem,
          extra: item,
        ),
      ),
    );
  }
}
