import 'package:flutter/material.dart';
import '../../../core/utils/logger.dart';

class SemoAIScreen extends StatefulWidget {
  const SemoAIScreen({Key? key}) : super(key: key);

  @override
  _SemoAIScreenState createState() => _SemoAIScreenState();
}

class _SemoAIScreenState extends State<SemoAIScreen> {
  final AppLogger _logger = AppLogger();
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    _logger.debug('SemoAIScreen initialized');
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      _logger.warning('Attempted to send empty message');
      return;
    }

    _logger.info('Sending message: $message');

    setState(() {
      _messages.add({
        'sender': 'user',
        'message': message,
      });
      _messageController.clear();
    });

    // TODO: Implement actual AI message sending logic
    _simulateAIResponse(message);
  }

  void _simulateAIResponse(String userMessage) {
    _logger.debug('Simulating AI response for: $userMessage');

    setState(() {
      _messages.add({
        'sender': 'ai',
        'message': 'I received: $userMessage. Working on a response...',
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _logger.debug('SemoAIScreen disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      _logger.debug('Building SemoAIScreen');

      return Scaffold(
        appBar: AppBar(
          title: const Text('SEMO AI'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    itemCount: _messages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      child: Icon(Icons.smart_toy,
                                          color: Colors.white),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'SEMO AI',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Hello! I\'m SEMO AI, your personal assistant. How can I help you today?',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final message = _messages[index - 1];
                      return Card(
                        color: message['sender'] == 'user'
                            ? Colors.blue[50]
                            : Colors.green[50],
                        child: ListTile(
                          title: Text(message['message'] ?? ''),
                          subtitle: Text(
                              message['sender'] == 'user' ? 'You' : 'SEMO AI'),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Ask me anything...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send,
                          color: Theme.of(context).primaryColor),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e, stackTrace) {
      _logger.error('Error building SemoAIScreen',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
