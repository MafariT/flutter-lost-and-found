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
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (query) {
              ref.read(searchQueryProvider.notifier).updateQuery(query);
            },
            decoration: InputDecoration(
              hintText: 'Search for an item...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),

        Expanded(
          child: itemsAsyncValue.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            
            error: (error, stack) {
              return Center(child: Text('Error: $error'));
            },
            data: (items) {
              if (items.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(itemsFeedProvider(status).future),
                  child: ListView(
                    children: const [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(48.0),
                          child: Text('No items found.'),
                        ),
                      )
                    ],
                  ),
                );
              }
              
              return RefreshIndicator(
                onRefresh: () => ref.refresh(itemsFeedProvider(status).future),
                child: ListView.builder(
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