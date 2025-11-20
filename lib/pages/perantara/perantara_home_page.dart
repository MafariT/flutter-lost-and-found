import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/components/app_drawer.dart';
import 'package:flutter_lost_and_found/main.dart';

class PerantaraHomePage extends StatefulWidget {
  const PerantaraHomePage({super.key});

  @override
  State<PerantaraHomePage> createState() => _PerantaraHomePageState();
}

class _PerantaraHomePageState extends State<PerantaraHomePage> {
  late Future<List<Map<String, dynamic>>> _pendingItemsFuture;

  @override
  void initState() {
    super.initState();
    _pendingItemsFuture = _fetchPendingItems();
  }

  Future<List<Map<String, dynamic>>> _fetchPendingItems() async {
    return await supabase
        .from('items')
        .select()
        .eq('status', 'unverified_found')
        .order('created_at', ascending: true);
  }

  Future<void> _refresh() async {
    setState(() {
      _pendingItemsFuture = _fetchPendingItems();
    });
  }

  Future<void> _approveItem(String itemId) async {
    await supabase.from('items').update({'status': 'found'}).eq('id', itemId);
    _refresh();
  }

  Future<void> _rejectItem(String itemId) async {
    await supabase.from('items').delete().eq('id', itemId);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Found Items Review"),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _pendingItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: const Center(
                child: Text('No found items are waiting for review.'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: item['image_url'] != null
                        ? SizedBox(
                            width: 50,
                            child: Image.network(
                              item['image_url'],
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.image_not_supported),
                    title: Text(item['item_name']),
                    subtitle: Text(item['description'] ?? 'No description'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          tooltip: 'Approve',
                          onPressed: () => _approveItem(item['id']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          tooltip: 'Reject',
                          onPressed: () => _rejectItem(item['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
