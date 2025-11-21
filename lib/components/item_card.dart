import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/pages/item_detail_page.dart';

class ItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final String itemName = item['item_name'] ?? 'No Name';
    final String description = item['description'] ?? 'No Description';
    final String? imageUrl = item['image_url'];
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ItemDetailPage(item: item)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- IMAGE ---
            (imageUrl != null && imageUrl.isNotEmpty)
                ? Image.network(
                    imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 200,
                        child: Icon(Icons.broken_image, size: 48),
                      );
                    },
                  )
                : Container(
                    height: 200,
                    color: Theme.of(context).colorScheme.secondary,
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 48),
                    ),
                  ),

            // --- TEXT CONTENT ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
