import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lost_and_found/main.dart';
import 'package:flutter_lost_and_found/providers/auth_provider.dart';

final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final authState = ref.watch(authStateProvider).value;

  if (authState?.session?.user == null) {
    return null;
  }

  final user = authState!.session!.user;
  final profileData = await supabase
      .from('profiles')
      .select()
      .eq('id', user.id)
      .single();

  final rawAvatarUrl = profileData['avatar_url'] as String?;
  if (rawAvatarUrl != null) {
    final cacheBustedUrl =
        '$rawAvatarUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    profileData['avatar_url'] = cacheBustedUrl;
  }
  return profileData;
});
