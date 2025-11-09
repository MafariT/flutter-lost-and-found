import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/main.dart';
import 'package:flutter_lost_and_found/components/primary_text_field.dart';
import 'package:flutter_lost_and_found/components/primary_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _getProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userId = supabase.auth.currentUser!.id;
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      _nameController.text = (data['name'] as String?) ?? '';
      _nimController.text = (data['nim'] as String?) ?? '';
      _emailController.text = (data['email'] as String?) ?? '';
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching profile: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userId = supabase.auth.currentUser!.id;
      final name = _nameController.text.trim();
      final nim = _nimController.text.trim();
      await supabase
          .from('profiles')
          .update({'name': name, 'nim': nim})
          .eq('id', userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 30),
              children: [
                PrimaryTextfield(
                  label: "Email",
                  hintText: 'Email',
                  obscureText: false,
                  readOnly: true,
                  controller: _emailController,
                ),
                const SizedBox(height: 20),

                PrimaryTextfield(
                  label: "Name",
                  hintText: 'Name',
                  obscureText: false,
                  controller: _nameController,
                ),
                const SizedBox(height: 20),

                PrimaryTextfield(
                  label: "NIM",
                  hintText: 'NIM',
                  obscureText: false,
                  controller: _nimController,
                ),
                const SizedBox(height: 30),

                PrimaryButton(
                  text: 'Update Profile',
                  onTap: _isLoading ? null : _updateProfile,
                ),
              ],
            ),
    );
  }
}
