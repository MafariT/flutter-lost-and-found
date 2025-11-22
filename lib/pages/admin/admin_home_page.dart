import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/components/primary_drawer.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Admin Dashboard"),
        centerTitle: true,
      ),
      drawer: const PrimaryDrawer(),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: [
          _buildDashboardCard(
            context,
            icon: Icons.people_outline,
            label: 'Manage Users',
            onTap: () {
              /* TODO: Navigate to user management page */
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.inventory_2_outlined,
            label: 'Manage Items',
            onTap: () {
              /* TODO: Navigate to item management page */
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.analytics_outlined,
            label: 'View Stats',
            onTap: () {
              /* TODO: Navigate to statistics page */
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
