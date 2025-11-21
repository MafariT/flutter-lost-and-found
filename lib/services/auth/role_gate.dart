import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/main.dart';
import 'package:flutter_lost_and_found/pages/admin/admin_home_page.dart';
import 'package:flutter_lost_and_found/pages/home_page.dart';
import 'package:flutter_lost_and_found/pages/perantara/perantara_home_page.dart';

class RoleGate extends StatelessWidget {
  const RoleGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    final String role = user.appMetadata['role'] ?? 'user';

    switch (role) {
      case 'admin':
        return const AdminHomePage();
      case 'perantara':
        return const PerantaraHomePage();
      case 'user':
        return const HomePage();
      default:
        return const HomePage();
    }
  }
}
