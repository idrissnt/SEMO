import 'package:flutter/material.dart';
import '../../core/utils/logger.dart';

class DeliverScreen extends StatefulWidget {
  const DeliverScreen({Key? key}) : super(key: key);

  @override
  _DeliverScreenState createState() => _DeliverScreenState();
}

class _DeliverScreenState extends State<DeliverScreen> {
  final AppLogger _logger = AppLogger();

  @override
  void initState() {
    super.initState();
    _logger
        .debug('DeliverScreen: Initializing', {'component': 'DeliverScreen'});
  }

  @override
  Widget build(BuildContext context) {
    try {
      _logger.debug('Building EarnScreen', {'component': 'EarnScreen'});
      return Scaffold(
        appBar: AppBar(
          title: const Text('Rendez service, touchez une prime'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                  'Livrez pour vos voisins, gagnez au passage ! (Coming Soon)'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _logger.info('User tapped on earn money placeholder');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Earn features coming soon!')),
                  );
                },
                child: const Text('Learn More'),
              ),
            ],
          ),
        ),
      );
    } catch (e, stackTrace) {
      _logger.error('Error building EarnScreen',
          error: e, stackTrace: stackTrace);
      return Scaffold(
        body: Center(
          child: Text('Error: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logger.debug('EarnScreen disposed', {'component': 'EarnScreen'});
    super.dispose();
  }
}
