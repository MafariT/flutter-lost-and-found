
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lost_and_found/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return supabase.auth.onAuthStateChange;
});

final isGuestProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider).value;
  return authState?.session?.user != null && authState!.session!.user.isAnonymous;
});