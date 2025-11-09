import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/services/auth/login_and_register.dart';
import 'package:flutter_lost_and_found/services/auth/role_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.session?.user != null) {
            return const RoleGate();
          } else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}