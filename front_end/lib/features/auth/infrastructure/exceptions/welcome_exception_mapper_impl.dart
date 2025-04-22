// welcome_exception_mapper_impl.dart
import 'package:semo/core/domain/exceptions/api_exceptions.dart';
import 'package:semo/core/infrastructure/exceptions/api_exception_mapper.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/domain/exceptions/welcom/welcome_error_codes.dart';
import 'package:semo/features/auth/domain/exceptions/welcom/welcome_exceptions.dart';
import 'package:semo/features/auth/domain/exceptions/welcom/welcome_exception_mapper.dart';

class WelcomeExceptionMapperImpl
    extends ApiExceptionMapperImpl<WelcomeException>
    implements WelcomeExceptionMapper {
  WelcomeExceptionMapperImpl({required AppLogger logger})
      : super(logger: logger);

  @override
  Never mapApiExceptionToDomainException(dynamic e) {
    // First check for domain exceptions that might have been thrown already
    if (e is WelcomeException) {
      // If it's already a domain exception, just rethrow it
      throw e;
    }

    // Map specific API exceptions to welcome domain exceptions
    if (e is NotFoundException) {
      throw WelcomeAssetsNotFoundException(
        e.message,
        code: WelcomeErrorCodes.assetNotFound,
        requestId: e.requestId,
      );
    } else if (e is BadRequestException) {
      throw WelcomeAssetsValidationException(
        e.message,
        code: WelcomeErrorCodes.invalidAsset,
        requestId: e.requestId,
      );
    }

    // For all other API exceptions, use the base mapper
    return super.mapApiExceptionToDomainException(e);
  }

  @override
  WelcomeException createFeatureException(String message,
      {String? code, String? requestId}) {
    return WelcomeAssetsFetchException(
      message,
      code: code ?? WelcomeErrorCodes.genericError,
      requestId: requestId,
    );
  }
}
