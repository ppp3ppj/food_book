import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/item_model.dart';
import '../providers/item_provider.dart';

/// Edit Item Screen - Senior-friendly design with Thai language
/// Performance optimized with hooks for form management
class EditItemScreen extends HookConsumerWidget {
  final ItemModel item;

  const EditItemScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Form key with hooks
    final formKey = useMemoized(() => GlobalKey<FormState>());
    
    // Text controllers with hooks (initialized with item data, auto-disposed)
    final nameController = useTextEditingController(text: item.name);
    final priceController = useTextEditingController(text: item.price.toString());
    final amountController = useTextEditingController(text: item.amount.toString());

    // Update item callback
    Future<void> updateItem() async {
      if (!formKey.currentState!.validate()) {
        return;
      }

      final name = nameController.text.trim();
      final price = double.parse(priceController.text.trim());
      final amount = int.tryParse(amountController.text.trim()) ?? 0;

      final success = await ref.read(itemProvider.notifier).updateItem(
            item.id!,
            name,
            price,
            amount: amount,
          );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'บันทึกการแก้ไขเรียบร้อยแล้ว',
              style: TextStyle(fontSize: 18),
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

    // Delete item callback
    Future<void> deleteItem() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'ลบรายการ',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'คุณแน่ใจหรือไม่ที่จะลบ "${item.name}"?',
            style: const TextStyle(fontSize: 20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          actionsPadding: const EdgeInsets.all(16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'ยกเลิก',
                style: TextStyle(fontSize: 20),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'ลบ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        final success = await ref.read(itemProvider.notifier).deleteItem(item.id!);

        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'ลบ "${item.name}" เรียบร้อยแล้ว',
                style: const TextStyle(fontSize: 18),
              ),
              backgroundColor: Colors.red[700],
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
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'แก้ไขรายการ',
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.delete_rounded, size: 32),
              color: Colors.red[300],
              onPressed: deleteItem,
              tooltip: 'ลบรายการ',
              iconSize: 32,
            ),
          ),
        ],
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
              'จำนวน',
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
            const SizedBox(height: 40),
            
            // Update Button
            ElevatedButton.icon(
              onPressed: updateItem,
              icon: const Icon(Icons.save_rounded, size: 32),
              label: const Text(
                'บันทึกการแก้ไข',
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
