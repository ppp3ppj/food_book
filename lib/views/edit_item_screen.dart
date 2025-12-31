import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/item_model.dart';
import '../providers/item_provider.dart';

/// Edit Item Screen - Refactored with HookConsumerWidget
/// Performance optimized with hooks for form management
/// No StatefulWidget needed - all state managed with hooks
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
          const SnackBar(content: Text('Item updated successfully')),
        );
        context.pop();
      }
    }

    // Delete item callback
    Future<void> deleteItem() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Item'),
          content: Text('Are you sure you want to delete "${item.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        final success = await ref.read(itemProvider.notifier).deleteItem(item.id!);

        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Item "${item.name}" deleted')),
          );
          context.pop();
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red,
            onPressed: deleteItem,
            tooltip: 'Delete Item',
          ),
        ],
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
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory),
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
              onPressed: updateItem,
              icon: const Icon(Icons.save),
              label: const Text('Update Item'),
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
