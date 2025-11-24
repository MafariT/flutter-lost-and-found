import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/components/primary_button.dart';
import 'package:flutter_lost_and_found/components/primary_text_field.dart';
import 'package:flutter_lost_and_found/main.dart';
import 'package:image_picker/image_picker.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isLoading = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String _status = 'lost';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.${_imageFile!.path.split('.').last}';
    final filePath = 'public/$fileName';

    try {
      await supabase.storage.from('item_images').upload(filePath, _imageFile!);
      final response = supabase.storage.from('item_images').getPublicUrl(filePath);
      return response;
    } catch (e) {
      _showError('Gagal mengupload gambar: $e');
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_imageFile == null) {
      _showError('Mohon sertakan foto barang');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String submissionStatus = _status == 'lost' ? 'lost' : 'unverified_found';
      final imageUrl = await _uploadImage();

      final data = {
        'item_name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'status': submissionStatus,
        'image_url': imageUrl,
        'user_id': supabase.auth.currentUser!.id,
      };

      await supabase.from('items').insert(data);

      _showSuccess('Barang berhasil dilaporkan!');
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError('Laporan gagal!: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error));
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Lapor Barang', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _TypeSelector(
                            label: "Kehilangan",
                            isSelected: _status == 'lost',
                            color: Theme.of(context).colorScheme.error,
                            onTap: () => setState(() => _status = 'lost'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _TypeSelector(
                            label: "Menemukan",
                            isSelected: _status == 'found',
                            color: Theme.of(context).colorScheme.primary,
                            onTap: () => setState(() => _status = 'found'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    GestureDetector(
                      onTap: _pickImage,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _imageFile != null ? Colors.white : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _imageFile != null
                                ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          image: _imageFile != null
                              ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _imageFile == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_rounded, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Tambah Foto Barang',
                                    style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                                  ),
                                  Text('(Wajib)', style: TextStyle(color: Colors.red.shade300, fontSize: 12)),
                                ],
                              )
                            : Stack(
                                children: [
                                  Positioned(
                                    right: 10,
                                    top: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.secondary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.edit, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              PrimaryTextfield(
                label: 'Nama Barang',
                hintText: 'Contoh: Dompet Hitam Kulit',
                obscureText: false,
                controller: _nameController,
                validator: (value) => value == null || value.isEmpty ? 'Nama barang wajib diisi' : null,
              ),
              PrimaryTextfield(
                label: 'Deskripsi',
                hintText: 'Ciri-ciri, isi, atau detail lainnya...',
                obscureText: false,
                controller: _descriptionController,
                validator: (value) => value == null || value.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
              PrimaryTextfield(
                label: 'Lokasi',
                hintText: 'Lokasi terakhir diketahui',
                obscureText: false,
                controller: _locationController,
                validator: (value) => value == null || value.isEmpty ? 'Lokasi wajib diisi' : null,
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: PrimaryButton(
                  text: _isLoading ? "Mengirim Laporan..." : "Kirim Laporan",
                  color: _status == 'lost'
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                  onTap: _isLoading ? null : _submitForm,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeSelector({required this.label, required this.isSelected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color : Colors.grey.shade200, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
