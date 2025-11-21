import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/providers/perantara_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingClaimsFeed extends ConsumerWidget {
  const PendingClaimsFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingClaims = ref.watch(pendingClaimsProvider);

    return pendingClaims.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (claims) {
        if (claims.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => ref.refresh(pendingClaimsProvider.future),
            child: const Center(child: Text('No pending claims.')),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(pendingClaimsProvider.future),
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
                  subtitle: Text("Claim by: ${claimant['email'] ?? 'N/A'}"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Claimant's Message:", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(claim['claimant_message'] ?? 'No message provided.'),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () =>
                                    ref.read(perantaraControllerProvider.notifier).rejectClaim(claim['id']),
                                child: const Text('Reject', style: TextStyle(color: Colors.red)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => ref
                                    .read(perantaraControllerProvider.notifier)
                                    .approveClaim(claim['id'], item['id']),
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
