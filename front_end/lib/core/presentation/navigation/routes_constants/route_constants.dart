/// Constants for route paths used throughout the app
///
/// Using this class instead of string literals ensures consistency and makes
/// refactoring easier, as all route paths are defined in one place.
class AppRoutes {
  // Auth routes
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';

  // Main app routes
  static const String home = '/homeScreen';
  static const String mission = '/mission';
  static const String earn = '/earn';
  static const String message = '/message';
  static const String semoAi = '/semo-ai';

  // Utility routes
  static const String main = '/main';
}
