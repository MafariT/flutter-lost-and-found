import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/services/auth/auth_service.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Admin HomePage"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              AuthService().signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(child: Text("Welcome, Admin!")),
    );
  }
}
