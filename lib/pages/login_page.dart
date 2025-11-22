import 'package:flutter_lost_and_found/components/primary_text_field.dart';
import 'package:flutter_lost_and_found/services/auth/auth_service.dart';
import 'package:flutter_lost_and_found/components/primary_button.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key, required this.onTap});
  final void Function()? onTap;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _auth = AuthService();

  void login(BuildContext context) async {
    try {
      await _auth.signInWithEmailPassword(_emailController.text, _passwordController.text);
    } catch (e) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => AlertDialog(title: const Text("Login Failed"), content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/splash-background.png'),
                fit: BoxFit.cover,
                opacity: 0.5,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 120,
                    backgroundColor: Colors.transparent,
                    child: Image(image: AssetImage('assets/images/logo-clear.png')),
                  ),

                  const SizedBox(height: 50),

                  PrimaryTextfield(label: "Email", hintText: "Email", obscureText: false, controller: _emailController),

                  const SizedBox(height: 12),

                  PrimaryTextfield(
                    label: "Password",
                    hintText: "Password",
                    obscureText: true,
                    controller: _passwordController,
                  ),

                  const SizedBox(height: 30),

                  PrimaryButton(
                    text: "LOGIN",
                    onTap: () => login(context),
                    color: Colors.blue.shade400,
                    textColor: Colors.white,
                  ),

                  const SizedBox(height: 10),

                  PrimaryButton(
                    text: "Continue as Guest",
                    onTap: () {
                      AuthService().signInAnonymously();
                    },
                    color: Colors.grey.shade700,
                    textColor: Colors.white,
                  ),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Belum punya akun? ",
                        style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.inversePrimary),
                      ),
                      GestureDetector(
                        onTap: onTap,
                        child: Text(
                          "Buat disini",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade400),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
