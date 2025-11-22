import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lost_and_found/main.dart';
import 'package:flutter_lost_and_found/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userProfileControllerProvider = AsyncNotifierProvider<UserProfileController, void>(UserProfileController.new);

class UserProfileController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<String?> _uploadAvatar(File imageFile) async {
    final userId = supabase.auth.currentUser!.id;
    final filePath = '$userId/avatar.png';
    try {
      await supabase.storage
          .from('avatars')
          .upload(filePath, imageFile, fileOptions: const FileOptions(cacheControl: '3600', upsert: true));
      final rawUrl = supabase.storage.from('avatars').getPublicUrl(filePath);
      return '$rawUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String name,
    required String nim,
    required String faculty,
    required String programStudy,
    File? imageFile,
  }) async {
    state = const AsyncValue.loading();
    try {
      String? newAvatarUrl;
      if (imageFile != null) {
        newAvatarUrl = await _uploadAvatar(imageFile);
      }

      final updates = {
        'id': supabase.auth.currentUser!.id,
        'name': name,
        'nim': nim,
        'faculty': faculty,
        'program_study': programStudy,
        if (newAvatarUrl != null) 'avatar_url': newAvatarUrl.split('?').first,
      };

      await supabase.from('profiles').upsert(updates);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final authState = ref.watch(authStateProvider).value;

  if (authState?.session?.user == null) {
    return null;
  }

  final user = authState!.session!.user;
  final profileData = await supabase.from('profiles').select().eq('id', user.id).single();

  final rawAvatarUrl = profileData['avatar_url'] as String?;
  if (rawAvatarUrl != null) {
    final cacheBustedUrl = '$rawAvatarUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    profileData['avatar_url'] = cacheBustedUrl;
  }
  return profileData;
});
