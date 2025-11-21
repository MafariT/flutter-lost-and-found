import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/main.dart';

class PendingClaimsFeed extends StatefulWidget {
  const PendingClaimsFeed({super.key});

  @override
  State<PendingClaimsFeed> createState() => _PendingClaimsFeedState();
}

class _PendingClaimsFeedState extends State<PendingClaimsFeed> {
  late Future<List<Map<String, dynamic>>> _pendingClaimsFuture;

  @override
  void initState() {
    super.initState();
    _pendingClaimsFuture = _fetchPendingClaims();
  }

  Future<List<Map<String, dynamic>>> _fetchPendingClaims() async {
    return await supabase
        .from('claims')
        .select('*, items(*), profiles:claimer_id(*)')
        .eq('status', 'pending')
        .order('created_at', ascending: true);
  }

  Future<void> _refresh() async {
    setState(() {
      _pendingClaimsFuture = _fetchPendingClaims();
    });
  }

  Future<void> _approveClaim(String claimId, String itemId) async {
    await supabase.rpc(
      'approve_claim_and_update_item',
      params: {'claim_id_to_approve': claimId, 'item_id_to_update': itemId},
    );
    _refresh();
  }

  Future<void> _rejectClaim(String claimId) async {
    await supabase
        .from('claims')
        .update({'status': 'rejected'})
        .eq('id', claimId);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _pendingClaimsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No pending claims123.'));
        }

        final claims = snapshot.data!;
        if (claims.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: const Center(child: Text('No pending claims.')),
          );
        }
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            itemCount: claims.length,
            itemBuilder: (context, index) {
              final claim = claims[index];
              final item = claim['items'];
              final claimant = claim['profiles'];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text("Claim for: ${item['item_name']}"),
                  subtitle: Text("Claim by: ${claimant['name'] ?? claimant['email']}"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Claimant's Message:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            claim['claimant_message'] ?? 'No message provided.',
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => _rejectClaim(claim['id']),
                                child: const Text(
                                  'Reject',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () =>
                                    _approveClaim(claim['id'], item['id']),
                                child: const Text('Approve'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
