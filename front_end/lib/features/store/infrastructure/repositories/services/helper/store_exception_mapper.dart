// store_exception_mapper.dart
import 'package:semo/core/domain/exceptions/api_exceptions.dart';
import 'package:semo/core/infrastructure/exceptions/api_exception_mapper.dart';
import 'package:semo/features/store/domain/exceptions/store_error_codes.dart';
import 'package:semo/features/store/domain/exceptions/store_exception_mapper.dart';
import 'package:semo/features/store/domain/exceptions/store_exceptions.dart';

class StoreExceptionMapperImpl extends ApiExceptionMapperImpl<StoreException>
    implements StoreExceptionMapper {
  StoreExceptionMapperImpl({required super.logger});

  @override
  Never mapApiExceptionToDomainException(dynamic e) {
    // First check for domain exceptions that might have been thrown already
    if (e is StoreException) {
      // If it's already a domain exception, just rethrow it
      throw e;
    }

    // We override backend error codes with our frontend constants for consistency
    // The original code is still logged above for debugging purposes
    if (e is BadRequestException) {
      switch (e.code) {
        case StoreErrorCodes.invalidUuid:
          throw InvalidUuidException(
            message: e.message,
            code: StoreErrorCodes.invalidUuid,
            requestId: e.requestId,
          );
        case StoreErrorCodes.addressRequired:
          throw AddressRequiredException(
            message: e.message,
            code: StoreErrorCodes.addressRequired,
            requestId: e.requestId,
          );
        case StoreErrorCodes.querySearchRequired:
          throw QuerySearchRequiredException(
            message: e.message,
            code: StoreErrorCodes.querySearchRequired,
            requestId: e.requestId,
          );
        case StoreErrorCodes.storeIdRequired:
          throw StoreIdRequiredException(
            message: e.message,
            code: StoreErrorCodes.storeIdRequired,
            requestId: e.requestId,
          );
        default:
          throw GenericStoreException(
            e.message,
            code: StoreErrorCodes.genericError,
            requestId: e.requestId,
          );
      }
    }

    // For all other API exceptions, use the base mapper
    return super.mapApiExceptionToDomainException(e);
  }

  @override
  StoreException createFeatureException(String message,
      {String? code, String? requestId}) {
    return GenericStoreException(
      message,
      code: code ?? StoreErrorCodes.genericError,
      requestId: requestId,
    );
  }
}
