/// Base class for all domain-specific exceptions
abstract class DomainException implements Exception {
  final String message;
  DomainException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown when authentication operations fail
class AuthenticationException extends DomainException {
  AuthenticationException(String message) : super(message);
}

/// Exception thrown when user profile operations fail
class UserProfileException extends DomainException {
  UserProfileException(String message) : super(message);
}

/// Exception thrown when authorization operations fail
class AuthorizationException extends DomainException {
  AuthorizationException(String message) : super(message);
}

/// Exception thrown when token operations fail
class TokenException extends DomainException {
  TokenException(String message) : super(message);
}

/// Exception thrown when network operations fail
class NetworkException extends DomainException {
  NetworkException(String message) : super(message);
}
