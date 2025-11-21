import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lost_and_found/main.dart';

final perantaraControllerProvider = AsyncNotifierProvider<PerantaraController, void>(PerantaraController.new);

class PerantaraController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> approveItem(String itemId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await supabase.from('items').update({'status': 'found'}).eq('id', itemId);
    });
  }

  Future<void> rejectItem(String itemId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await supabase.from('items').delete().eq('id', itemId);
    });
  }

  Future<void> approveClaim(String claimId, String itemId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await supabase.rpc(
        'approve_claim_and_update_item',
        params: {'claim_id_to_approve': claimId, 'item_id_to_update': itemId},
      );
    });
  }

  Future<void> rejectClaim(String claimId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await supabase.from('claims').update({'status': 'rejected'}).eq('id', claimId);
    });
  }
}

final pendingItemsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await supabase.from('items').select().eq('status', 'unverified_found').order('created_at', ascending: true);
});

final pendingClaimsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await supabase
      .from('claims')
      .select('*, items(*), profiles:claimer_id(*)')
      .eq('status', 'pending')
      .order('created_at', ascending: true);
});
