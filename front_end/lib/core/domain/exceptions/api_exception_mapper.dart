import 'package:semo/core/domain/exceptions/api_exceptions.dart';

/// Defines the contract for mapping exceptions between layers
abstract class ApiExceptionMapper<T extends DomainException> {
  /// Maps infrastructure exceptions to domain-specific exceptions
  /// This method should never return - it always throws an exception
  Never mapApiExceptionToDomainException(dynamic exception);

  /// Convert a generic error to a feature-specific domain exception
  T createFeatureException(String message, {String? code, String? requestId});
}
