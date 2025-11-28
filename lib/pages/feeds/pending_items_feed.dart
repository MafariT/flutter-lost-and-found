import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/providers/perantara_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingItemsFeed extends ConsumerWidget {
  const PendingItemsFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingItems = ref.watch(pendingItemsProvider);

    return pendingItems.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (items) {
        if (items.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => ref.refresh(pendingItemsProvider.future),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Tidak ada laporan temuan barang', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(pendingItemsProvider.future),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _FlatPendingItemCard(item: item, ref: ref);
            },
          ),
        );
      },
    );
  }
}

class _FlatPendingItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final WidgetRef ref;

  const _FlatPendingItemCard({required this.item, required this.ref});

  @override
  Widget build(BuildContext context) {
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
              width: 80,
              height: 80,
              child: item['image_url'] != null
                  ? Image.network(item['image_url'], fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey.shade100,
                      child: Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['item_name'] ?? 'No Name',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item['description'] ?? 'Tidak ada deskripsi',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => ref.read(perantaraControllerProvider.notifier).rejectItem(item['id']),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Tolak',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Approve Button
                    InkWell(
                      onTap: () => ref.read(perantaraControllerProvider.notifier).approveItem(item['id']),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          border: Border.all(color: Colors.green.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Terima',
                          style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
