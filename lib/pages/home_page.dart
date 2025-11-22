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
      backgroundColor: Theme.of(context).colorScheme.surface,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Lost & Found"),
        centerTitle: true,
      ),

      drawer: isGuest ? GuestDrawer() : PrimaryDrawer(),

      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.search_off), label: 'Lost Items'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Found Items'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.inversePrimary,
        unselectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),

      floatingActionButton: isGuest
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddItemPage()));
              },
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              child: Icon(Icons.add, color: Theme.of(context).colorScheme.surface),
            ),
    );
  }
}
