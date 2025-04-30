import 'package:semo/core/domain/exceptions/api_exceptions.dart';
import 'package:semo/features/profile/domain/exceptions/user_verifications/verif_error_codes.dart';

/// Domain exceptions for user verification
class UserVerifException extends DomainException {
  UserVerifException(
    String message, {
    String? code,
    String? requestId,
  }) : super(message, code: code, requestId: requestId);
}

/// Exception for user not found (404)
class UserNotFoundException extends UserVerifException {
  UserNotFoundException(String message, {String? code, String? requestId})
      : super(message,
            code: code ?? UserVerifErrorCodes.userNotFoundException,
            requestId: requestId);
}

/// Exception for invalid verification code (400)
class InvalidVerificationCodeException extends UserVerifException {
  InvalidVerificationCodeException(String message,
      {String? code, String? requestId})
      : super(message,
            code: code ?? UserVerifErrorCodes.invalidVerificationCodeException,
            requestId: requestId);
}

/// Exception for email verification request failed (500)
class EmailVerificationRequestFailedException extends UserVerifException {
  EmailVerificationRequestFailedException(String message,
      {String? code, String? requestId})
      : super(message,
            code: code ??
                UserVerifErrorCodes.emailVerificationRequestFailedException,
            requestId: requestId);
}

/// Exception for phone verification request failed (500)
class PhoneVerificationRequestFailedException extends UserVerifException {
  PhoneVerificationRequestFailedException(String message,
      {String? code, String? requestId})
      : super(message,
            code: code ??
                UserVerifErrorCodes.phoneVerificationRequestFailedException,
            requestId: requestId);
}

/// Exception for password reset request failed (500)
class PasswordResetRequestFailedException extends UserVerifException {
  PasswordResetRequestFailedException(String message,
      {String? code, String? requestId})
      : super(message,
            code:
                code ?? UserVerifErrorCodes.passwordResetRequestFailedException,
            requestId: requestId);
}

/// Exception for password reset failed (500)
class PasswordResetFailedException extends UserVerifException {
  PasswordResetFailedException(String message,
      {String? code, String? requestId})
      : super(message,
            code: code ?? UserVerifErrorCodes.passwordResetFailedException,
            requestId: requestId);
}

// generic error
class GenericUserVerifException extends UserVerifException {
  GenericUserVerifException(String message, {String? code, String? requestId})
      : super(message,
            code: code ?? UserVerifErrorCodes.genericError,
            requestId: requestId);
}
