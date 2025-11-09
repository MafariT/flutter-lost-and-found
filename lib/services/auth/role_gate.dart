import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/main.dart';
import 'package:flutter_lost_and_found/pages/admin/admin_home_page.dart';
import 'package:flutter_lost_and_found/pages/home_page.dart';

class RoleGate extends StatelessWidget {
  const RoleGate({super.key});

  @override
  Widget build(BuildContext context) {
    final String? uid = supabase.auth.currentUser?.id;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text("Error: Not logged in.")));
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: supabase.from('profiles').select().eq('id', uid).single(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("Error: ${snapshot.error}")));
        }

        if (snapshot.hasData) {
          final data = snapshot.data!;
          final String role = data['role'] ?? 'user';

          switch (role) {
            case 'admin':
              return AdminHomePage();
            case 'perantara':
            case 'user':
              return HomePage();
          }
        }
        
        return const Scaffold(body: Center(child: Text("User data not found.")));
      },
    );
  }
}