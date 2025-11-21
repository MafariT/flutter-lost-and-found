import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/components/app_drawer.dart';
import 'package:flutter_lost_and_found/main.dart';
import 'package:flutter_lost_and_found/pages/feeds/pending_claims_feed.dart';

class PerantaraHomePage extends StatefulWidget {
  const PerantaraHomePage({super.key});

  @override
  State<PerantaraHomePage> createState() => _PerantaraHomePageState();
}

class _PerantaraHomePageState extends State<PerantaraHomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const PendingItemsFeed(),
    const PendingClaimsFeed(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_selectedIndex == 0 ? "Review New Items" : "Manage Claims"),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'New Items',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rule_folder_outlined),
            label: 'Claims',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class PendingItemsFeed extends StatefulWidget {
  const PendingItemsFeed({super.key});
  @override
  State<PendingItemsFeed> createState() => _PendingItemsFeedState();
}

class _PendingItemsFeedState extends State<PendingItemsFeed> {
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
    return FutureBuilder<List<Map<String, dynamic>>>(
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
              child: Text('No new found items are waiting for review.'),
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
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: item['image_url'] != null
                      ? SizedBox(
                          width: 50,
                          height: 50,
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
    );
  }
}
