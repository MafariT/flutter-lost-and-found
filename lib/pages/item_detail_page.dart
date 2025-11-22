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
          decoration: InputDecoration(labelText: 'Your Message', hintText: hint),
          maxLines: 3,
          autofocus: true,
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
    final claimsController = ref.read(claimsControllerProvider.notifier);

    ref.listen<AsyncValue<void>>(claimsControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${next.error}'), backgroundColor: Colors.red));
      }
      if (previous is AsyncLoading && next is AsyncData) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Action successful!'), backgroundColor: Colors.green));
        ref.invalidate(claimStatusProvider(item['id'] as String));
      }
    });

    final String itemName = item['item_name'] ?? 'No Name';
    final String description = item['description'] ?? 'No description available.';
    final String? imageUrl = item['image_url'];
    final String location = item['location'] ?? 'Location not specified';
    final String createdAt = item['created_at'] ?? '';

    String formattedDate = 'Date not available';
    if (createdAt.isNotEmpty) {
      initializeDateFormatting('id', null);
      final parsedDate = DateTime.parse(createdAt).toUtc().add(const Duration(hours: 7)); // UTC+7
      formattedDate = formattedDate = DateFormat('EEEE, dd MMMM yyyy - HH:mm WIB', 'id').format(parsedDate);
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: (imageUrl != null && imageUrl.isNotEmpty)
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : Container(
                      color: Theme.of(context).colorScheme.secondary,
                      child: const Center(child: Icon(Icons.image_not_supported, size: 60)),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(itemName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(description, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const Divider(height: 40),
                  _buildDetailRow(context, Icons.location_on_outlined, 'Location', location),
                  const SizedBox(height: 16),
                  _buildDetailRow(context, Icons.calendar_today_outlined, 'Date Reported', formattedDate),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isGuest
            ? const SizedBox.shrink()
            : buttonState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (status) {
                  switch (status) {
                    case 'can_claim':
                      return _buildActionButton(
                        context: context,
                        text: 'Claim Item',
                        onPressed: () => _showDialog(
                          context,
                          ref,
                          title: 'Claim This Item',
                          hint: 'e.g., "My wallet has a red sticker inside."',
                          onSubmit: (message) => claimsController.submitClaim(
                            itemId: item['id'],
                            finderId: item['user_id'],
                            message: message,
                          ),
                        ),
                      );
                    case 'claim_pending':
                      return _buildDisabledButton(text: 'Claim Pending', icon: Icons.hourglass_top);
                    case 'can_contact':
                      return _buildActionButton(
                        context: context,
                        text: 'I Found This!',
                        onPressed: () => _showDialog(
                          context,
                          ref,
                          title: 'I Found This Item!',
                          hint: 'e.g., "I think I found your wallet, contact me at..."',
                          onSubmit: (message) => claimsController.submitContact(
                            itemId: item['id'],
                            ownerId: item['user_id'],
                            message: message,
                          ),
                        ),
                      );
                    case 'contacted':
                      return _buildDisabledButton(text: 'Owner Notified', icon: Icons.check_circle);
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: 4),
              Text(content, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({required BuildContext context, required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        foregroundColor: Theme.of(context).colorScheme.surface,
      ),
      child: Text(text, style: const TextStyle(fontSize: 18)),
    );
  }

  Widget _buildDisabledButton({required String text, required IconData icon}) {
    return ElevatedButton.icon(
      onPressed: null,
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        disabledBackgroundColor: Colors.grey.shade600,
      ),
    );
  }
}
