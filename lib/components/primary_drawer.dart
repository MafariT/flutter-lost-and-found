import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/pages/profile_page.dart';
import 'package:flutter_lost_and_found/pages/settings_page.dart';
import 'package:flutter_lost_and_found/providers/user_provider.dart';
import 'package:flutter_lost_and_found/services/auth/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrimaryDrawer extends ConsumerWidget {
  const PrimaryDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsyncValue = ref.watch(userProfileProvider);

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          profileAsyncValue.when(
            data: (profile) {
              final avatarUrl = profile?['avatar_url'];
              final name = profile?['name'];
              final email = profile?['email'];

              return DrawerHeader(
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      backgroundImage: (avatarUrl != null) ? NetworkImage(avatarUrl) : null,
                      child: (avatarUrl == null) ? const Icon(Icons.person, size: 40) : null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name ?? email,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary),
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary),
              child: const Center(child: Text('Error loading profile')),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('My History'),
            onTap: () {
              // TODO: Navigate to history page
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              AuthService().signOut();
            },
          ),
        ],
      ),
    );
  }
}
