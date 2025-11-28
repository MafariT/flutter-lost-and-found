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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Belum ada claim barang', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(pendingClaimsProvider.future),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: claims.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final claim = claims[index];
              return _FlatClaimCard(claim: claim, ref: ref);
            },
          ),
        );
      },
    );
  }
}

class _FlatClaimCard extends StatelessWidget {
  final Map<String, dynamic> claim;
  final WidgetRef ref;

  const _FlatClaimCard({required this.claim, required this.ref});

  @override
  Widget build(BuildContext context) {
    final item = claim['items'];
    final claimant = claim['profiles'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 50,
              height: 50,
              child: item['image_url'] != null
                  ? Image.network(item['image_url'], fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey.shade100,
                      child: Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400),
                    ),
            ),
          ),
          title: Text(
            item['item_name'] ?? 'Unknown Item',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            "Diklaim oleh: ${claimant?['name'] ?? 'Unknown'}",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pesan dari pengklaim:",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    claim['claimant_message'] ?? 'Tidak ada pesan',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => ref.read(perantaraControllerProvider.notifier).rejectClaim(claim['id']),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(color: Theme.of(context).colorScheme.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Tolak'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        ref.read(perantaraControllerProvider.notifier).approveClaim(claim['id'], item['id']),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Terima'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
