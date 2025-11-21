import 'dart:async';
import 'dart:io';
import 'package:flutter_lost_and_found/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, void>(ProfileController.new);

class ProfileController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
  }

  Future<String?> _uploadAvatar(File imageFile) async {
    final userId = supabase.auth.currentUser!.id;
    final filePath = '$userId/avatar.png';
    try {
      await supabase.storage.from('avatars').upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
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