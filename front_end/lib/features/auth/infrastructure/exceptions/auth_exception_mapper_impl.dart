// auth_exception_mapper.dart
import 'package:semo/core/domain/exceptions/api_exceptions.dart';
import 'package:semo/core/domain/exceptions/api_error_code.dart';
import 'package:semo/core/infrastructure/exceptions/api_exception_mapper.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/domain/exceptions/auth/auth_error_codes.dart';
import 'package:semo/features/auth/domain/exceptions/auth/auth_exceptions.dart';
import 'package:semo/features/auth/domain/exceptions/auth/auth_exception_mapper.dart';

class AuthExceptionMapperImpl
    extends ApiExceptionMapperImpl<AuthenticationException>
    implements AuthExceptionMapper {
  final AppLogger logger;

  AuthExceptionMapperImpl({required this.logger}) : super(logger: logger);

  final logFileName = 'AuthExceptionMapperImpl';

  @override
  Never mapApiExceptionToDomainException(dynamic e) {
    // First check for domain exceptions that might have been thrown already
    if (e is AuthenticationException) {
      // If it's already a domain exception, just rethrow it
      throw e;
    }

    // We override backend error codes with our frontend constants for consistency
    // The original code is still logged above for debugging purposes
    if (e is NotFoundException) {
      // Check if this is a user not found error
      if (e.code == ErrorCodes.userNotFound) {
        logger.warning(
            '$logFileName: User not found exception detected in mapper');
        throw _createUserNotFoundException(e);
      }
      // For other not found errors, use the generic exception
      throw GenericAuthException(
        e.message,
        code: AuthErrorCodes.genericError,
        requestId: e.requestId,
      );
    } else if (e is UnauthorizedException) {
      // Check if this is a user not found error that came as a 401
      if (e.code == ErrorCodes.userNotFound) {
        logger.warning(
            '$logFileName: User not found exception detected in mapper (from 401)');
        throw _createUserNotFoundException(e);
      }

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

  /// Creates a UserNotFoundException from an API exception
  UserNotFoundException _createUserNotFoundException(ApiException e) {
    return UserNotFoundException(
      message: e.message,
      code: ErrorCodes.userNotFound,
      requestId: e.requestId,
    );
  }
}
