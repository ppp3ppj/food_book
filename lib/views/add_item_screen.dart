import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/item_provider.dart';

/// Add Item Screen - Senior-friendly design with Thai language
/// Performance optimized with hooks for form management
class AddItemScreen extends HookConsumerWidget {
  final String? date;

  const AddItemScreen({super.key, this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Form key with hooks
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // Text controllers with hooks (auto-disposed)
    final nameController = useTextEditingController();
    final priceController = useTextEditingController();
    final reasonController = useTextEditingController();

    // Recent suggestions state
    final recentSuggestions = useState<List<Map<String, dynamic>>>([]);
    final isLoadingSuggestions = useState(false);

    // Load recent suggestions on mount
    useEffect(() {
      Future<void> loadSuggestions() async {
        isLoadingSuggestions.value = true;
        final suggestions = await ref
            .read(itemProvider.notifier)
            .getRecentItemSuggestions();
        recentSuggestions.value = suggestions;
        isLoadingSuggestions.value = false;
      }

      loadSuggestions();
      return null;
    }, []);

    // Fill form from suggestion
    void selectSuggestion(Map<String, dynamic> suggestion) {
      nameController.text = suggestion['name'] as String;
      priceController.text = (suggestion['price'] as num).toString();
      if (suggestion['reason'] != null) {
        reasonController.text = suggestion['reason'] as String;
      }
    }

    // Save item callback
    Future<void> saveItem() async {
      if (!formKey.currentState!.validate()) {
        return;
      }

      final name = nameController.text.trim();
      final price = double.parse(priceController.text.trim());
      final reason = reasonController.text.trim().isEmpty
          ? null
          : reasonController.text.trim();

      final success = await ref
          .read(itemProvider.notifier)
          .createItem(name, price, date: date, reason: reason);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'เพิ่ม "$name" เรียบร้อยแล้ว',
              style: const TextStyle(fontSize: 18),
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(20),
          ),
        );
        context.pop();
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'เพิ่มรายการอาหาร',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 72,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // Recent Suggestions Section
            if (recentSuggestions.value.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.history,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'รายการล่าสุด (แตะเพื่อเลือก)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 56,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recentSuggestions.value.length > 8
                      ? 8
                      : recentSuggestions.value.length,
                  itemBuilder: (context, index) {
                    final suggestion = recentSuggestions.value[index];
                    final usageCount = suggestion['usage_count'] as int;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        avatar: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.2),
                          child: Text(
                            usageCount.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        label: Text(
                          suggestion['name'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onPressed: () => selectSuggestion(suggestion),
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Divider(color: Colors.grey[300], thickness: 1),
              const SizedBox(height: 24),
            ],

            // Item Name Field
            Text(
              'ชื่อรายการ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: nameController,
              style: const TextStyle(fontSize: 20),
              decoration: InputDecoration(
                hintText: 'พิมพ์ชื่ออาหาร...',
                hintStyle: TextStyle(fontSize: 18, color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.restaurant_menu, size: 28),
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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'กรุณาใส่ชื่อรายการ';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),

            // Price Field
            Text(
              'ราคา (บาท)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: priceController,
              style: const TextStyle(fontSize: 20),
              decoration: InputDecoration(
                hintText: 'พิมพ์ราคา...',
                hintStyle: TextStyle(fontSize: 18, color: Colors.grey[400]),
                prefixIcon: Icon(
                  Icons.attach_money,
                  size: 28,
                  color: Colors.green[700],
                ),
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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'กรุณาใส่ราคา';
                }
                final price = double.tryParse(value);
                if (price == null || price < 0) {
                  return 'กรุณาใส่ราคาที่ถูกต้อง';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),

            // Reason Field (Optional)
            Text(
              'หมายเหตุ (ไม่บังคับ)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: reasonController,
              style: const TextStyle(fontSize: 20),
              decoration: InputDecoration(
                hintText: 'เช่น: เผ็ดมาก, ไม่ใส่ผัก...',
                hintStyle: TextStyle(fontSize: 18, color: Colors.grey[400]),
                prefixIcon: Icon(
                  Icons.note_outlined,
                  size: 28,
                  color: Colors.orange[700],
                ),
                helperText:
                    'ระบุรายละเอียดเพิ่มเติม เช่น ความเผ็ด หรือข้อควรระวัง',
                helperStyle: const TextStyle(fontSize: 16),
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
              ),
            ),
            const SizedBox(height: 40),

            // Save Button
            ElevatedButton.icon(
              onPressed: saveItem,
              icon: const Icon(Icons.save_rounded, size: 32),
              label: const Text(
                'บันทึก',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
