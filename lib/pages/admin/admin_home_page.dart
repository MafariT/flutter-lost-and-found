import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/components/primary_drawer.dart';
import 'package:flutter_lost_and_found/pages/admin/admin_item_list_page.dart';
import 'package:flutter_lost_and_found/pages/admin/admin_user_list_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      drawer: const PrimaryDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: [
                  _card(
                    context,
                    icon: Icons.people_alt_outlined,
                    label: 'Kelola User',
                    subLabel: 'Ubah Role & Akses Pengguna',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminUserListPage()));
                    },
                  ),
                  const SizedBox(height: 16),
                  _card(
                    context,
                    icon: Icons.inventory_2_outlined,
                    label: 'Kelola Barang',
                    subLabel: 'Hapus Postingan & Moderasi',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminItemListPage()));
                    },
                  ),
                  const SizedBox(height: 16),
                  _card(
                    context,
                    icon: Icons.analytics_outlined,
                    label: 'Statistik',
                    subLabel: 'Lihat Laporan Aktivitas',
                    color: Colors.purple,
                    onTap: () {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text("Fitur akan segera hadir")));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subLabel,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subLabel, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                ],
              ),
            ),

            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
