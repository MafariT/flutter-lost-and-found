import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tentang Aplikasi', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: CircleAvatar(
                radius: 140,
                backgroundColor: Colors.transparent,
                child: Padding(padding: const EdgeInsets.all(16.0), child: Image.asset('assets/images/logo-clear.png')),
              ),
            ),
            const SizedBox(height: 24),

            const Text("Lost & Found", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Versi 1.0.0", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Aplikasi ini dibuat untuk membantu mahasiswa dalam melaporkan dan menemukan barang yang hilang di lingkungan kampus",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, height: 1.5),
              ),
            ),

            const Spacer(),
            Text("© 2025 Lost & Found Team", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
