import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/item_model.dart';
import '../providers/database_provider.dart';
import 'menu_analysis_detail_screen.dart';

/// Menu Analysis Screen - View menu items across date range
/// Senior-friendly UI for analyzing menu history
class MenuAnalysisScreen extends HookConsumerWidget {
  const MenuAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);
    final startDate = useState<DateTime?>(null);
    final endDate = useState<DateTime?>(null);
    final isLoading = useState(false);
    final hasSearched = useState(false);
    final items = useState<List<ItemModel>>([]);
    final groupedByDate = useState<Map<String, List<ItemModel>>>({});

    // Load items for date range
    Future<void> loadDateRange() async {
      if (startDate.value == null || endDate.value == null) return;

      isLoading.value = true;
      hasSearched.value = true;
      try {
        final start = _formatDate(startDate.value!);
        final end = _formatDate(endDate.value!);

        final result = database.query(
          'SELECT * FROM items WHERE date BETWEEN ? AND ? ORDER BY date DESC, created_at DESC',
          [start, end],
        );

        final itemList = result.map((row) => ItemModel.fromMap(row)).toList();
        items.value = itemList;

        // Group by date
        final grouped = <String, List<ItemModel>>{};
        for (var item in itemList) {
          grouped.putIfAbsent(item.date, () => []).add(item);
        }
        groupedByDate.value = grouped;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เกิดข้อผิดพลาด: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'วิเคราะห์เมนู',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Date Range Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _DateButton(
                        label: 'วันที่เริ่มต้น',
                        date: startDate.value,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: startDate.value ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            startDate.value = picked;
                            if (endDate.value != null &&
                                picked.isAfter(endDate.value!)) {
                              endDate.value = picked;
                            }
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 32,
                        color: Colors.grey[600],
                      ),
                    ),
                    Expanded(
                      child: _DateButton(
                        label: 'วันที่สิ้นสุด',
                        date: endDate.value,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: endDate.value ?? DateTime.now(),
                            firstDate: startDate.value ?? DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            endDate.value = picked;
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed:
                        (startDate.value != null && endDate.value != null)
                        ? loadDateRange
                        : null,
                    icon: const Icon(Icons.analytics, size: 28),
                    label: const Text(
                      'ดูข้อมูล',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Compact Summary Bar
          if (items.value.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${groupedByDate.value.length} วัน',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 2,
                    height: 30,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.restaurant_menu,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${items.value.length} รายการ',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Items List
          Expanded(
            child: isLoading.value
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(strokeWidth: 5),
                        SizedBox(height: 20),
                        Text(
                          'กำลังโหลดข้อมูล...',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  )
                : items.value.isEmpty
                ? _buildEmptyState(
                    context,
                    hasSearched.value,
                    startDate.value,
                    endDate.value,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: groupedByDate.value.length,
                    itemBuilder: (context, index) {
                      final date = groupedByDate.value.keys.elementAt(index);
                      final dateItems = groupedByDate.value[date]!;
                      return _DateGroupCard(date: date, items: dateItems);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Build empty state based on context
  Widget _buildEmptyState(
    BuildContext context,
    bool hasSearched,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (!hasSearched) {
      // Initial state - no search performed yet
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  size: 56,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'เริ่มวิเคราะห์เมนู',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'เลือกวันที่เริ่มต้นและสิ้นสุด\nแล้วกดปุ่ม "ดูข้อมูล"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.orange[700],
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'ดูสรุปเมนูอาหารในช่วงเวลาที่ต้องการ',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.orange[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Search performed but no results found
      final dateRangeText = startDate != null && endDate != null
          ? '${_formatDateDisplay(startDate)} - ${_formatDateDisplay(endDate)}'
          : '';

      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.inbox_outlined,
                  size: 56,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'ไม่พบข้อมูล',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 10),
              if (dateRangeText.isNotEmpty) ...[
                Text(
                  dateRangeText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Text(
                'ไม่มีรายการอาหารในช่วงวันที่นี้',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  String _formatDateDisplay(DateTime date) {
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
    return '${date.day} ${thaiMonths[date.month - 1]} ${date.year + 543}';
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: date != null ? Colors.blue[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null ? Colors.blue : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text(
              date != null ? _formatDateDisplay(date!) : 'เลือกวันที่',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: date != null ? Colors.blue[900] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateDisplay(DateTime date) {
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
    return '${date.day} ${thaiMonths[date.month - 1]} ${date.year + 543}';
  }
}

class _DateGroupCard extends HookWidget {
  final String date;
  final List<ItemModel> items;

  const _DateGroupCard({required this.date, required this.items});

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(false);
    final displayItems = isExpanded.value ? items : items.take(3).toList();
    final hasMore = items.length > 3;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      MenuAnalysisDetailScreen(date: date, items: items),
                ),
              );
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.blue[700], size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _formatDateDisplay(date),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${items.length} รายการ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.blue[700],
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayItems.length,
            itemBuilder: (context, index) {
              final item = displayItems[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: index.isEven ? Colors.grey[50] : Colors.white,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.restaurant,
                          color: Colors.green[700],
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                          if (item.reason != null && item.reason!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.note,
                                    size: 16,
                                    color: Colors.orange[700],
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      item.reason!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.orange[700],
                                        fontWeight: FontWeight.w500,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '฿${item.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (hasMore)
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        MenuAnalysisDetailScreen(date: date, items: items),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  border: Border(
                    top: BorderSide(color: Colors.blue[100]!, width: 1),
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.blue[700],
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'ดูทั้งหมด ${items.length} รายการ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.open_in_full,
                        color: Colors.blue[700],
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDateDisplay(String dateStr) {
    final parts = dateStr.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);

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

    return '$day ${thaiMonths[month - 1]} ${year + 543}';
  }
}
