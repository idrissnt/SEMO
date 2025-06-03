import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/utils/logger.dart';

final AppLogger _logger = AppLogger();

class MapServicesWidget extends StatelessWidget {
  final CommunityOrder order;

  // Map service logos
  final List<String> mapsLogoData = [
    'https://www.apple.com/v/maps/d/images/overview/intro_icon__dfyvjc1ohbcm_large.png', // Apple Maps
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSC10aIGcrdtvbwpYkeboJsf9YXZ0K6cwbOMw&s', // Google Maps
    'https://cdn-1.webcatalog.io/catalog/waze/waze-icon-filled-256.png?v=1745800727973' // Waze
  ];

  // Map service names
  final List<String> mapServiceNames = ['Apple Maps', 'Google Maps', 'Waze'];

  MapServicesWidget({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Commencez votre livraison avec',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                  3, (index) => _buildMapServiceButton(context, index)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapServiceButton(BuildContext context, int index) {
    return InkWell(
      onTap: () => _launchMapService(context, index),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.9),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                mapsLogoData[index],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.map, size: 40),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            mapServiceNames[index],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchMapService(BuildContext context, int index) async {
    // Add haptic feedback
    HapticFeedback.mediumImpact();

    final String origin = Uri.encodeComponent(order.storeAddress);
    final String destination = Uri.encodeComponent(order.deliveryAddress);

    String url = '';

    switch (index) {
      case 0: // Apple Maps
        url = 'https://maps.apple.com/?saddr=$origin&daddr=$destination';
        break;
      case 1: // Google Maps
        url =
            'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination';
        break;
      case 2: // Waze
        url = 'https://waze.com/ul?navigate=yes&from=$origin&to=$destination';
        break;
    }

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _logger.info('Could not launch ${mapServiceNames[index]}');
        // Show a snackbar or toast message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Impossible d\'ouvrir ${mapServiceNames[index]}')));
        }
      }
    } catch (e) {
      _logger.error('Error launching map: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Erreur lors de l\'ouverture de la carte')));
      }
    }
  }
}
