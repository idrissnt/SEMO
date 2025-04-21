// lib/core/infrastructure/exception/api_exception_mapper.dart
import 'package:semo/core/domain/exceptions/api_exception_mapper.dart';
import 'package:semo/core/domain/exceptions/api_exceptions.dart';
import 'package:semo/core/utils/logger.dart';

abstract class ApiExceptionMapperImpl<T extends DomainException>
    implements ApiExceptionMapper<T> {
  final AppLogger _logger;

  ApiExceptionMapperImpl({required AppLogger logger}) : _logger = logger;

  /// Maps API exceptions to domain-specific exceptions
  /// Override this in feature-specific mappers to add custom mapping
  @override
  Never mapApiExceptionToDomainException(dynamic e) {
    _logger.error('API Exception: ${e.message}, Code: ${e.code}');

    // Handle common API exceptions
    if (e is ApiNetworkException || e is ApiTimeoutException) {
      final String networkCode = e is ApiTimeoutException
          ? ErrorCodes.timeout
          : ErrorCodes.networkError;

      throw createFeatureException(
        e.message,
        code: networkCode,
        requestId: e.requestId,
      );
    } else if (e is ApiServerException) {
      throw createFeatureException(
        e.message,
        code: ErrorCodes.serverError,
        requestId: e.requestId,
      );
    }

    // For all other cases, throw a generic domain exception
    // We don't pass any code here to ensure the feature-specific default code is used
    throw createFeatureException(
      e.toString(),
      // Intentionally not passing a code so the feature-specific default is used
      requestId: e is ApiException ? e.requestId : null,
    );
  }

  /// Convert a generic error to a feature-specific domain exception
  /// This must be implemented by feature-specific mappers
  @override
  T createFeatureException(String message, {String? code, String? requestId});
}
