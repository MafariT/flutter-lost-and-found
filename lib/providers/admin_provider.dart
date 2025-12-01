import 'dart:async';
import 'package:flutter_lost_and_found/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lost_and_found/main.dart';

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

  Future<void> deleteItem(String itemId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await supabase.from('items').delete().eq('id', itemId);
    });
  }
}

final adminUserListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(authStateProvider);
  return await supabase.from('profiles').select().neq('email', 'null').order('created_at', ascending: false);
});

final adminItemListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await supabase
      .from('items')
      .select()
      .neq('status', 'claimed')
      .neq('status', 'returned')
      .order('created_at', ascending: false);
});
