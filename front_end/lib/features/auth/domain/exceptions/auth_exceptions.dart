import 'package:semo/core/domain/exceptions/api_exceptions.dart';
import 'package:semo/features/auth/domain/exceptions/auth_error_codes.dart';

/// Domain exceptions for authentication and authorization
class AuthenticationException extends DomainException {
  AuthenticationException(
    String message, {
    String? code,
    String? requestId,
  }) : super(message, code: code, requestId: requestId);
}

class InvalidInputException extends AuthenticationException {
  InvalidInputException(
      {String message = 'Invalid input provided',
      String? code,
      String? requestId})
      : super(message,
            code: code ?? AuthErrorCodes.invalidInput, requestId: requestId);
}

/// Exception for invalid credentials (401 Unauthorized)
class InvalidCredentialsException extends AuthenticationException {
  InvalidCredentialsException(
      {String message = 'The email or password you entered is incorrect',
      String? code,
      String? requestId})
      : super(message,
            code: code ?? AuthErrorCodes.invalidCredentials,
            requestId: requestId);
}

/// Exception for user already exists errors (409 Conflict)
class UserAlreadyExistsException extends AuthenticationException {
  UserAlreadyExistsException(
      {String message = 'User with this email already exists',
      String? code,
      String? requestId})
      : super(message,
            code: code ?? AuthErrorCodes.userAlreadyExists,
            requestId: requestId);
}

/// Exception for token errors (400 Bad Request)
class MissingRefreshTokenException extends AuthenticationException {
  MissingRefreshTokenException({
    String message = 'Refresh token is required',
    String? code,
    String? requestId,
  }) : super(message,
            code: code ?? AuthErrorCodes.missingToken, requestId: requestId);
}

/// Generic authentication exception for cases that don't fit other categories (500 Internal Server Error)
class GenericAuthException extends AuthenticationException {
  GenericAuthException(String message, {String? code, String? requestId})
      : super(message,
            code: code ?? AuthErrorCodes.genericError, requestId: requestId);
}
