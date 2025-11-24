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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _auth.signUpWithEmailPassword(_emailController.text, _passwordController.text);
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Pendaftaran Gagal"),
            content: Text(e.toString().replaceAll('Exception: ', '')),
          ),
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
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/splash-background.png'),
                fit: BoxFit.cover,
                opacity: 0.4,
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
                      hintText: "Masukkan Email anda",
                      obscureText: false,
                      controller: _emailController,
                      validator: (value) => value == null || value.isEmpty ? 'Masukkan Email' : null,
                    ),
                    PrimaryTextfield(
                      label: "Kata Sandi",
                      hintText: "Buat kata sandi",
                      obscureText: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Masukkan kata sandi';
                        if (value.length < 6) return 'Minimal 6 karakter';
                        return null;
                      },
                    ),
                    PrimaryTextfield(
                      label: "Konfirmasi Kata Sandi",
                      hintText: "Konfirmasi kata sandi anda",
                      obscureText: true,
                      controller: _confirmPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Konfirmasi kata sandi';
                        if (value != _passwordController.text) return "Kata sandi tidak cocok";
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    PrimaryButton(
                      text: _isLoading ? "Membuat Akun..." : "Daftar",
                      onTap: _isLoading ? null : register,
                      color: Theme.of(context).colorScheme.primary,
                      textColor: Colors.white,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Sudah punya akun? ", style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Text(
                            "Masuk disini",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
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
