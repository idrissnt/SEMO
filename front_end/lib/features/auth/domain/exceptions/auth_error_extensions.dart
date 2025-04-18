import 'package:semo/core/domain/exceptions/api_exceptions.dart';
import 'package:semo/features/auth/domain/exceptions/auth_error_codes.dart';
import 'package:semo/features/auth/domain/exceptions/auth_exceptions.dart';

// adding new functionality to the DomainException class without modifying the original class
/// Extension methods for domain exceptions to determine their type
extension DomainExceptionTypeExtension on DomainException {
  /// defines a getter method isServerError that checks if the exception's
  /// code matches ErrorCodes.serverError. Returns true if it matches
  bool get isServerError => code == ErrorCodes.serverError;

  /// Returns true if this exception represents a network error
  bool get isNetworkError =>
      code == ErrorCodes.networkError || code == ErrorCodes.timeout;

  /// Returns true if this exception represents an authentication error
  bool get isAuthError =>
      this is AuthenticationException ||
      code == AuthErrorCodes.invalidCredentials ||
      code == AuthErrorCodes.missingToken;
}

/// Extension methods for creating user-friendly error messages
extension DomainExceptionMessageExtension on DomainException {
  /// Returns a user-friendly error message for network errors
  /// context: "login" or "registration" or "logout"
  String getNetworkErrorMessage(String context) =>
      'Network error during $context: $message';

  /// Returns a user-friendly error message for server errors
  String getServerErrorMessage(String context) =>
      'Server error during $context: $message';
}
