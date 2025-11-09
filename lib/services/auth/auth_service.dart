import 'package:flutter_lost_and_found/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final GoTrueClient _auth = supabase.auth;

  // Sign in
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final AuthResponse res = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      return res;
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Sign up
  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final AuthResponse res = await _auth.signUp(
        email: email,
        password: password,
      );
      return res;
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}