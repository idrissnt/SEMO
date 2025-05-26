/// Constants and shared utilities for filter components
class FilterConstants {
  // Filter keys
  static const String kAllMarkets = 'all_markets';
  static const String kOneMarket = 'one_market';
  static const String kUrgent = 'urgent';
  static const String kScheduled = 'scheduled';
  static const String kDistance = 'distance';
  static const String kHighReward = 'high_reward';

  // Store data
  static const List<Map<String, String>> stores = [
    {
      'name': 'Carrefour',
      'logoUrl': 'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/for-cart/carrefoures-log-for-cart.jpeg',
    },
    {
      'name': 'Lidl',
      'logoUrl': 'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/logo/Lidl-logo-home.png',
    },
    {
      'name': 'E.Leclerc',
      'logoUrl': 'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/for-cart/E-Leclerc-logo-for-cart.png',
    },
  ];

  // Schedule options
  static const List<Map<String, dynamic>> scheduleOptions = [
    {
      'label': "Aujourd'hui",
      'icon': 'today',
    },
    {
      'label': 'Demain',
      'icon': 'calendar_today',
    },
    {
      'label': 'Cette semaine',
      'icon': 'date_range',
    },
  ];

  // Distance settings
  static const double minDistance = 0.5;
  static const double maxDistance = 5.0;
  static const int distanceDivisions = 9;
  static const double defaultDistance = 1.0;
}
