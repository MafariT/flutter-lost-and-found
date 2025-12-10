import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/components/primary_button.dart';
import 'package:flutter_lost_and_found/components/primary_text_field.dart';
import 'package:flutter_lost_and_found/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = supabase.auth.currentUser?.email;
      if (email == null) throw const AuthException("User email not found");

      await supabase.auth.signInWithPassword(email: email, password: _currentPasswordController.text.trim());

      await supabase.auth.updateUser(UserAttributes(password: _newPasswordController.text.trim()));

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Kata sandi berhasil diubah!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) {
        String message = e.message;
        if (message.contains("Invalid login credentials")) {
          message = "Kata sandi saat ini salah";
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Ubah Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "Demi keamanan, mohon masukkan kata sandi lama anda sebelum membuat yang baru",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),

              PrimaryTextfield(
                label: "Kata Sandi Saat Ini",
                hintText: "Masukkan kata sandi lama",
                obscureText: true,
                controller: _currentPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Wajib diisi';
                  return null;
                },
              ),

              PrimaryTextfield(
                label: "Kata Sandi Baru",
                hintText: "Minimal 6 karakter",
                obscureText: true,
                controller: _newPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Wajib diisi';
                  if (value.length < 6) return 'Minimal 6 karakter';
                  if (value == _currentPasswordController.text) {
                    return 'Kata sandi baru tidak boleh sama dengan yang lama';
                  }
                  return null;
                },
              ),
              PrimaryTextfield(
                label: "Konfirmasi Kata Sandi Baru",
                hintText: "Ulangi kata sandi baru",
                obscureText: true,
                controller: _confirmPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Wajib diisi';
                  if (value != _newPasswordController.text) return 'Kata sandi tidak cocok';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: PrimaryButton(
                  text: _isLoading ? "Memproses..." : "Simpan Kata Sandi",
                  color: Theme.of(context).colorScheme.primary,
                  onTap: _isLoading ? null : _updatePassword,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
