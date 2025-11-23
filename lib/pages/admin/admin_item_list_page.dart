import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/providers/admin_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminItemListPage extends ConsumerWidget {
  const AdminItemListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(adminItemListProvider);

    ref.listen<AsyncValue<void>>(adminControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${next.error}'), backgroundColor: Colors.red));
      }
      if (previous is AsyncLoading && next is AsyncData) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Item deleted successfully!'), backgroundColor: Colors.green));
        ref.invalidate(adminItemListProvider);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Manage All Items')),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No items found in database.'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _AdminItemTile(item: item);
            },
          );
        },
      ),
    );
  }
}

class _AdminItemTile extends ConsumerWidget {
  final Map<String, dynamic> item;
  const _AdminItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: item['image_url'] != null
            ? SizedBox(width: 50, height: 50, child: Image.network(item['image_url'], fit: BoxFit.cover))
            : const Icon(Icons.image_not_supported, size: 40),
        title: Text(item['item_name']),
        subtitle: Text('Status: ${item['status']}\nID: ${item['id']}'),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmDelete(context, ref, item['id'], item['item_name']),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String itemId, String itemName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item?'),
        content: Text('Are you sure you want to permanently delete "$itemName"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              ref.read(adminControllerProvider.notifier).deleteItem(itemId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
