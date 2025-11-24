import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/pages/profile_page.dart';
import 'package:flutter_lost_and_found/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ListView(
        children: [
          const _SettingsHeader(title: 'Akun'),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Edit Profil',
            subtitle: 'Perbarui nama, fakultas, dan avatar',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
            },
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'Ubah Kata Sandi',
            subtitle: 'Perbarui atau ubah kata sandi anda',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feature coming soon!')));
            },
          ),

          const _SettingsHeader(title: 'Aplikasi'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Pemberitahuan',
            subtitle: 'Kelola preferensi pemberitahuan',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feature coming soon!')));
            },
          ),

          const _ThemeToggleTile(),

          const _SettingsHeader(title: 'Tentang'),
          _SettingsTile(
            icon: Icons.policy_outlined,
            title: 'Kebijakan Privasi',
            subtitle: 'lihat cara kami mengelola data',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feature coming soon!')));
            },
          ),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Dukungan dan Bantuan',
            subtitle: 'Dapatkan dukungan atau laporkan masalah',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feature coming soon!')));
            },
          ),
        ],
      ),
    );
  }
}

class _ThemeToggleTile extends StatelessWidget {
  const _ThemeToggleTile();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListTile(
          leading: const Icon(Icons.color_lens_outlined),
          title: const Text('Mode Gelap'),
          subtitle: Text(
            themeProvider.isDarkMode ? 'Aktif' : 'Nonaktif',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: Switch(
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        );
      },
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final String title;
  const _SettingsHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      onTap: onTap,
    );
  }
}
