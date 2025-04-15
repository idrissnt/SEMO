import 'package:flutter/material.dart';
import '../../core/utils/logger.dart';

class EarnScreen extends StatefulWidget {
  const EarnScreen({Key? key}) : super(key: key);

  @override
  _EarnScreenState createState() => _EarnScreenState();
}

class _EarnScreenState extends State<EarnScreen> {
  final AppLogger _logger = AppLogger();

  @override
  void initState() {
    super.initState();
    _logger.debug('EarnScreen: Initializing');
  }

  @override
  Widget build(BuildContext context) {
    try {
      _logger.debug('Building EarnScreen');
      return Scaffold(
        appBar: AppBar(
          title: const Text('Earn Money'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Earn Money Screen (Coming Soon)'),
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
    _logger.debug('EarnScreen disposed');
    super.dispose();
  }
}
