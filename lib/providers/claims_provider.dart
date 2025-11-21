import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lost_and_found/main.dart';

final claimsControllerProvider = AsyncNotifierProvider<ClaimsController, void>(ClaimsController.new);

class ClaimsController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> submitClaim({required String itemId, required String finderId, required String message}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await supabase.from('claims').insert({
        'item_id': itemId,
        'claimer_id': supabase.auth.currentUser!.id,
        'finder_id': finderId,
        'claimant_message': message,
      });
    });
  }

  Future<void> submitContact({required String itemId, required String ownerId, required String message}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await supabase.from('contacts').insert({
        'item_id': itemId,
        'sender_id': supabase.auth.currentUser!.id,
        'receiver_id': ownerId,
        'message': message,
      });
    });
  }
}

final claimStatusProvider = FutureProvider.family<String, String>((ref, itemId) async {
  final currentUser = supabase.auth.currentUser;
  final item = await supabase.from('items').select('status, user_id').eq('id', itemId).single();
  final itemStatus = item['status'];
  final ownerId = item['user_id'];

  if (currentUser == null || currentUser.id == ownerId) {
    return 'hide';
  }

  if (itemStatus == 'found') {
    final claims = await supabase
        .from('claims')
        .select('id')
        .eq('item_id', itemId)
        .eq('claimer_id', currentUser.id)
        .limit(1);
    return claims.isEmpty ? 'can_claim' : 'claim_pending';
  } else if (itemStatus == 'lost') {
    final contacts = await supabase
        .from('contacts')
        .select('id')
        .eq('item_id', itemId)
        .eq('sender_id', currentUser.id)
        .limit(1);
    return contacts.isEmpty ? 'can_contact' : 'contacted';
  }

  return 'hide';
});
