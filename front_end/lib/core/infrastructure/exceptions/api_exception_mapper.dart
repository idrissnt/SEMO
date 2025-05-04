// lib/core/infrastructure/exception/api_exception_mapper.dart
import 'package:semo/core/domain/exceptions/api_error_code.dart';
import 'package:semo/core/domain/exceptions/api_exception_mapper.dart';
import 'package:semo/core/domain/exceptions/api_exceptions.dart';
import 'package:semo/core/utils/logger.dart';

abstract class ApiExceptionMapperImpl<T extends DomainException>
    implements ApiExceptionMapper<T> {
  final AppLogger _logger;

  final logName = 'ApiExceptionMapperImpl';

  ApiExceptionMapperImpl({required AppLogger logger}) : _logger = logger;

  /// Maps API exceptions to domain-specific exceptions
  /// Override this in feature-specific mappers to add custom mapping
  @override
  Never mapApiExceptionToDomainException(dynamic e) {
    // Extract message, code and requestId
    String errorMessage;
    String? errorCode;
    String? requestId;
    
    if (e is ApiException) {
      errorMessage = e.message;
      errorCode = e.code;
      requestId = e.requestId;
      _logger.error('[$logName] : API Exception: $errorMessage, Code: $errorCode',
          error: e);
    } else {
      // Handle non-API exceptions (like NoSuchMethodError)
      errorMessage = e.toString();
      _logger.error('[$logName] : Non-API Exception: $errorMessage', error: e);
    }

    // Handle common API exceptions
    if (e is ApiNetworkException || e is ApiTimeoutException) {
      final String networkCode = e is ApiTimeoutException
          ? ErrorCodes.timeout
          : ErrorCodes.networkError;
      
      throw createFeatureException(
        errorMessage,
        code: networkCode,
        requestId: requestId,
      );
    } else if (e is ApiServerException) {
      throw createFeatureException(
        errorMessage,
        code: ErrorCodes.serverError,
        requestId: requestId,
      );
    }

    // For all other cases, throw a generic domain exception
    // We don't pass any code here to ensure the feature-specific default code is used
    throw createFeatureException(
      errorMessage,
      // Intentionally not passing a code so the feature-specific default is used
      requestId: requestId,
    );
  }

  /// Convert a generic error to a feature-specific domain exception
  /// This must be implemented by feature-specific mappers
  @override
  T createFeatureException(String message, {String? code, String? requestId});
}
