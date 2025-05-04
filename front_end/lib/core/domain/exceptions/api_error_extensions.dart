import 'package:semo/core/domain/exceptions/api_error_code.dart';
import 'package:semo/core/domain/exceptions/api_exceptions.dart';

// adding new functionality to the DomainException class without modifying the original class
/// Extension methods for domain exceptions to determine their type
extension DomainExceptionTypeExtension on DomainException {
  /// defines a getter method isServerError that checks if the exception's
  /// code matches ErrorCodes.serverError. Returns true if it matches
  bool get isServerError => code == ErrorCodes.serverError;

  /// Returns true if this exception represents a network error
  bool get isNetworkError =>
      code == ErrorCodes.networkError || code == ErrorCodes.timeout;

  bool get isUserNotFoundException => code == ErrorCodes.userNotFound;
}
