import 'package:flutter_lost_and_found/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void updateQuery(String newQuery) => state = newQuery;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

final itemsFeedProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, status) async {
  final searchTerm = ref.watch(searchQueryProvider);

  var query = supabase.from('items').select().eq('status', status);

  if (searchTerm.isNotEmpty) {
    query = query.ilike('item_name', '%$searchTerm%');
  }

  final data = await query.order('created_at', ascending: false);
  return data;
});
