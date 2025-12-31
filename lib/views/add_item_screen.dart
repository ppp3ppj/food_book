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
    final amountController = useTextEditingController(text: '0');
    final reasonController = useTextEditingController();

    // Save item callback
    Future<void> saveItem() async {
      if (!formKey.currentState!.validate()) {
        return;
      }

      final name = nameController.text.trim();
      final price = double.parse(priceController.text.trim());
      final amount = int.tryParse(amountController.text.trim()) ?? 0;
      final reason = reasonController.text.trim().isEmpty ? null : reasonController.text.trim();

      final success = await ref.read(itemProvider.notifier).createItem(
            name,
            price,
            amount: amount,
            date: date,
            reason: reason,
          );

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
                prefixIcon: Icon(Icons.attach_money, size: 28, color: Colors.green[700]),
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
            
            // Amount Field
            Text(
              'จำนวน (ไม่บังคับ)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: amountController,
              style: const TextStyle(fontSize: 20),
              decoration: InputDecoration(
                hintText: 'พิมพ์จำนวน...',
                hintStyle: TextStyle(fontSize: 18, color: Colors.grey[400]),
                prefixIcon: Icon(Icons.inventory_2_outlined, size: 28, color: Colors.blue[700]),
                helperText: 'ใส่ 0 หากไม่ต้องการนับจำนวน',
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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final amount = int.tryParse(value);
                  if (amount == null || amount < 0) {
                    return 'กรุณาใส่จำนวนที่ถูกต้อง';
                  }
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
                prefixIcon: Icon(Icons.note_outlined, size: 28, color: Colors.orange[700]),
                helperText: 'ระบุรายละเอียดเพิ่มเติม เช่น ความเผ็ด หรือข้อควรระวัง',
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
