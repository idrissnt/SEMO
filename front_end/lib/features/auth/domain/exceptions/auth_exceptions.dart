/// Base class for all domain-specific exceptions
abstract class DomainException implements Exception {
  final String message;
  final String? code;
  final String? requestId;
  
  DomainException(this.message, {this.code, this.requestId});

  @override
  String toString() => message;
}

/// Exception thrown when authentication operations fail
class AuthenticationException extends DomainException {
  AuthenticationException(String message, {String? code, String? requestId}) 
      : super(message, code: code, requestId: requestId);
}

/// Exception for invalid credentials (401 Unauthorized)
class InvalidCredentialsException extends AuthenticationException {
  InvalidCredentialsException({String message = 'The email or password you entered is incorrect', String? code, String? requestId}) 
      : super(message, code: code ?? 'invalid_credentials', requestId: requestId);
}

/// Exception for validation errors (400 Bad Request)
class ValidationException extends AuthenticationException {
  final Map<String, dynamic>? validationErrors;
  
  ValidationException({String message = 'Validation error', this.validationErrors, String? code, String? requestId}) 
      : super(message, code: code ?? 'validation_error', requestId: requestId);
}

/// Exception for server errors (500 Internal Server Error)
class ServerException extends DomainException {
  ServerException({String message = 'An unexpected error occurred', String? code, String? requestId}) 
      : super(message, code: code ?? 'server_error', requestId: requestId);
}

/// Exception thrown when user profile operations fail
class UserProfileException extends DomainException {
  UserProfileException(String message, {String? code, String? requestId}) 
      : super(message, code: code, requestId: requestId);
}

/// Exception thrown when authorization operations fail
class AuthorizationException extends DomainException {
  AuthorizationException({String message = 'You are not authorized to perform this action', String? code, String? requestId}) 
      : super(message, code: code ?? 'unauthorized', requestId: requestId);
}

/// Exception thrown when token operations fail
class TokenException extends DomainException {
  TokenException({String message = 'Token error', String? code, String? requestId}) 
      : super(message, code: code ?? 'token_error', requestId: requestId);
}

/// Exception thrown when network operations fail
class NetworkException extends DomainException {
  NetworkException({String message = 'Network error', String? code, String? requestId}) 
      : super(message, code: code ?? 'network_error', requestId: requestId);
}

/// Generic domain exception for cases that don't fit other categories
class GenericDomainException extends DomainException {
  GenericDomainException(String message, {String? code, String? requestId}) 
      : super(message, code: code ?? 'generic_error', requestId: requestId);
}
