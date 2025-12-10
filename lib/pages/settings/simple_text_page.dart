import 'package:flutter/material.dart';

class SimpleTextPage extends StatelessWidget {
  final String title;
  final String content;

  const SimpleTextPage({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Text(
          textAlign: TextAlign.justify,
          content,
          style: const TextStyle(fontSize: 14, height: 1, color: Colors.black87),
        ),
      ),
    );
  }
}
