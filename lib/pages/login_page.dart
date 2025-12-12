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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _auth.signInWithEmailPassword(_emailController.text, _passwordController.text);
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(title: const Text("Login Gagal"), content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Container(
          //   decoration: const BoxDecoration(
          //     image: DecorationImage(
          //       image: AssetImage('assets/images/splash-background.png'),
          //       fit: BoxFit.cover,
          //       opacity: 0.4,
          //     ),
          //   ),
          // ),
          Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 140,
                      backgroundColor: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.asset('assets/images/logo-clear.png'),
                      ),
                    ),

                    const SizedBox(height: 20),

                    PrimaryTextfield(
                      label: "Email",
                      hintText: "Masukkan email terdaftar",
                      obscureText: false,
                      controller: _emailController,
                      validator: (value) => value == null || value.isEmpty ? 'Masukkan Email' : null,
                    ),
                    PrimaryTextfield(
                      label: "Kata Sandi",
                      hintText: "Masukkan kata sandi anda",
                      obscureText: true,
                      controller: _passwordController,
                      validator: (value) => value == null || value.isEmpty ? 'Masukkan kata sandi' : null,
                    ),

                    const SizedBox(height: 20),

                    PrimaryButton(
                      text: _isLoading ? "Memuat Halaman..." : "Login",
                      onTap: _isLoading ? null : login,
                      color: Theme.of(context).colorScheme.primary,
                      textColor: Colors.white,
                    ),

                    const SizedBox(height: 16),

                    PrimaryButton(
                      text: "Login Sebagai Tamu",
                      onTap: _isLoading ? null : () => _auth.signInAnonymously(),
                      color: Colors.grey.shade200,
                      textColor: Colors.black87,
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Belum punya akun? ", style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Text(
                            "Daftar disini",
                            style: TextStyle(
                              fontSize: 14,
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
            ),
          ),
        ],
      ),
    );
  }
}
