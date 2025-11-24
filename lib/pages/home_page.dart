import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/components/guest_drawer.dart';
import 'package:flutter_lost_and_found/components/primary_drawer.dart';
import 'package:flutter_lost_and_found/pages/add_item_page.dart';
import 'package:flutter_lost_and_found/pages/feeds/items_feed.dart';
import 'package:flutter_lost_and_found/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const ItemsFeed(key: ValueKey('lost_feed'), status: 'lost'),
    const ItemsFeed(key: ValueKey('found_feed'), status: 'found'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = ref.watch(isGuestProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? "Barang Hilang" : "Barang Ditemukan",
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      drawer: isGuest ? GuestDrawer() : PrimaryDrawer(),
      body: _widgetOptions.elementAt(_selectedIndex),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.search_off_rounded),
              activeIcon: Icon(Icons.search_off_rounded),
              label: 'Lost',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline_rounded),
              activeIcon: Icon(Icons.check_circle_rounded),
              label: 'Found',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
        ),
      ),

      floatingActionButton: isGuest
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddItemPage()));
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 4,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                "Lapor",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}
