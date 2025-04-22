/// Authentication-specific error code constants
/// These codes are specific to the auth feature and should not be in the core module
class AuthErrorCodes {
  // Authentication error codes
  static const String invalidCredentials = 'invalid_credentials';
  static const String userAlreadyExists = 'user_already_exists';
  static const String missingToken = 'missing_token';
  static const String invalidInput = 'invalid_input';

  // Generic error code
  static const String genericError = 'generic_auth_error';

  // Private constructor to prevent instantiation
  AuthErrorCodes._();
}
