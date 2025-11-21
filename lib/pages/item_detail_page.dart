import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const ItemDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final String itemName = item['item_name'] ?? 'No Name';
    final String description =
        item['description'] ?? 'No description available.';
    final String? imageUrl = item['image_url'];
    final String location = item['location'] ?? 'Location not specified';
    final String createdAt = item['created_at'] ?? '';

    String formattedDate = 'Date not available';
    if (createdAt.isNotEmpty) {
      final parsedDate = DateTime.parse(createdAt);
      formattedDate = DateFormat.yMMMMd().add_jm().format(parsedDate);
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: (imageUrl != null && imageUrl.isNotEmpty)
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.3),
                      colorBlendMode: BlendMode.darken,
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.secondary,
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 60),
                      ),
                    ),
            ),
          ),

          // --- CONTENT SECTION ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const Divider(height: 40),

                  _buildDetailRow(
                    context,
                    Icons.location_on_outlined,
                    'Location',
                    location,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    Icons.calendar_today_outlined,
                    'Date Reported',
                    formattedDate,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),

      // --- BOTTOM ACTION BUTTON ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // TODO: Implement "Claim Item" functionality
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            foregroundColor: Theme.of(context).colorScheme.surface,
          ),
          child: const Text('Claim Item', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String title,
    String content,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
