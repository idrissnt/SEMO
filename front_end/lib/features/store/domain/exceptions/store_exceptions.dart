import 'package:semo/core/domain/exceptions/api_exceptions.dart';
import 'package:semo/features/store/domain/exceptions/store_error_codes.dart';

/// Base exception for all store-related errors

/// Domain exceptions for store
class StoreException extends DomainException {
  StoreException(
    String message, {
    String? code,
    String? requestId,
  }) : super(message, code: code, requestId: requestId);
}

class InvalidUuidException extends StoreException {
  InvalidUuidException(
      {String message = 'Invalid UUID provided',
      String? code,
      String? requestId})
      : super(message,
            code: code ?? StoreErrorCodes.invalidUuid, requestId: requestId);
}

class StoreIdRequiredException extends StoreException {
  StoreIdRequiredException(
      {String message = 'Store id is required',
      String? code,
      String? requestId})
      : super(message,
            code: code ?? StoreErrorCodes.storeIdRequired,
            requestId: requestId);
}

class AddressRequiredException extends StoreException {
  AddressRequiredException(
      {String message = 'Address is required', String? code, String? requestId})
      : super(message,
            code: code ?? StoreErrorCodes.addressRequired,
            requestId: requestId);
}

class QuerySearchRequiredException extends StoreException {
  QuerySearchRequiredException(
      {String message = 'Required query search is missing',
      String? code,
      String? requestId})
      : super(message,
            code: code ?? StoreErrorCodes.querySearchRequired,
            requestId: requestId);
}

/// Generic store exception for cases that don't fit other categories (500 Internal Server Error)
class GenericStoreException extends StoreException {
  GenericStoreException(String message, {String? code, String? requestId})
      : super(message,
            code: code ?? StoreErrorCodes.genericError, requestId: requestId);
}
