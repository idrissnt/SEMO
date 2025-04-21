/// Core error code constants for domain exceptions
/// Only contains error codes that are truly cross-cutting concerns
class ErrorCodes {
  // Network error codes
  static const String networkError = 'network_error';
  static const String timeout = 'timeout';

  // Server error codes
  static const String serverError = 'server_error';
}

/// Base class for all domain-specific exceptions
abstract class DomainException implements Exception {
  final String message;
  final String? code;
  final String? requestId;

  DomainException(this.message, {this.code, this.requestId});

  @override
  String toString() => message;
}

/// Base exception for API-related errors
class ApiException extends DomainException {
  final int? statusCode;
  final Map<String, dynamic>? details;

  ApiException(
    String message, {
    this.statusCode,
    this.details,
    String? code,
    String? requestId,
  }) : super(message, code: code, requestId: requestId);
}

/// Exception for unauthorized access (401)
class UnauthorizedException extends ApiException {
  UnauthorizedException({
    String message = 'Unauthorized access',
    Map<String, dynamic>? details,
    String? code,
    String? requestId,
  }) : super(
          message,
          statusCode: 401,
          details: details,
          code: code ?? 'unauthorized',
          requestId: requestId,
        );
}

/// Exception for bad requests (400)
class BadRequestException extends ApiException {
  final Map<String, dynamic>? validationErrors;

  BadRequestException({
    String message = 'Bad request',
    this.validationErrors,
    Map<String, dynamic>? details,
    String? code,
    String? requestId,
  }) : super(
          message,
          statusCode: 400,
          details: details,
          code: code ?? 'bad_request',
          requestId: requestId,
        );
}

/// Exception for conflicts (409)
class ConflictException extends ApiException {
  final Map<String, dynamic>? validationErrors;

  ConflictException({
    String message = 'Conflict',
    this.validationErrors,
    Map<String, dynamic>? details,
    String? code,
    String? requestId,
  }) : super(
          message,
          statusCode: 409,
          details: details,
          code: code ?? 'conflict',
          requestId: requestId,
        );
}

/// Exception for server errors (500)
class ApiServerException extends ApiException {
  ApiServerException({
    String message = 'Server error',
    Map<String, dynamic>? details,
    String? code,
    String? requestId,
  }) : super(
          message,
          statusCode: 500,
          details: details,
          code: code ?? ErrorCodes.serverError,
          requestId: requestId,
        );
}

/// Exception for not found resources (404)
class NotFoundException extends ApiException {
  NotFoundException({
    String message = 'Resource not found',
    Map<String, dynamic>? details,
    String? code,
    String? requestId,
  }) : super(
          message,
          statusCode: 404,
          details: details,
          code: code ?? 'not_found',
          requestId: requestId,
        );
}

/// Exception for network-related issues
class ApiNetworkException extends ApiException {
  ApiNetworkException({
    String message = 'Network error',
    Map<String, dynamic>? details,
    String? code,
    String? requestId,
  }) : super(
          message,
          details: details,
          code: code ?? ErrorCodes.networkError,
          requestId: requestId,
        );
}

/// Exception for timeout issues
class ApiTimeoutException extends ApiNetworkException {
  ApiTimeoutException({
    String message = 'Request timed out',
    Map<String, dynamic>? details,
    String? code,
    String? requestId,
  }) : super(
          message: message,
          details: details,
          code: code ?? ErrorCodes.timeout,
          requestId: requestId,
        );
}
