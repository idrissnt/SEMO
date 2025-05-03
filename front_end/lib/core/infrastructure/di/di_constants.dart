/// Constants used for dependency injection
///
/// This class contains constants used for named dependencies in the DI container.
/// Using constants instead of hardcoded strings helps prevent typos and makes
/// refactoring easier.
class DIConstants {
  /// Name for the Dio instance used specifically for token service operations
  static const String tokenServiceDio = 'tokenServiceDio';
}
