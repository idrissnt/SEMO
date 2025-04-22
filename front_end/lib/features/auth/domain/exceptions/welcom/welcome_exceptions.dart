import 'package:semo/core/domain/exceptions/api_exceptions.dart';
import 'package:semo/features/auth/domain/exceptions/welcom/welcome_error_codes.dart';

/// Base exception for welcome assets feature
class WelcomeException extends DomainException {
  WelcomeException(
    String message, {
    String? code = WelcomeErrorCodes.genericError,
    String? requestId,
  }) : super(message, code: code, requestId: requestId);
}

/// Exception thrown when welcome assets cannot be fetched
class WelcomeAssetsFetchException extends WelcomeException {
  WelcomeAssetsFetchException(
    String message, {
    String code = WelcomeErrorCodes.assetFetchFailed,
    String? requestId,
  }) : super(message, code: code, requestId: requestId);
}

/// Exception thrown when welcome assets cannot be found
class WelcomeAssetsNotFoundException extends WelcomeException {
  WelcomeAssetsNotFoundException(
    String message, {
    String code = WelcomeErrorCodes.assetNotFound,
    String? requestId,
  }) : super(message, code: code, requestId: requestId);
}

/// Exception thrown when welcome assets validation fails
class WelcomeAssetsValidationException extends WelcomeException {
  WelcomeAssetsValidationException(
    String message, {
    String code = WelcomeErrorCodes.invalidAsset,
    String? requestId,
  }) : super(message, code: code, requestId: requestId);
}

/// Generic welcome exception for unexpected errors
class GenericWelcomeException extends WelcomeException {
  GenericWelcomeException(
    String message, {
    String code = WelcomeErrorCodes.genericError,
    String? requestId,
  }) : super(message, code: code, requestId: requestId);
}
