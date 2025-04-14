import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/logger.dart';

class StorePeopleScreen extends StatefulWidget {
  final String storeId;

  const StorePeopleScreen({Key? key, required this.storeId}) : super(key: key);

  @override
  State<StorePeopleScreen> createState() => _StorePeopleScreenState();
}

class _StorePeopleScreenState extends State<StorePeopleScreen>
    with AutomaticKeepAliveClientMixin {
  final AppLogger _logger = AppLogger();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Must call super.build

    _logger.debug('Building StorePeopleScreen for store: ${widget.storeId}');

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/store/${widget.storeId}'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text(
                  'Add people to shop with',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Invite friends and family to shop together',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),

                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search contacts',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 24),

                // Contacts list (placeholder)
                for (int i = 1; i <= 10; i++)
                  _buildContactTile(
                    'Contact $i',
                    'contact$i@example.com',
                    'https://ui-avatars.com/api/?name=Contact+$i&background=random',
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(String name, String email, String avatarUrl) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(avatarUrl),
      ),
      title: Text(name),
      subtitle: Text(email),
      trailing: OutlinedButton(
        onPressed: () {
          _logger.debug('Invite button pressed for contact: $name');
        },
        child: const Text('Invite'),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
    );
  }
}
