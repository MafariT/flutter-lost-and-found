import 'package:flutter_lost_and_found/components/primary_button.dart';
import 'package:flutter_lost_and_found/components/primary_text_field.dart';
import 'package:flutter_lost_and_found/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signUpWithEmailPassword(_emailController.text, _passwordController.text);
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Registration Failed"),
            content: Text(e.toString().replaceAll('Exception: ', '')),
          ),
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
                      validator: (value) => value == null || value.isEmpty ? 'Please enter an email' : null,
                    ),
                    const SizedBox(height: 12),
                    PrimaryTextfield(
                      label: "Password",
                      hintText: "Password",
                      obscureText: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter a password';
                        if (value.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    PrimaryTextfield(
                      label: "Confirm Password",
                      hintText: "Confirm Password",
                      obscureText: true,
                      controller: _confirmPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please confirm your password';
                        if (value != _passwordController.text) return "Passwords don't match";
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    PrimaryButton(
                      text: _isLoading ? "CREATING ACCOUNT..." : "REGISTER",
                      onTap: _isLoading ? null : register,
                      color: Colors.blue.shade400,
                      textColor: Colors.white,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sudah punya akun? ",
                          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.inversePrimary),
                        ),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Text(
                            "Masuk disini",
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
