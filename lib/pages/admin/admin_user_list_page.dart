import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/providers/admin_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminUserListPage extends ConsumerWidget {
  const AdminUserListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUserListProvider);

    ref.listen<AsyncValue<void>>(adminControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${next.error}'), backgroundColor: Colors.red));
      }
      if (previous is AsyncLoading && next is AsyncData) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User updated successfully!'), backgroundColor: Colors.green));
        ref.invalidate(adminUserListProvider);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _UserListTile(user: user);
            },
          );
        },
      ),
    );
  }
}

class _UserListTile extends ConsumerWidget {
  final Map<String, dynamic> user;
  const _UserListTile({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRole = user['role'];
    final email = user['email'];
    final name = user['name'] ?? 'No Name';
    final userId = user['id'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user['avatar_url'] != null ? NetworkImage(user['avatar_url']) : null,
          child: user['avatar_url'] == null ? const Icon(Icons.person, size: 24) : null,
        ),
        title: Text(name),
        subtitle: Text(email),
        trailing: DropdownButton<String>(
          value: currentRole,
          items: const [
            DropdownMenuItem(value: 'user', child: Text('User')),
            DropdownMenuItem(value: 'perantara', child: Text('Perantara')),
            DropdownMenuItem(value: 'admin', child: Text('Admin')),
          ],
          onChanged: (newRole) {
            if (newRole != null && newRole != currentRole) {
              _confirmRoleChange(context, ref, userId, newRole, name);
            }
          },
        ),
      ),
    );
  }

  void _confirmRoleChange(BuildContext context, WidgetRef ref, String userId, String newRole, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Change'),
        content: Text('Are you sure you want to change $userName\'s role to $newRole?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(adminControllerProvider.notifier).updateUserRole(userId, newRole);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
