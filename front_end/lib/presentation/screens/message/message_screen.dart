import 'package:flutter/material.dart';
import '../../../core/utils/logger.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final AppLogger _logger = AppLogger();
  final List<Map<String, dynamic>> _messages = [
    {'user': 'User 1', 'message': 'Latest message from user 1', 'time': '12:10 PM', 'unread': 1},
    {'user': 'User 2', 'message': 'Latest message from user 2', 'time': '12:20 PM', 'unread': 0},
    {'user': 'User 3', 'message': 'Latest message from user 3', 'time': '12:30 PM', 'unread': 2},
    {'user': 'User 4', 'message': 'Latest message from user 4', 'time': '12:40 PM', 'unread': 0},
    {'user': 'User 5', 'message': 'Latest message from user 5', 'time': '12:50 PM', 'unread': 3},
  ];

  @override
  void initState() {
    super.initState();
    _logger.debug('MessageScreen: Initializing');
    _logger.info('Total messages: ${_messages.length}');
  }

  void _onMessageTap(Map<String, dynamic> message) {
    _logger.info('Tapped on message from: ${message['user']}');
    // TODO: Navigate to chat detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening chat with ${message['user']}'))
    );
  }

  @override
  Widget build(BuildContext context) {
    try {
      _logger.debug('Building MessageScreen');
      return Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _logger.info('User initiated message search');
                // TODO: Implement search functionality
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _logger.info('Refreshing messages');
            // TODO: Implement actual message refresh logic
            await Future.delayed(const Duration(seconds: 1));
          },
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.primaries[index % Colors.primaries.length],
                  child: Text(message['user'][0]),
                ),
                title: Text(message['user']),
                subtitle: Text(message['message']),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message['time']),
                    if (message['unread'] > 0)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${message['unread']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                onTap: () => _onMessageTap(message),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _logger.info('User wants to start a new message');
            // TODO: Implement new message functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('New message feature coming soon!'))
            );
          },
          child: const Icon(Icons.add),
        ),
      );
    } catch (e, stackTrace) {
      _logger.error('Error building MessageScreen', error: e, stackTrace: stackTrace);
      return Scaffold(
        body: Center(
          child: Text('Error: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logger.debug('MessageScreen disposed');
    super.dispose();
  }
}
