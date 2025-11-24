import 'package:flutter/material.dart';

class PrimaryTextfield extends StatelessWidget {
  const PrimaryTextfield({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.focusNode,
    this.validator,
  });
  final String hintText;
  final bool obscureText;
  final String label;
  final bool readOnly;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        focusNode: focusNode,
        validator: validator,
        style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          fillColor: Colors.grey.shade100,
          filled: true,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }
}
