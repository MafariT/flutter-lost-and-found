import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/components/item_card.dart';
import 'package:flutter_lost_and_found/main.dart';

class ItemsFeed extends StatefulWidget {
  final String status;
  const ItemsFeed({super.key, required this.status});

  @override
  State<ItemsFeed> createState() => _ItemsFeedState();
}

class _ItemsFeedState extends State<ItemsFeed> {
  late Future<List<Map<String, dynamic>>> _itemsFuture;
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _fetchItems();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _refreshFeed();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchItems() async {
    try {
      final searchTerm = _searchController.text.trim();
      var query = supabase.from('items').select().eq('status', widget.status);

      if (searchTerm.isNotEmpty) {
        query = query.ilike('item_name', '%$searchTerm%');
      }

      final data = await query.order('created_at', ascending: false);
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
      _itemsFuture = _fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- SEARCH BAR ---
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for an item...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),

        // --- ITEMS LIST ---
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _itemsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snapshot.data;
              if (items == null || items.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _refreshFeed,
                  child: const Center(child: Text('No items found.')),
                );
              }
              return RefreshIndicator(
                onRefresh: _refreshFeed,
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ItemCard(item: item);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
