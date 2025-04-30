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
  UserVerificationExceptionMapperImpl({required AppLogger logger})
      : super(logger: logger);

  @override
  Never mapApiExceptionToDomainException(dynamic e) {
    // First check for domain exceptions that might have been thrown already
    if (e is UserVerifException) {
      // If it's already a domain exception, just rethrow it
      throw e;
    }

    // Map specific API exceptions to user verification domain exceptions
    if (e is NotFoundException) {
      throw UserNotFoundException(
        e.message,
        code: UserVerifErrorCodes.userNotFoundException,
        requestId: e.requestId,
      );
    } else if (e is BadRequestException) {
      throw InvalidVerificationCodeException(
        e.message,
        code: UserVerifErrorCodes.invalidVerificationCodeException,
        requestId: e.requestId,
      );
    } else if (e is ApiServerException) {
      switch (e.code) {
        case UserVerifErrorCodes.emailVerificationRequestFailedException:
          throw EmailVerificationRequestFailedException(
            e.message,
            code: UserVerifErrorCodes.emailVerificationRequestFailedException,
            requestId: e.requestId,
          );
        case UserVerifErrorCodes.phoneVerificationRequestFailedException:
          throw PhoneVerificationRequestFailedException(
            e.message,
            code: UserVerifErrorCodes.phoneVerificationRequestFailedException,
            requestId: e.requestId,
          );
        case UserVerifErrorCodes.passwordResetRequestFailedException:
          throw PasswordResetRequestFailedException(
            e.message,
            code: UserVerifErrorCodes.passwordResetRequestFailedException,
            requestId: e.requestId,
          );
        case UserVerifErrorCodes.passwordResetFailedException:
          throw PasswordResetFailedException(
            e.message,
            code: UserVerifErrorCodes.passwordResetFailedException,
            requestId: e.requestId,
          );
        default:
          throw GenericUserVerifException(
            e.message,
            code: UserVerifErrorCodes.genericError,
            requestId: e.requestId,
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
