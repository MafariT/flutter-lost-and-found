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
            child: const Center(child: Text('No new items to review.')),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(pendingItemsProvider.future),
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(item['item_name']),
                  subtitle: Text(item['description'] ?? 'No description'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => ref.read(perantaraControllerProvider.notifier).approveItem(item['id']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => ref.read(perantaraControllerProvider.notifier).rejectItem(item['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
