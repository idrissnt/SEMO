// auth_exception_mapper.dart
import 'package:semo/core/domain/exceptions/api_exceptions.dart';
import 'package:semo/core/infrastructure/exceptions/api_exception_mapper.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/domain/exceptions/auth/auth_error_codes.dart';
import 'package:semo/features/auth/domain/exceptions/auth/auth_exceptions.dart';
import 'package:semo/features/auth/domain/exceptions/auth/auth_exception_mapper.dart';

class AuthExceptionMapperImpl
    extends ApiExceptionMapperImpl<AuthenticationException>
    implements AuthExceptionMapper {
  AuthExceptionMapperImpl({required AppLogger logger}) : super(logger: logger);

  @override
  Never mapApiExceptionToDomainException(dynamic e) {
    // First check for domain exceptions that might have been thrown already
    if (e is AuthenticationException) {
      // If it's already a domain exception, just rethrow it
      throw e;
    }

    // We override backend error codes with our frontend constants for consistency
    // The original code is still logged above for debugging purposes
    if (e is UnauthorizedException) {
      throw InvalidCredentialsException(
        message: e.message,
        code: AuthErrorCodes.invalidCredentials,
        requestId: e.requestId,
      );
    } else if (e is ConflictException) {
      throw UserAlreadyExistsException(
        message: e.message,
        code: AuthErrorCodes.userAlreadyExists,
        requestId: e.requestId,
      );
    } else if (e is BadRequestException) {
      switch (e.code) {
        case AuthErrorCodes.missingToken:
          throw MissingRefreshTokenException(
            message: e.message,
            code: AuthErrorCodes.missingToken,
            requestId: e.requestId,
          );
        case AuthErrorCodes.invalidInput:
          throw InvalidInputException(
            message: e.message,
            code: AuthErrorCodes.invalidInput,
            requestId: e.requestId,
          );
        default:
          throw GenericAuthException(
            e.message,
            code: AuthErrorCodes.genericError,
            requestId: e.requestId,
          );
      }
    }

    // For all other API exceptions, use the base mapper
    return super.mapApiExceptionToDomainException(e);
  }

  @override
  AuthenticationException createFeatureException(String message,
      {String? code, String? requestId}) {
    return GenericAuthException(
      message,
      code: code ?? AuthErrorCodes.genericError,
      requestId: requestId,
    );
  }
}
