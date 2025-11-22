import 'dart:async';
import 'package:flutter_lost_and_found/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lost_and_found/main.dart';

final historyControllerProvider = AsyncNotifierProvider<HistoryController, void>(HistoryController.new);

class HistoryController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> markItemAsReturned(String itemId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await supabase.from('items').update({'status': 'returned'}).eq('id', itemId);
    });
  }

  Future<void> deleteItem(String itemId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await supabase.from('items').delete().eq('id', itemId);
    });
  }
}

final myItemsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(authStateProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return [];

  return await supabase.from('items').select().eq('user_id', user.id).order('created_at');
});

final relatedActivityProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>((
  ref,
  item,
) async {
  ref.watch(authStateProvider);
  final itemId = item['id'] as String;

  final response = await supabase.rpc('get_activity_for_item', params: {'p_item_id': itemId});

  return List<Map<String, dynamic>>.from(response);
});
