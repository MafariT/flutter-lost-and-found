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
        ).showSnackBar(const SnackBar(content: Text('User role updated!'), backgroundColor: Colors.green));
        ref.invalidate(adminUserListProvider);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Kelola User',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (users) {
          if (users.isEmpty) return const Center(child: Text('Tidak ada user found.'));

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: users.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = users[index];
              return _FlatUserTile(user: user);
            },
          );
        },
      ),
    );
  }
}

class _FlatUserTile extends ConsumerWidget {
  final Map<String, dynamic> user;
  const _FlatUserTile({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRole = user['role'] ?? 'user';
    final email = user['email'] ?? 'No Email';
    final name = user['name'] ?? 'Guest / No Name';
    final userId = user['id'];

    Color roleColor = Colors.grey;
    if (currentRole == 'admin') roleColor = Colors.red;
    if (currentRole == 'perantara') roleColor = Colors.orange;
    if (currentRole == 'user') roleColor = Colors.blue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade100,
            backgroundImage: user['avatar_url'] != null ? NetworkImage(user['avatar_url']) : null,
            child: user['avatar_url'] == null
                ? Text(name.toUpperCase(), style: TextStyle(color: Colors.grey.shade600))
                : null,
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(email, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: roleColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    currentRole.toUpperCase(),
                    style: TextStyle(color: roleColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: Colors.grey.shade600,
            onPressed: () => _showRoleDialog(context, ref, userId, currentRole, name),
          ),
        ],
      ),
    );
  }

  void _showRoleDialog(BuildContext context, WidgetRef ref, String userId, String currentRole, String userName) {
    showDialog(
      context: context,
      builder: (context) {
        String selectedRole = currentRole;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Ubah Role User'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Ubah role akses untuk $userName:'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'user', child: Text('User (Mahasiswa)')),
                      DropdownMenuItem(value: 'perantara', child: Text('Perantara (Satpam)')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (val) => setState(() => selectedRole = val!),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (selectedRole != currentRole) {
                      ref.read(adminControllerProvider.notifier).updateUserRole(userId, selectedRole);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
