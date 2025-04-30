/// User verification-specific error code constants
/// These codes are specific to the user verification feature and should not be in the core module
class UserVerifErrorCodes {
  // User verification error codes
  static const String userNotFoundException = 'user_not_found';
  static const String invalidVerificationCodeException =
      'invalid_verification_code';

  // Email verification error codes
  static const String emailVerificationRequestFailedException =
      'email_verification_request_failed';

  // Phone verification error codes
  static const String phoneVerificationRequestFailedException =
      'phone_verification_request_failed';

  // Password reset error codes
  static const String passwordResetRequestFailedException =
      'password_reset_request_failed';
  static const String passwordResetFailedException = 'password_reset_failed';

  // Generic error code
  static const String genericError = 'generic_user_verification_error';
}
