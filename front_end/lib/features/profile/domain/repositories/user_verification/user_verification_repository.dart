import 'package:semo/core/utils/result.dart';
import 'package:semo/features/profile/domain/entities/verification_response_entity.dart';
import 'package:semo/features/profile/domain/exceptions/user_verifications/verif_exceptions.dart';

/// Verification types for different verification methods
enum VerificationType {
  email,
  phone,
  // ignore: constant_identifier_names
  password_reset,
}

/// Repository interface for user verification operations
abstract class UserVerificationRepository {
  /// Request email verification code
  ///
  /// Returns a [Result] with a VerificationResponse entity containing message and requestId
  Future<Result<VerificationResponse, UserVerifException>>
      requestEmailVerification(String email);

  /// Request phone verification code
  ///
  /// Returns a [Result] with a VerificationResponse entity containing message and requestId
  Future<Result<VerificationResponse, UserVerifException>>
      requestPhoneVerification(String phoneNumber);

  /// Verify a code for email or phone verification
  ///
  /// Returns a [Result] with a VerificationResponse entity containing message and requestId
  Future<Result<VerificationResponse, UserVerifException>> verifyCode(
      String userId, String code, VerificationType verificationType);

  /// Request password reset code
  ///
  /// Either email or phoneNumber must be provided
  /// Returns a [Result] with a VerificationResponse entity containing message and requestId
  Future<Result<VerificationResponse, UserVerifException>> requestPasswordReset(
      {String? email, String? phoneNumber});

  /// Reset password with verification code
  ///
  /// Returns a [Result] with a VerificationResponse entity containing message and requestId
  Future<Result<VerificationResponse, UserVerifException>> resetPassword(
      String userId, String code, String newPassword);
}
