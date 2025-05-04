// verif_exception_mapper_imp.dart
import 'package:semo/core/infrastructure/exceptions/api_exception_mapper.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/profile/domain/exceptions/user_verifications/verif_error_codes.dart';
import 'package:semo/features/profile/domain/exceptions/user_verifications/verif_exceptions.dart';
import 'package:semo/features/profile/domain/exceptions/user_verifications/verif_exception_mapper.dart';
import 'package:semo/core/domain/exceptions/api_exceptions.dart';

class UserVerificationExceptionMapperImpl
    extends ApiExceptionMapperImpl<UserVerifException>
    implements UserVerificationExceptionMapper {
  final AppLogger logger;

  final String theLogName = 'UserVerificationExceptionMapperImpl';

  UserVerificationExceptionMapperImpl({required this.logger})
      : super(logger: logger);

  @override
  Never mapApiExceptionToDomainException(dynamic e) {
    // If the error is already a domain exception, just rethrow it
    if (e is UserVerifException) {
      throw e;
    }

    // Safely extract message, code and requestId if they exist
    String errorMessage;
    String? errorCode;
    String? requestId;

    if (e is ApiException) {
      // The ApiClientImpl has already processed the DioException and created an ApiException
      // with the appropriate message, code, and requestId
      errorMessage = e.message;
      errorCode = e.code;
      requestId = e.requestId;
    } else {
      // Handle non-API exceptions
      errorMessage = e.toString();
      logger.error('[$logName] : Non-API Exception: $errorMessage', error: e);
      throw GenericUserVerifException(
        errorMessage,
        code: UserVerifErrorCodes.genericError,
        requestId: requestId,
      );
    }

    // Map specific API exceptions to user verification domain exceptions
    if (e is NotFoundException) {
      logger.error('[$logName] : NotFoundException: $errorMessage', error: e);
      throw UserNotFoundException(
        errorMessage,
        code: UserVerifErrorCodes.userNotFoundException,
        requestId: requestId,
      );
    } else if (e is BadRequestException) {
      logger.error('[$logName] : BadRequestException: $errorMessage', error: e);
      throw InvalidVerificationCodeException(
        errorMessage,
        code: UserVerifErrorCodes.invalidVerificationCodeException,
        requestId: requestId,
      );
    } else if (e is ApiServerException) {
      logger.error('[$logName] : ApiServerException: $errorMessage', error: e);
      switch (errorCode) {
        case UserVerifErrorCodes.emailVerificationRequestFailedException:
          logger.error(
              '[$logName] : EmailVerificationRequestFailedException: $errorMessage',
              error: e);
          throw EmailVerificationRequestFailedException(
            errorMessage,
            code: UserVerifErrorCodes.emailVerificationRequestFailedException,
            requestId: requestId,
          );
        case UserVerifErrorCodes.phoneVerificationRequestFailedException:
          logger.error(
              '[$logName] : PhoneVerificationRequestFailedException: $errorMessage',
              error: e);
          throw PhoneVerificationRequestFailedException(
            errorMessage,
            code: UserVerifErrorCodes.phoneVerificationRequestFailedException,
            requestId: requestId,
          );
        case UserVerifErrorCodes.passwordResetRequestFailedException:
          logger.error(
              '[$logName] : PasswordResetRequestFailedException: $errorMessage',
              error: e);
          throw PasswordResetRequestFailedException(
            errorMessage,
            code: UserVerifErrorCodes.passwordResetRequestFailedException,
            requestId: requestId,
          );
        case UserVerifErrorCodes.passwordResetFailedException:
          logger.error(
              '[$logName] : PasswordResetFailedException: $errorMessage',
              error: e);
          throw PasswordResetFailedException(
            errorMessage,
            code: UserVerifErrorCodes.passwordResetFailedException,
            requestId: requestId,
          );
        default:
          logger.error('[$logName] : GenericUserVerifException: $errorMessage',
              error: e);
          throw GenericUserVerifException(
            errorMessage,
            code: UserVerifErrorCodes.genericError,
            requestId: requestId,
          );
      }
    }

    // For all other API exceptions, use the base mapper
    return super.mapApiExceptionToDomainException(e);
  }

  @override
  UserVerifException createFeatureException(String message,
      {String? code, String? requestId}) {
    return UserVerifException(message, code: code, requestId: requestId);
  }
}
