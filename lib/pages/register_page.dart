import 'package:flutter_lost_and_found/services/auth/auth_service.dart';
import 'package:flutter_lost_and_found/components/primary_button.dart';
import 'package:flutter_lost_and_found/components/primary_text_field.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key, required this.onTap});
  final void Function()? onTap;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService _auth = AuthService();

  void register(BuildContext context) async {
    // Check if password match first
    if (_passwordController.text == _confirmPasswordController.text) {
      try {
        await _auth.signUpWithEmailPassword(
          _emailController.text,
          _passwordController.text,
        );
      } catch (e) {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) => AlertDialog(title: Text(e.toString())),
        );
      }
    } else {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) =>
            const AlertDialog(title: Text("Password Doesn't match!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 36),

            Text(
              "Lost and Found",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            const SizedBox(height: 24),

            PrimaryTextfield(
              label: "Email",
              hintText: "Email",
              obscureText: false,
              controller: _emailController,
            ),

            const SizedBox(height: 12),

            PrimaryTextfield(
              label: "Password",
              hintText: "Password",
              obscureText: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 12),

            PrimaryTextfield(
              label: "Confirm password",
              hintText: "Confirm password",
              obscureText: true,
              controller: _confirmPasswordController,
            ),

            const SizedBox(height: 24),

            PrimaryButton(text: "Register", onTap: () => register(context)),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Sudah punya akun? ",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    "Masuk disini",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
