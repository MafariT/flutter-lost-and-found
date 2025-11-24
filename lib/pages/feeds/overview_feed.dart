import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/components/item_card.dart';
import 'package:flutter_lost_and_found/providers/items_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OverviewFeed extends ConsumerWidget {
  const OverviewFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(overviewItemsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Aktivitas Terbaru",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              Text(
                "Pantau barang hilang dan ditemukan terkini",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
            ],
          ),
        ),

        Expanded(
          child: overviewAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (items) {
              if (items.isEmpty) {
                return const Center(child: Text('Belum ada aktivitas terbaru.'));
              }
              return RefreshIndicator(
                onRefresh: () => ref.refresh(overviewItemsProvider.future),
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