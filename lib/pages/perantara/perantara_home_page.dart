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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.error}'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
      if (previous is AsyncLoading && next is AsyncData) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Berhasil!'), backgroundColor: Colors.green));
        ref.invalidate(pendingItemsProvider);
        ref.invalidate(pendingClaimsProvider);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? "Kelola Barang Temuan" : "Kelola Claim Barang",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      drawer: const PrimaryDrawer(),
      body: _widgetOptions.elementAt(_selectedIndex),

      // --- FLAT BOTTOM NAV ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2_rounded),
              label: 'Barang Temuan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.rule_folder_outlined),
              activeIcon: Icon(Icons.rule_folder_rounded),
              label: 'Claim Barang',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey.shade400,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}
