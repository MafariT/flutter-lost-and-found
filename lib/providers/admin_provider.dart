import 'dart:async';
import 'package:flutter_lost_and_found/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lost_and_found/main.dart';

final adminUserListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(authStateProvider);
  return await supabase.from('profiles').select().neq('email', 'null').order('created_at', ascending: false);
});

final adminControllerProvider = AsyncNotifierProvider<AdminController, void>(AdminController.new);

class AdminController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> updateUserRole(String userId, String newRole) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await supabase.from('profiles').update({'role': newRole}).eq('id', userId);
    });
  }
}
