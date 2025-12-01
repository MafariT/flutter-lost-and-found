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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${next.error}'), backgroundColor: Colors.red));
      }
      if (previous is AsyncLoading && next is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item dihapus!'), backgroundColor: Colors.green));
        ref.invalidate(adminItemListProvider);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Kelola Semua Barang', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('Database barang kosong'));
          
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _FlatAdminItemTile(item: item, ref: ref);
            },
          );
        },
      ),
    );
  }
}

class _FlatAdminItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final WidgetRef ref;

  const _FlatAdminItemTile({required this.item, required this.ref});

  @override
  Widget build(BuildContext context) {
    final status = item['status'] ?? 'unknown';
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 60,
              child: item['image_url'] != null
                  ? Image.network(item['image_url'], fit: BoxFit.cover)
                  : Container(color: Colors.grey.shade100, child: const Icon(Icons.image_not_supported_outlined)),
            ),
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['item_name'] ?? 'No Name',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item['description'] ?? 'No Description',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'STATUS: ${status.toUpperCase()}',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context, item['id'], item['item_name']),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String itemId, String itemName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Permanen?'),
        content: Text('Anda yakin ingin menghapus "$itemName"? Tindakan ini tidak dapat dibatalkan'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              ref.read(adminControllerProvider.notifier).deleteItem(itemId);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}