import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/providers/auth_provider.dart';
import 'package:flutter_lost_and_found/providers/claims_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class ItemDetailPage extends ConsumerWidget {
  final Map<String, dynamic> item;
  const ItemDetailPage({super.key, required this.item});

  void _showDialog(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String hint,
    required Function(String) onSubmit,
  }) {
    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextFormField(
          controller: messageController,
          decoration: InputDecoration(labelText: 'Pesan claim', hintText: hint),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final message = messageController.text.trim();
              if (message.isNotEmpty) {
                Navigator.pop(context);
                onSubmit(message);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(isGuestProvider);
    final buttonState = ref.watch(claimStatusProvider(item['id'] as String));

    ref.listen<AsyncValue<void>>(claimsControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${next.error}'), backgroundColor: Colors.red));
      }
      if (previous is AsyncLoading && next is AsyncData) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Submit berhasil!'), backgroundColor: Colors.green));
        ref.invalidate(claimStatusProvider(item['id'] as String));
      }
    });

    final String itemName = item['item_name'] ?? 'No Name';
    final String description = item['description'] ?? 'Tidak terdeskripsi';
    final String? imageUrl = item['image_url'];
    final String location = item['location'] ?? 'Lokasi tidak spesifik';
    final String createdAt = item['created_at'] ?? '';

    String formattedDate = 'Waktu tidak diketahui';
    if (createdAt.isNotEmpty) {
      try {
        initializeDateFormatting('id', null);
        final parsedDate = DateTime.parse(createdAt).toUtc().add(const Duration(hours: 7)); // UTC+7
        formattedDate = formattedDate = DateFormat('EEEE, dd MMMM yyyy - HH:mm WIB', 'id').format(parsedDate);
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350.0,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  (imageUrl != null && imageUrl.isNotEmpty)
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey.shade100,
                          child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey.shade300),
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black38],
                        stops: const [0.8, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Text(
                      itemName,
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetaChip(context, Icons.calendar_today, formattedDate),
                  const SizedBox(height: 10),
                  _buildMetaChip(context, Icons.location_on, location),

                  const SizedBox(height: 20),

                  const Text(
                    'Deskripsi barang',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Text(description, style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF555555))),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20.0),
        child: SafeArea(
          child: isGuest
              ? ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade300),
                  child: const Text("Login / Daftar", style: TextStyle(color: Colors.grey)),
                )
              : buttonState.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error: $err'),
                  data: (status) {
                    final claimsController = ref.read(claimsControllerProvider.notifier);
                    switch (status) {
                      case 'can_claim':
                        return _buildActionButton(
                          context,
                          text: 'Claim Barang',
                          color: Theme.of(context).colorScheme.primary,
                          onPressed: () => _showDialog(
                            context,
                            ref,
                            title: 'Claim Barang ini',
                            hint: 'Misalnya: "Izin Claim pak saya kehilangan dompet merah di FST gedung B"',
                            onSubmit: (message) => claimsController.submitClaim(
                              itemId: item['id'],
                              finderId: item['user_id'],
                              message: message,
                            ),
                          ),
                        );
                      case 'can_contact':
                        return _buildActionButton(
                          context,
                          text: 'Laporkan Temuan!',
                          color: Theme.of(context).colorScheme.primary,
                          onPressed: () => _showDialog(
                            context,
                            ref,
                            title: 'Saya temukan barang ini!',
                            hint: 'Misalnya: "Aku dapat ini di depan parkiran, PC Wa aku  08234....."',
                            onSubmit: (message) => claimsController.submitContact(
                              itemId: item['id'],
                              ownerId: item['user_id'],
                              message: message,
                            ),
                          ),
                        );
                      case 'claim_pending':
                        return _buildDisabledButton('Claim Pending', Icons.hourglass_top);
                      case 'rejected':
                        return _buildDisabledButton('Claim anda ditolak', Icons.cancel_outlined);
                      case 'contacted':
                        return _buildDisabledButton('Pemilik telah diberitahu', Icons.check_circle);
                      default:
                        return const SizedBox.shrink();
                    }
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildMetaChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDisabledButton(String text, IconData icon) {
    return SizedBox(
      height: 55,
      child: ElevatedButton.icon(
        onPressed: null,
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade400,
          disabledBackgroundColor: Colors.grey.shade400,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
