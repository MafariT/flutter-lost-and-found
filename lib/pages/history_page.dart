import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/providers/history_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(historyControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.error}'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
      if (previous is AsyncLoading && next is AsyncData) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Berhasil!'), backgroundColor: Colors.green));
        ref.invalidate(myItemsProvider);
      }
    });

    final myItems = ref.watch(myItemsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Riwayat Laporan',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: const [
              Tab(text: 'Kehilangan'),
              Tab(text: 'Temuan'),
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
                _HistoryList(items: lostItems, type: 'lost'),
                _HistoryList(items: foundItems, type: 'found'),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HistoryList extends ConsumerWidget {
  final List<Map<String, dynamic>> items;
  final String type;

  const _HistoryList({required this.items, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              type == 'lost' ? 'Tidak ada riwayat kehilangan' : 'Tidak ada riwayat temuan',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(myItemsProvider.future),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return _FlatHistoryCard(item: item, ref: ref);
        },
      ),
    );
  }
}

class _FlatHistoryCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final WidgetRef ref;

  const _FlatHistoryCard({required this.item, required this.ref});

  @override
  Widget build(BuildContext context) {
    final status = item['status'];
    final bool isFinished = status == 'returned' || status == 'claimed';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showActivityBottomSheet(context, ref, item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: item['image_url'] != null
                      ? Image.network(item['image_url'], fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey.shade100,
                          child: Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400),
                        ),
                ),
              ),
              const SizedBox(width: 16),

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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isFinished ? Colors.green.shade50 : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.toUpperCase().replaceAll('_', ' '),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isFinished ? Colors.green.shade700 : Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_shouldShowAction(status)) _buildActionButton(context, status, item['id']),
            ],
          ),
        ),
      ),
    );
  }

  bool _shouldShowAction(String status) {
    return status == 'lost' || status == 'unverified_found';
  }

  Widget _buildActionButton(BuildContext context, String status, String itemId) {
    if (status == 'lost') {
      return TextButton(
        onPressed: () => ref.read(historyControllerProvider.notifier).markItemAsReturned(itemId),
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: const Text('Ditemukan?'),
      );
    } else if (status == 'unverified_found') {
      return IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: () => ref.read(historyControllerProvider.notifier).deleteItem(itemId),
      );
    }
    return const SizedBox.shrink();
  }

  void _showActivityBottomSheet(BuildContext context, WidgetRef ref, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return _ActivityBottomSheetContent(item: item, ref: ref);
      },
    );
  }
}

class _ActivityBottomSheetContent extends ConsumerWidget {
  final Map<String, dynamic> item;
  final WidgetRef ref;

  const _ActivityBottomSheetContent({required this.item, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(relatedActivityProvider(item));
    final isLostItem = ['lost', 'returned'].contains(item['status']);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isLostItem ? 'Pesan Masuk' : 'Klaim Barang',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isLostItem ? 'Daftar orang yang menghubungi anda' : 'Daftar orang yang mengklaim barang ini',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: activityAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (activities) {
                if (activities.isEmpty) {
                  return Center(
                    child: Text('Belum ada aktivitas', style: TextStyle(color: Colors.grey.shade400)),
                  );
                }
                return ListView.separated(
                  itemCount: activities.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final act = activities[index];
                    final profile = act['public_profiles'];
                    final message = isLostItem ? act['message'] : act['claimant_message'];
                    final dateStr = act['created_at'];
                    String timeAgo = '';
                    if (dateStr != null) {
                      initializeDateFormatting('id', null);
                      final parsedDate = DateTime.parse(dateStr).toUtc().add(const Duration(hours: 7)); // UTC+7
                      timeAgo = DateFormat('EEEE, dd MMMM yyyy - HH:mm WIB', 'id').format(parsedDate);
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey.shade100,
                            backgroundImage: profile?['avatar_url'] != null
                                ? NetworkImage(profile['avatar_url'])
                                : null,
                            child: profile?['avatar_url'] == null
                                ? Icon(Icons.person, color: Colors.grey.shade400)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      profile?['name'] ?? 'Unknown',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(timeAgo, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(message ?? '', style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                                if (!isLostItem) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Status: ${act['status']}',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
