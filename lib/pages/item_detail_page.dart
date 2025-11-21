import 'package:flutter/material.dart';
import 'package:flutter_lost_and_found/main.dart';
import 'package:intl/intl.dart';

class ItemDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;
  const ItemDetailPage({super.key, required this.item});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  // 'loading', 'hide', 'can_claim', 'claim_pending', 'can_contact', 'contacted'
  String _buttonState = 'loading';
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadButtonState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadButtonState() async {
    setState(() {
      _buttonState = 'loading';
    });
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null || currentUser.id == widget.item['user_id']) {
        setState(() {
          _buttonState = 'hide';
        });
        return;
      }

      final itemStatus = widget.item['status'];

      if (itemStatus == 'found') {
        final claims = await supabase
            .from('claims')
            .select('id')
            .eq('item_id', widget.item['id'])
            .eq('claimer_id', currentUser.id)
            .limit(1);
        _buttonState = claims.isNotEmpty ? 'claim_pending' : 'can_claim';
      } else if (itemStatus == 'lost') {
        final contacts = await supabase
            .from('contacts')
            .select('id')
            .eq('item_id', widget.item['id'])
            .eq('sender_id', currentUser.id)
            .limit(1);
        _buttonState = contacts.isNotEmpty ? 'contacted' : 'can_contact';
      }
    } catch (e) {
      _showError('Error loading page state: $e');
      _buttonState = 'hide';
    } finally {
      if (mounted) setState(() {});
    }
  }

  // --- CLAIM WORKFLOW (for FOUND items) ---
  Future<void> _submitClaim(String message) async {
    setState(() {
      _buttonState = 'loading';
    });
    try {
      await supabase.from('claims').insert({
        'item_id': widget.item['id'],
        'claimer_id': supabase.auth.currentUser!.id,
        'finder_id': widget.item['user_id'],
        'claimant_message': message,
        'status': 'pending',
      });
      _showSuccess('Claim submitted for review!');
      _loadButtonState();
    } catch (e) {
      _showError('Failed to submit claim: $e');
      _loadButtonState();
    }
  }

  void _showClaimDialog() {
    _messageController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Claim This Item'),
        content: TextFormField(
          controller: _messageController,
          decoration: const InputDecoration(
            labelText: 'Proof of Ownership',
            hintText: 'e.g., "My wallet has a red sticker inside."',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final message = _messageController.text.trim();
              if (message.isNotEmpty) {
                Navigator.pop(context);
                _submitClaim(message);
              }
            },
            child: const Text('Submit Claim'),
          ),
        ],
      ),
    );
  }

  // --- CONTACT WORKFLOW (for LOST items) ---
  Future<void> _submitContact(String message) async {
    setState(() {
      _buttonState = 'loading';
    });
    try {
      await supabase.from('contacts').insert({
        'item_id': widget.item['id'],
        'sender_id': supabase.auth.currentUser!.id,
        'receiver_id': widget.item['user_id'],
        'message': message,
      });
      _showSuccess('Owner has been notified!');
      _loadButtonState();
    } catch (e) {
      _showError('Failed to send message: $e');
      _loadButtonState();
    }
  }

  void _showContactDialog() {
    _messageController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('I Found This Item!'),
        content: TextFormField(
          controller: _messageController,
          decoration: const InputDecoration(
            labelText: 'Your Message',
            hintText: 'e.g., "I think I found your wallet, contact me at..."',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final message = _messageController.text.trim();
              if (message.isNotEmpty) {
                Navigator.pop(context);
                _submitContact(message);
              }
            },
            child: const Text('Send Message'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String itemName = widget.item['item_name'] ?? 'No Name';
    final String description =
        widget.item['description'] ?? 'No description available.';
    final String? imageUrl = widget.item['image_url'];
    final String location = widget.item['location'] ?? 'Location not specified';
    final String createdAt = widget.item['created_at'] ?? '';

    String formattedDate = 'Date not available';
    if (createdAt.isNotEmpty) {
      try {
        final parsedDate = DateTime.parse(createdAt);
        formattedDate = DateFormat.yMMMMd().add_jm().format(parsedDate);
      } catch (_) {
        formattedDate = 'Invalid Date';
      }
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildBottomButton(),
      ),
    );
  }

  Widget _buildBottomButton() {
    switch (_buttonState) {
      case 'loading':
        return const Center(child: CircularProgressIndicator());

      case 'can_claim':
        return _buildActionButton(
          text: 'Claim Item',
          onPressed: _showClaimDialog,
        );
      case 'claim_pending':
        return _buildDisabledButton(
          text: 'Claim Pending',
          icon: Icons.hourglass_top,
        );

      case 'can_contact':
        return _buildActionButton(
          text: 'I Found This!',
          onPressed: _showContactDialog,
        );
      case 'contacted':
        return _buildDisabledButton(
          text: 'Owner Notified',
          icon: Icons.check_circle,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
  }) {
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

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }
}
