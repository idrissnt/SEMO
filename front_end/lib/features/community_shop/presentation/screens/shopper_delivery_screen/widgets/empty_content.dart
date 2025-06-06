import 'package:flutter/material.dart';
import 'package:semo/core/utils/logger.dart';

final AppLogger _logger = AppLogger();

Widget emptyContent(String tabName) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            textAlign: TextAlign.center,
            'Aucune commande $tabName',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            textAlign: TextAlign.center,
            'Pour recevoir plus de commandes, vous pouvez :',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          // Button to edit available days and hours
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to availability settings
              _logger.info('Navigate to availability settings');
            },
            icon: const Icon(Icons.calendar_today),
            label: const Text('Modifier mes disponibilités'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              fixedSize: const Size(double.maxFinite, 45),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          // Button to edit regular routes
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to routes settings
              _logger.info('Navigate to routes settings');
            },
            icon: const Icon(Icons.route),
            label: const Text('Modifier mes trajets réguliers'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              fixedSize: const Size(double.maxFinite, 45),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ),
  );
}
