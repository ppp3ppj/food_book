import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/item_model.dart';
import '../providers/item_provider.dart';
import '../providers/settings_provider.dart';
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
    final selectedDate = useState(DateTime.now());

    // Watch item state from Riverpod provider
    final itemState = ref.watch(itemProvider);

    // Reload items when date changes using Future.microtask to avoid lifecycle issues
    useEffect(() {
      final dateStr =
          '${selectedDate.value.year}-${selectedDate.value.month.toString().padLeft(2, '0')}-${selectedDate.value.day.toString().padLeft(2, '0')}';
      Future.microtask(
        () => ref.read(itemProvider.notifier).loadItems(date: dateStr),
      );
      return null;
    }, [selectedDate.value]);

    // Computed filtered items
    final filteredItems = useMemoized(() {
      if (searchQuery.value.isEmpty) return itemState.items;

      final lowerQuery = searchQuery.value.toLowerCase();
      return itemState.items.where((item) {
        return item.name.toLowerCase().contains(lowerQuery);
      }).toList();
    }, [itemState.items, searchQuery.value]);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'รายการอาหาร',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 56,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: IconButton(
              icon: const Icon(Icons.share, size: 28),
              tooltip: 'แชร์เมนู',
              iconSize: 28,
              onPressed: () =>
                  _shareMenu(context, ref, selectedDate.value, itemState.items),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: IconButton(
              icon: const Icon(Icons.settings, size: 28),
              tooltip: 'ตั้งค่า',
              iconSize: 28,
              onPressed: () => context.push(AppRoutes.settings),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.refresh, size: 28),
              tooltip: 'รีเฟรช',
              iconSize: 28,
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
              padding: const EdgeInsets.all(12.0),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              child: TextField(
                controller: searchController,
                focusNode: searchFocusNode,
                autofocus: false,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'ค้นหารายการอาหาร...',
                  hintStyle: TextStyle(fontSize: 18, color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, size: 28),
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
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 24),
                          iconSize: 24,
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
            // Date Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Previous Day Button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 32),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        selectedDate.value = selectedDate.value.subtract(
                          const Duration(days: 1),
                        );
                      },
                      tooltip: 'วันก่อนหน้า',
                    ),
                  ),
                  // Date Display & Picker
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate.value,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                textTheme: Theme.of(context).textTheme.copyWith(
                                  headlineMedium: const TextStyle(fontSize: 28),
                                  titleLarge: const TextStyle(fontSize: 22),
                                  labelLarge: const TextStyle(fontSize: 18),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedDate != null) {
                          selectedDate.value = pickedDate;
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatDate(selectedDate.value),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDayName(selectedDate.value),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Next Day Button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, size: 32),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        selectedDate.value = selectedDate.value.add(
                          const Duration(days: 1),
                        );
                      },
                      tooltip: 'วันถัดไป',
                    ),
                  ),
                ],
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
        onPressed: () {
          final dateStr =
              '${selectedDate.value.year}-${selectedDate.value.month.toString().padLeft(2, '0')}-${selectedDate.value.day.toString().padLeft(2, '0')}';
          context.push(AppRoutes.addItem, extra: dateStr);
        },
        icon: const Icon(Icons.add, size: 24),
        label: const Text(
          'เพิ่มรายการ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                style: TextStyle(fontSize: 22, color: Colors.grey[700]),
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
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                searchQuery.isEmpty ? Icons.inbox_outlined : Icons.search_off,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 20),
              Text(
                searchQuery.isEmpty ? 'ยังไม่มีรายการ' : 'ไม่พบรายการ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                searchQuery.isEmpty
                    ? 'เริ่มต้นโดยการเพิ่มรายการใหม่'
                    : 'ลองค้นหาด้วยคำอื่น',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildItemCard(context, item);
      },
    );
  }

  /// Build individual item card
  Widget _buildItemCard(BuildContext context, ItemModel item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(
          AppRoutes.editItem,
          extra: {'item': item, 'date': item.date},
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Icon/avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    item.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 20,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '฿${item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    if (item.amount > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'จำนวน: ${item.amount}',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (item.reason != null && item.reason!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.note_outlined,
                            size: 18,
                            color: Colors.orange[600],
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              item.reason!,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.orange[700],
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  iconSize: 24,
                  color: Colors.blue[700],
                  tooltip: 'แก้ไข',
                  onPressed: () => context.push(
                    AppRoutes.editItem,
                    extra: {'item': item, 'date': item.date},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Share menu as formatted text
  Future<void> _shareMenu(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    List<ItemModel> items,
  ) async {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ไม่มีรายการอาหารให้แชร์',
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final settings = ref.read(settingsProvider);
    final formattedText = _generateMenuText(
      settings.menuHeaderText,
      settings.menuFooterNote,
      selectedDate,
      items,
    );

    await Clipboard.setData(ClipboardData(text: formattedText));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'คัดลอกเมนูไปยังคลิปบอร์ดแล้ว',
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          action: SnackBarAction(
            label: 'ดู',
            textColor: Colors.white,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(
                    'ตัวอย่างข้อความ',
                    style: TextStyle(fontSize: 20),
                  ),
                  content: SingleChildScrollView(
                    child: SelectableText(
                      formattedText,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ปิด', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }
  }

  /// Generate formatted menu text
  String _generateMenuText(
    String headerText,
    String footerNote,
    DateTime date,
    List<ItemModel> items,
  ) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln(headerText);
    buffer.writeln(_formatDate(date));
    buffer.writeln();

    // Items
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final itemText = '${i + 1}. ${item.name} - ฿${item.price.toStringAsFixed(2)}';
      if (item.reason != null && item.reason!.isNotEmpty) {
        buffer.writeln('$itemText (${item.reason})');
      } else {
        buffer.writeln(itemText);
      }
    }

    // Footer
    if (footerNote.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(footerNote);
    }

    return buffer.toString();
  }

  /// Format date in Thai Buddhist calendar format
  String _formatDate(DateTime date) {
    final thaiMonths = [
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.',
    ];
    final day = date.day;
    final month = thaiMonths[date.month - 1];
    final year = date.year + 543; // Buddhist calendar
    return '$day $month $year';
  }

  /// Format day name in Thai
  String _formatDayName(DateTime date) {
    final thaiDays = [
      'จันทร์',
      'อังคาร',
      'พุธ',
      'พฤหัสบดี',
      'ศุกร์',
      'เสาร์',
      'อาทิตย์',
    ];
    return thaiDays[date.weekday - 1];
  }
}
