import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/pages/home_page.dart';
import 'package:flutter_lost_and_found/services/auth/login_and_register.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override // Check if user is login or not
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomePage();
          } else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}