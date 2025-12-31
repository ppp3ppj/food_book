import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/item_model.dart';
import '../providers/item_provider.dart';
import '../router/app_router.dart';

/// Item List Screen - Senior-friendly design with Thai language
/// Performance optimized with HookConsumerWidget
class ItemListScreen extends HookConsumerWidget {
  const ItemListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Local state management with hooks
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
        title: const Text(
          'รายการอาหาร',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 72,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.refresh, size: 32),
              tooltip: 'รีเฟรช',
              iconSize: 32,
              onPressed: () => ref.read(itemProvider.notifier).loadItems(),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          searchFocusNode.unfocus();
        },
        child: Column(
          children: [
            // Search bar
            Container(
              padding: const EdgeInsets.all(20.0),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              child: TextField(
                controller: searchController,
                focusNode: searchFocusNode,
                autofocus: false,
                style: const TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  hintText: 'ค้นหารายการอาหาร...',
                  hintStyle: TextStyle(fontSize: 20, color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, size: 32),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  suffixIcon: searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 28),
                          iconSize: 28,
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
        icon: const Icon(Icons.add, size: 28),
        label: const Text(
          'เพิ่มรายการ',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  /// Build item list based on state
  Widget _buildItemList(
    BuildContext context,
    WidgetRef ref,
    ItemState itemState,
    List<ItemModel> filteredItems,
    String searchQuery,
  ) {
    // Loading state
    if (itemState.isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(strokeWidth: 5),
              const SizedBox(height: 24),
              Text(
                'กำลังโหลด...',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Error state
    if (itemState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 96, color: Colors.red),
              const SizedBox(height: 24),
              Text(
                'เกิดข้อผิดพลาด',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                itemState.error!,
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => ref.read(itemProvider.notifier).loadItems(),
                icon: const Icon(Icons.refresh, size: 28),
                label: const Text(
                  'ลองใหม่อีกครั้ง',
                  style: TextStyle(fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (filteredItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                searchQuery.isEmpty ? Icons.inbox_outlined : Icons.search_off,
                size: 96,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                searchQuery.isEmpty 
                    ? 'ยังไม่มีรายการ' 
                    : 'ไม่พบรายการ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                searchQuery.isEmpty 
                    ? 'เริ่มต้นโดยการเพิ่มรายการใหม่' 
                    : 'ลองค้นหาด้วยคำอื่น',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Items list
    return ListView.builder(
      itemCount: filteredItems.length,
      padding: const EdgeInsets.all(20),
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildItemCard(context, item);
      },
    );
  }

  /// Build individual item card
  Widget _buildItemCard(BuildContext context, ItemModel item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(
          AppRoutes.editItem,
          extra: item,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Large icon/avatar
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    item.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 24,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '฿${item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    if (item.amount > 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 22,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'จำนวน: ${item.amount}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Edit button
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  iconSize: 32,
                  color: Colors.blue[700],
                  tooltip: 'แก้ไข',
                  onPressed: () => context.push(
                    AppRoutes.editItem,
                    extra: item,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
