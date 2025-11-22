import 'dart:io';
import 'package:flutter_lost_and_found/components/primary_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/components/primary_button.dart';
import 'package:flutter_lost_and_found/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
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

  void _updateProfile() async {
    try {
      await ref
          .read(userControllerProvider.notifier)
          .updateProfile(
            name: _nameController.text,
            nim: _nimController.text,
            faculty: _facultyController.text,
            programStudy: _programStudyController.text,
            imageFile: _imageFile,
          );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green));
      }
      ref.invalidate(userProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProvider);
    final controllerState = ref.watch(userControllerProvider);
    final isLoading = controllerState is AsyncLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
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

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (avatarUrl != null ? NetworkImage(avatarUrl) : null) as ImageProvider?,
                      child: (avatarUrl == null && _imageFile == null) ? const Icon(Icons.person, size: 60) : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 22),
                          onPressed: isLoading ? null : _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              PrimaryTextfield(
                label: "Name",
                hintText: "Enter your name",
                obscureText: false,
                controller: _nameController,
              ),
              const SizedBox(height: 12),
              PrimaryTextfield(
                label: "NIM",
                hintText: "Enter your NIM",
                obscureText: false,
                controller: _nimController,
              ),
              const SizedBox(height: 12),
              PrimaryTextfield(
                label: "Faculty",
                hintText: "Enter your faculty",
                obscureText: false,
                controller: _facultyController,
              ),
              const SizedBox(height: 12),
              PrimaryTextfield(
                label: "Program Study",
                hintText: "Enter your Program Study",
                obscureText: false,
                controller: _programStudyController,
              ),
              const SizedBox(height: 30),
              PrimaryButton(
                text: isLoading ? "Updating..." : "Update Profile",
                color: Theme.of(context).colorScheme.inversePrimary,
                onTap: _updateProfile,
              ),
            ],
          );
        },
      ),
    );
  }
}
