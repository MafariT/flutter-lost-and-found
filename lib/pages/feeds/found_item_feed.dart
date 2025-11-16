import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/components/item_card.dart';
import 'package:flutter_lost_and_found/main.dart';

class FoundItemFeed extends StatefulWidget {
  const FoundItemFeed({super.key});

  @override
  State<FoundItemFeed> createState() => _FoundItemFeedState();
}

class _FoundItemFeedState extends State<FoundItemFeed> {
  late Future<List<Map<String, dynamic>>> _loundItemsFuture;

  @override
  void initState() {
    super.initState();
    _loundItemsFuture = _fetchFoundItems();
  }

  Future<List<Map<String, dynamic>>> _fetchFoundItems() async {
    try {
      final data = await supabase
          .from('items')
          .select()
          .eq('status', 'found')
          .order('created_at', ascending: false);
      return data;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch items: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return [];
    }
  }

  Future<void> _refreshFeed() async {
    setState(() {
      _loundItemsFuture = _fetchFoundItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loundItemsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final items = snapshot.data;
        if (items == null || items.isEmpty) {
          return const Center(child: Text('No found items found.'));
        }

        return RefreshIndicator(
          onRefresh: _refreshFeed,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ItemCard(
                itemName: item['item_name'] ?? 'No Name',
                description: item['description'] ?? 'No Description',
                imageUrl: item['image_url'],
              );
            },
          ),
        );
      },
    );
  }
}
