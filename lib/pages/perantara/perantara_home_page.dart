import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/components/primary_drawer.dart';
import 'package:flutter_lost_and_found/pages/feeds/pending_claims_feed.dart';
import 'package:flutter_lost_and_found/pages/feeds/pending_items_feed.dart';
import 'package:flutter_lost_and_found/providers/perantara_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PerantaraHomePage extends ConsumerStatefulWidget {
  const PerantaraHomePage({super.key});

  @override
  ConsumerState<PerantaraHomePage> createState() => _PerantaraHomePageState();
}

class _PerantaraHomePageState extends ConsumerState<PerantaraHomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[const PendingItemsFeed(), const PendingClaimsFeed()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(perantaraControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${next.error}'), backgroundColor: Colors.red));
      }
      if (previous is AsyncLoading && next is AsyncData) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Action successful!'), backgroundColor: Colors.green));
        ref.invalidate(pendingItemsProvider);
        ref.invalidate(pendingClaimsProvider);
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(_selectedIndex == 0 ? "Review New Items" : "Manage Claims"), centerTitle: true),
      drawer: const PrimaryDrawer(),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'New Items'),
          BottomNavigationBarItem(icon: Icon(Icons.rule_folder_outlined), label: 'Claims'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
