import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/services/auth/auth_service.dart';

class GuestDrawer extends StatelessWidget {
  const GuestDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  child: Icon(Icons.person, size: 40, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 10),
                Text(
                  'Welcome, Guest!',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Login or Register'),
            subtitle: const Text('Create an account to report and claim items'),
            onTap: () {
              AuthService().signOut();
            },
          ),
        ],
      ),
    );
  }
}
