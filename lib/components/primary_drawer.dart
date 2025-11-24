import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/pages/history_page.dart';
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
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: profileAsyncValue.when(
              data: (profile) {
                final avatarUrl = profile?['avatar_url'];
                final name = profile?['name'];
                final email = profile?['email'];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundImage: (avatarUrl != null) ? NetworkImage(avatarUrl) : null,
                        child: (avatarUrl == null) ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name ?? email,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
              error: (_, __) => const Text('Error loading profile', style: TextStyle(color: Colors.white)),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              children: <Widget>[
                _DrawerTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Profil',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
                  },
                ),
                _DrawerTile(
                  icon: Icons.history_rounded,
                  title: 'Riwayat',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryPage()));
                  },
                ),
                _DrawerTile(
                  icon: Icons.settings_outlined,
                  title: 'Pengaturan',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                  },
                ),

                const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Divider(height: 1)),

                _DrawerTile(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  color: Theme.of(context).colorScheme.error,
                  onTap: () {
                    AuthService().signOut();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerTile({required this.icon, required this.title, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: color ?? Colors.grey.shade700, size: 24),
      title: Text(
        title,
        style: TextStyle(color: color ?? Colors.black87, fontWeight: FontWeight.w600, fontSize: 15),
      ),
      onTap: onTap,
    );
  }
}
