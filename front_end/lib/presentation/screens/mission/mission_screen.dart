import 'package:flutter/material.dart';
import '../../../core/utils/logger.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({Key? key}) : super(key: key);

  @override
  _MissionScreenState createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  final AppLogger _logger = AppLogger();
  final List<Map<String, dynamic>> _missions = [
    {'id': 1, 'title': 'Complete Profile', 'description': 'Fill out your profile details', 'points': 50},
    {'id': 2, 'title': 'First Purchase', 'description': 'Make your first purchase', 'points': 100},
    {'id': 3, 'title': 'Refer a Friend', 'description': 'Invite a friend to the app', 'points': 75},
    {'id': 4, 'title': 'Write a Review', 'description': 'Write a review for a product', 'points': 25},
    {'id': 5, 'title': 'Share on Social Media', 'description': 'Share app on social platforms', 'points': 40},
  ];

  @override
  void initState() {
    super.initState();
    _logger.debug('MissionScreen: Initializing');
    _logger.info('Total missions available: ${_missions.length}');
  }

  void _startMission(Map<String, dynamic> mission) {
    _logger.info('User started mission: ${mission['title']}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mission "${mission['title']}" started. Earn ${mission['points']} points!'))
    );
    // TODO: Implement actual mission start logic
  }

  @override
  Widget build(BuildContext context) {
    try {
      _logger.debug('Building MissionScreen');
      return Scaffold(
        appBar: AppBar(
          title: const Text('Missions'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                _logger.info('User opened missions info');
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Missions Info'),
                    content: const Text('Complete missions to earn points and rewards!'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Available Missions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _missions.length,
                  itemBuilder: (context, index) {
                    final mission = _missions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          Icons.stars,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(mission['title']),
                        subtitle: Text(mission['description']),
                        trailing: ElevatedButton(
                          onPressed: () => _startMission(mission),
                          child: const Text('Start'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e, stackTrace) {
      _logger.error('Error building MissionScreen', error: e, stackTrace: stackTrace);
      return Scaffold(
        body: Center(
          child: Text('Error: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logger.debug('MissionScreen disposed');
    super.dispose();
  }
}
