import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/components/primary_button.dart';
import 'package:flutter_lost_and_found/components/primary_text_field.dart';
import 'package:flutter_lost_and_found/main.dart';
import 'package:flutter_lost_and_found/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _facultyController = TextEditingController();
  final _programStudyController = TextEditingController();

  File? _imageFile;
  bool _controllersInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _facultyController.dispose();
    _programStudyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _updateProfile(bool isStudent) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await ref
          .read(userProfileControllerProvider.notifier)
          .updateProfile(
            name: _nameController.text,
            nim: isStudent ? _nimController.text : '',
            faculty: isStudent ? _facultyController.text : '',
            programStudy: isStudent ? _programStudyController.text : '',
            imageFile: _imageFile,
          );
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);
    final controllerState = ref.watch(userProfileControllerProvider);
    final isLoading = controllerState is AsyncLoading;

    final userRole = supabase.auth.currentUser?.appMetadata['role'] ?? 'user';
    final isStudent = userRole == 'user';

    ref.listen<AsyncValue<void>>(userProfileControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.error}'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
      if (previous is AsyncLoading && next is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Pembaruan Profil Berhasil!'), backgroundColor: Colors.green.shade600),
        );
        ref.invalidate(userProfileProvider);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: userProfile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (profile) {
          if (!_controllersInitialized) {
            _nameController.text = profile?['name'] ?? '';
            _nimController.text = profile?['nim'] ?? '';
            _facultyController.text = profile?['faculty'] ?? '';
            _programStudyController.text = profile?['program_study'] ?? '';
            _controllersInitialized = true;
          }
          final avatarUrl = profile?['avatar_url'];

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              physics: const BouncingScrollPhysics(),
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade200, width: 4),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade100,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : (avatarUrl != null ? NetworkImage(avatarUrl) : null) as ImageProvider?,
                          child: (avatarUrl == null && _imageFile == null)
                              ? Icon(Icons.person, size: 60, color: Colors.grey.shade400)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: GestureDetector(
                          onTap: isLoading ? null : _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                PrimaryTextfield(
                  label: "Nama",
                  hintText: "Masukkan nama anda",
                  obscureText: false,
                  controller: _nameController,
                  validator: (value) => value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),

                if (isStudent) ...[
                  PrimaryTextfield(
                    label: "NIM",
                    hintText: "Masukan NIM anda",
                    obscureText: false,
                    controller: _nimController,
                    validator: (value) => value == null || value.isEmpty ? 'NIM tidak boleh kosong' : null,
                  ),
                  PrimaryTextfield(
                    label: "Fakultas",
                    hintText: "Masukkan fakultas anda",
                    obscureText: false,
                    controller: _facultyController,
                  ),
                  PrimaryTextfield(
                    label: "Program Studi",
                    hintText: "Masukkan program studi anda",
                    obscureText: false,
                    controller: _programStudyController,
                  ),
                ],

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: PrimaryButton(
                    text: isLoading ? "Memperbarui..." : "Perbarui Profil",
                    color: Theme.of(context).colorScheme.primary,
                    onTap: isLoading ? null : () => _updateProfile(isStudent),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
