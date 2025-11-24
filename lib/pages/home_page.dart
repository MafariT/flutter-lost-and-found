import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/components/guest_drawer.dart';
import 'package:flutter_lost_and_found/components/primary_drawer.dart';
import 'package:flutter_lost_and_found/pages/add_item_page.dart';
import 'package:flutter_lost_and_found/pages/feeds/items_feed.dart';
import 'package:flutter_lost_and_found/pages/feeds/overview_feed.dart';
import 'package:flutter_lost_and_found/pages/profile_page.dart';
import 'package:flutter_lost_and_found/providers/auth_provider.dart';
import 'package:flutter_lost_and_found/services/auth/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 2) {
      final isGuest = ref.read(isGuestProvider);
      if (isGuest) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Silahkan login untuk lapor barang'),
            action: SnackBarAction(label: 'Login', onPressed: () => AuthService().signOut()),
          ),
        );
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddItemPage()));
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = ref.watch(isGuestProvider);

    Widget bodyContent;
    switch (_selectedIndex) {
      case 0:
        bodyContent = const OverviewFeed();
        break;
      case 1:
        bodyContent = const ItemsFeed(key: ValueKey('lost'), status: 'lost');
        break;
      case 3:
        bodyContent = const ItemsFeed(key: ValueKey('found'), status: 'found');
        break;
      case 4:
        bodyContent = isGuest ? const _GuestProfilePlaceholder() : const ProfilePage();
        break;
      default:
        bodyContent = const OverviewFeed();
    }

    String appBarTitle = "Lost & Found";
    if (_selectedIndex == 0) appBarTitle = "Beranda";
    if (_selectedIndex == 1) appBarTitle = "Barang Hilang";
    if (_selectedIndex == 3) appBarTitle = "Barang Ditemukan";
    if (_selectedIndex == 4) appBarTitle = "Profil Saya";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(appBarTitle, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        elevation: 0,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),

      drawer: isGuest ? const GuestDrawer() : const PrimaryDrawer(),

      body: bodyContent,

      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey.shade400,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),

          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
            const BottomNavigationBarItem(icon: Icon(Icons.search_off_rounded), label: 'Hilang'),

            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
              ),
              label: '',
            ),

            const BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline_rounded), label: 'Ditemukan'),

            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestProfilePlaceholder extends StatelessWidget {
  const _GuestProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          const Text("Menu Profil Terkunci", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Silahkan login untuk mengakses profil anda", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => AuthService().signOut(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Login Sekarang"),
          ),
        ],
      ),
    );
  }
}
