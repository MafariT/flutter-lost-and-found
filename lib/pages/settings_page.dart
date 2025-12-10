import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/pages/profile_page.dart';
import 'package:flutter_lost_and_found/pages/settings/about_page.dart';
import 'package:flutter_lost_and_found/pages/settings/change_password_page.dart';
import 'package:flutter_lost_and_found/pages/settings/simple_text_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordPage()));
            },
          ),

          // const _SettingsHeader(title: 'Aplikasi'),
          // _SettingsTile(
          //   icon: Icons.notifications_outlined,
          //   title: 'Pemberitahuan',
          //   subtitle: 'Kelola preferensi pemberitahuan',
          //   onTap: () {
          //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur akan segera hadir!')));
          //   },
          // ),
          // const _ThemeToggleTile(),
          const _SettingsHeader(title: 'Bantuan'),
          _SettingsTile(
            icon: Icons.mail_outline_rounded,
            title: 'Hubungi Kami',
            subtitle: 'Laporkan masalah atau saran',
            onTap: () {
              _showContactDialog(context);
            },
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Syarat & Ketentuan',
            subtitle: 'Aturan penggunaan aplikasi',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SimpleTextPage(
                    title: "Syarat & Ketentuan",
                    content:
                        "1. Pengguna wajib memberikan informasi yang benar\n\n"
                        "2. Dilarang memposting barang ilegal\n\n"
                        "3. Pihak aplikasi tidak bertanggung jawab atas transaksi di luar aplikasi\n\n"
                        "4. Hormati sesama pengguna",
                  ),
                ),
              );
            },
          ),

          const _SettingsHeader(title: 'Tentang'),
          _SettingsTile(
            icon: Icons.policy_outlined,
            title: 'Kebijakan Privasi',
            subtitle: 'Lihat cara kami mengelola data',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SimpleTextPage(
                    title: "Kebijakan Privasi",
                    content:
                        "Kami menghargai privasi Anda. Data yang kami kumpulkan hanya digunakan untuk "
                        "keperluan verifikasi kepemilikan barang dan tidak akan dibagikan ke pihak ketiga "
                        "tanpa persetujuan Anda",
                  ),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'Tentang Aplikasi',
            subtitle: 'Versi 1.0.0',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
            },
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hubungi Kami'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Jika anda memiliki kendala, silahkan hubungi admin via email:'),
            SizedBox(height: 10),
            SelectableText('support@lostfound.id', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))],
      ),
    );
  }
}

// class _ThemeToggleTile extends StatelessWidget {
//   const _ThemeToggleTile();

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ThemeProvider>(
//       builder: (context, themeProvider, child) {
//         return ListTile(
//           leading: const Icon(Icons.color_lens_outlined),
//           title: const Text('Mode Gelap'),
//           subtitle: Text(themeProvider.isDarkMode ? 'Aktif' : 'Nonaktif', style: Theme.of(context).textTheme.bodySmall),
//           trailing: Switch(
//             value: themeProvider.isDarkMode,
//             onChanged: (value) {
//               Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
//             },
//           ),
//         );
//       },
//     );
//   }
// }

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
