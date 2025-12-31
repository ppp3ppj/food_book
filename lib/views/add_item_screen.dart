import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/item_provider.dart';

/// Add Item Screen - Refactored with HookConsumerWidget
/// Performance optimized with hooks for form management
/// No StatefulWidget needed - all state managed with hooks
class AddItemScreen extends HookConsumerWidget {
  const AddItemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Form key with hooks
    final formKey = useMemoized(() => GlobalKey<FormState>());
    
    // Text controllers with hooks (auto-disposed)
    final nameController = useTextEditingController();
    final priceController = useTextEditingController();
    final amountController = useTextEditingController(text: '0');

    // Save item callback
    Future<void> saveItem() async {
      if (!formKey.currentState!.validate()) {
        return;
      }

      final name = nameController.text.trim();
      final price = double.parse(priceController.text.trim());
      final amount = int.tryParse(amountController.text.trim()) ?? 0;

      final success = await ref.read(itemProvider.notifier).createItem(
            name,
            price,
            amount: amount,
          );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item "$name" added successfully')),
        );
        context.pop();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.restaurant_menu),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter item name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Price (฿)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter price';
                }
                final price = double.tryParse(value);
                if (price == null || price < 0) {
                  return 'Please enter a valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory),
                helperText: 'Leave as 0 if not tracking inventory',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final amount = int.tryParse(value);
                  if (amount == null || amount < 0) {
                    return 'Please enter a valid amount';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: saveItem,
              icon: const Icon(Icons.save),
              label: const Text('Save Item'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
