import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/components/app_drawer.dart';
import 'package:flutter_lost_and_found/pages/add_item_page.dart';
import 'package:flutter_lost_and_found/pages/feeds/found_item_feed.dart';
import 'package:flutter_lost_and_found/pages/feeds/lost_item_feed.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const LostItemFeed(),
    const FoundItemFeed(),
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
        title: const Text("Lost & Found"),
        centerTitle: true,
      ),

      drawer: const AppDrawer(),

      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search_off),
            label: 'Lost Items',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Found Items',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.inversePrimary,
        unselectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddItemPage()),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.surface),
      ),
    );
  }
}
