import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lost_and_found/main.dart';

final userProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = supabase.auth.currentUser;

  if (user == null) {
    throw Exception('Not logged in');
  }

  final profileData = await supabase
      .from('profiles')
      .select()
      .eq('id', user.id)
      .single();

  final rawAvatarUrl = profileData['avatar_url'] as String?;
  if (rawAvatarUrl != null) {
    final cacheBustedUrl = '$rawAvatarUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    profileData['avatar_url'] = cacheBustedUrl;
  }
  return profileData;
});
