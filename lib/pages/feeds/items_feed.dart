import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/components/item_card.dart';
import 'package:flutter_lost_and_found/providers/items_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemsFeed extends ConsumerWidget {
  final String status;
  const ItemsFeed({super.key, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsyncValue = ref.watch(itemsFeedProvider(status));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
            child: TextField(
              onChanged: (query) {
                ref.read(searchQueryProvider.notifier).updateQuery(query);
              },
              decoration: InputDecoration(
                hintText: 'Cari barang...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.primary),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                filled: false,
              ),
            ),
          ),
        ),

        Expanded(
          child: itemsAsyncValue.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (items) {
              if (items.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(itemsFeedProvider(status).future),
                  child: ListView(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.inbox_rounded, size: 60, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text('Barang tidak ditemukan', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                color: Theme.of(context).colorScheme.primary,
                onRefresh: () => ref.refresh(itemsFeedProvider(status).future),
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ItemCard(item: item);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
