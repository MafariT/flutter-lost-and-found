import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/providers/auth_provider.dart';
import 'package:flutter_lost_and_found/services/auth/login_and_register.dart';
import 'package:flutter_lost_and_found/services/auth/role_gate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (data) {
        if (data.session?.user != null) {
          return const RoleGate();
        } else {
          return const LoginOrRegister();
        }
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text('Error in auth stream: $error'))),
    );
  }
}
