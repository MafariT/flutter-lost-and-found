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
  });
  final String hintText;
  final bool obscureText;
  final String label;
  final bool readOnly;
  final TextEditingController controller;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          label: Text(label),
          fillColor: Theme.of(context).colorScheme.tertiary,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        readOnly: readOnly,
      ),
    );
  }
}
