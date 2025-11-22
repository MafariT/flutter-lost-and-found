import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/providers/history_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(historyControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${next.error}'), backgroundColor: Colors.red));
      }
      if (previous is AsyncLoading && next is AsyncData) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Action successful!'), backgroundColor: Colors.green));
        ref.invalidate(myItemsProvider);
      }
    });

    final myItems = ref.watch(myItemsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My History'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Lost Items'),
              Tab(text: 'My Found Items'),
            ],
          ),
        ),
        body: myItems.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (items) {
            final lostItems = items.where((i) => ['lost', 'returned'].contains(i['status'])).toList();
            final foundItems = items
                .where((i) => ['found', 'unverified_found', 'claimed'].contains(i['status']))
                .toList();

            return TabBarView(
              children: [
                _ItemList(items: lostItems),
                _ItemList(items: foundItems),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ItemList extends ConsumerWidget {
  final List<Map<String, dynamic>> items;
  const _ItemList({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.refresh(myItemsProvider.future),
        child: const Center(child: Text('You have not reported any items in this category.')),
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.refresh(myItemsProvider.future),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: item['image_url'] != null
                ? SizedBox(width: 50, height: 50, child: Image.network(item['image_url'], fit: BoxFit.cover))
                : const Icon(Icons.image_not_supported, size: 40),
            title: Text(item['item_name']),
            subtitle: Text('Status: ${item['status']}'),
            trailing: _buildActionForStatus(context, ref, item),
            onTap: () => _showActivityDialog(context, ref, item),
          );
        },
      ),
    );
  }

  Widget? _buildActionForStatus(BuildContext context, WidgetRef ref, Map<String, dynamic> item) {
    final status = item['status'];
    final itemId = item['id'];

    switch (status) {
      case 'lost':
        return ElevatedButton(
          onPressed: () => ref.read(historyControllerProvider.notifier).markItemAsReturned(itemId),
          child: const Text('Mark as Returned'),
        );
      case 'found':
      case 'unverified_found':
        return IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          tooltip: 'Delete Listing',
          onPressed: () => ref.read(historyControllerProvider.notifier).deleteItem(itemId),
        );
      case 'returned':
      case 'claimed':
        return Chip(label: Text(status!), backgroundColor: Colors.grey.shade300);
      default:
        return null;
    }
  }

  void _showActivityDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final activity = ref.watch(relatedActivityProvider(item));
            final isLostItem = item['status'] == 'lost';

            return AlertDialog(
              title: Text(isLostItem ? 'Contacts for your Item' : 'Claims on your Item'),
              content: SizedBox(
                width: double.maxFinite,
                child: activity.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error: $err'),
                  data: (activities) {
                    if (activities.isEmpty) {
                      return const Center(child: Text('No activity yet.'));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final act = activities[index];
                        final profile = act['public_profiles'];
                        final message = isLostItem ? act['message'] : act['claimant_message'];

                        return Card(
                          child: ListTile(
                            title: Text('From: ${profile?['name']}'),
                            subtitle: Text(message ?? 'No message.'),
                            trailing: isLostItem ? null : Text(act['status']),
                            leading: CircleAvatar(
                              backgroundImage: profile?['avatar_url'] != null
                                  ? NetworkImage(profile['avatar_url'])
                                  : null,
                              child: profile?['avatar_url'] == null ? const Icon(Icons.person) : null,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
            );
          },
        );
      },
    );
  }
}
