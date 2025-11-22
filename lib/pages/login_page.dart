import 'package:flutter_lost_and_found/components/primary_button.dart';
import 'package:flutter_lost_and_found/components/primary_text_field.dart';
import 'package:flutter_lost_and_found/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailPassword(_emailController.text, _passwordController.text);
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(title: const Text("Login Gagal"), content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
        setState(() {
          _isLoading = false;
        });
      }
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 120,
                      backgroundColor: Colors.transparent,
                      child: Image(image: AssetImage('assets/images/logo-clear.png')),
                    ),
                    const SizedBox(height: 50),
                    PrimaryTextfield(
                      label: "Email",
                      hintText: "Email",
                      obscureText: false,
                      controller: _emailController,
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your email' : null,
                    ),
                    const SizedBox(height: 12),
                    PrimaryTextfield(
                      label: "Password",
                      hintText: "Password",
                      obscureText: true,
                      controller: _passwordController,
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your password' : null,
                    ),
                    const SizedBox(height: 30),
                    PrimaryButton(
                      text: _isLoading ? "LOGGING IN..." : "LOGIN",
                      onTap: _isLoading ? null : login,
                      color: Colors.blue.shade400,
                      textColor: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    PrimaryButton(
                      text: "Continue as Guest",
                      onTap: _isLoading ? null : () => _auth.signInAnonymously(),
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
                          onTap: widget.onTap,
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
          ),
        ],
      ),
    );
  }
}
