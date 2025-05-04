import 'package:semo/core/domain/services/api_client.dart';
import 'package:semo/core/infrastructure/api_endpoints/user_verif_endpoints.dart';
import 'package:semo/core/utils/logger.dart';

import 'package:semo/features/profile/domain/exceptions/user_verifications/verif_exception_mapper.dart';
import 'package:semo/features/profile/domain/repositories/user_verification/user_verification_repository.dart';
import 'package:semo/features/profile/infrastructure/models/verification_response_model.dart';

/// Service class for user verification operations
class UserVerificationService {
  final ApiClient _apiClient;
  final AppLogger _logger;
  final UserVerificationExceptionMapper _userVerificationExceptionMapper;

  final logName = 'UserVerificationService';

  UserVerificationService({
    required ApiClient apiClient,
    required AppLogger logger,
    required UserVerificationExceptionMapper userVerificationExceptionMapper,
  })  : _apiClient = apiClient,
        _logger = logger,
        _userVerificationExceptionMapper = userVerificationExceptionMapper;

  /// Request email verification code
  /// Returns a VerificationResponseModel containing message and requestId
  Future<VerificationResponseModel> requestEmailVerification(
      String email) async {
    _logger.info('[$logName] : Requesting email verification for: $email');

    try {
      final response = await _apiClient.post(
        UserVerifApiRoutes.requestEmailVerification,
        data: {'email': email},
      );
      // The response is already the JSON object, not a wrapper with .data property
      return VerificationResponseModel.fromJson(response);
    } catch (e) {
      _logger.error('[$logName] : Failed to request email verification',
          error: e);
      throw _userVerificationExceptionMapper
          .mapApiExceptionToDomainException(e);
    }
  }

  /// Request phone verification code
  /// Returns a VerificationResponseModel containing message and requestId
  Future<VerificationResponseModel> requestPhoneVerification(
      String phoneNumber) async {
    _logger
        .info('[$logName] : Requesting phone verification for: $phoneNumber');

    try {
      final response = await _apiClient.post(
        UserVerifApiRoutes.requestPhoneVerification,
        data: {'phone_number': phoneNumber},
      );
      // The response is already the JSON object, not a wrapper with .data property
      return VerificationResponseModel.fromJson(response);
    } catch (e) {
      _logger.error('[$logName] : Failed to request phone verification',
          error: e);
      throw _userVerificationExceptionMapper
          .mapApiExceptionToDomainException(e);
    }
  }

  /// code to verify the email or phone number of a user or to reset the password
  /// Returns a VerificationResponseModel containing message and requestId
  Future<VerificationResponseModel> verifyCode(
      String userId, String code, VerificationType verificationType) async {
    _logger.info(
        '[$logName] : Verifying code for user: $userId, type: $verificationType');

    // Convert enum to string for API
    final typeString = verificationType.toString().split('.').last;

    try {
      final response = await _apiClient.post(
        UserVerifApiRoutes.verifyCode,
        data: {
          'user_id': userId,
          'code': code,
          'verification_type': typeString,
        },
      );
      // The response is already the JSON object, not a wrapper with .data property
      return VerificationResponseModel.fromJson(response);
    } catch (e) {
      _logger.error('[$logName] :  Failed to verify code', error: e);
      throw _userVerificationExceptionMapper
          .mapApiExceptionToDomainException(e);
    }
  }

  /// Request password reset code
  /// Returns a VerificationResponseModel containing message and requestId
  Future<VerificationResponseModel> requestPasswordReset(
      {String? email, String? phoneNumber}) async {
    _logger.info(
        '[$logName] : Requesting password reset for: ${email ?? phoneNumber}');

    final data = <String, dynamic>{};
    if (email != null) data['email'] = email;
    if (phoneNumber != null) data['phone_number'] = phoneNumber;

    try {
      final response = await _apiClient.post(
        UserVerifApiRoutes.requestPasswordReset,
        data: data,
      );
      // The response is already the JSON object, not a wrapper with .data property
      return VerificationResponseModel.fromJson(response);
    } catch (e) {
      _logger.error('[$logName] : Failed to request password reset', error: e);
      throw _userVerificationExceptionMapper
          .mapApiExceptionToDomainException(e);
    }
  }

  /// Reset password with verification code
  /// Returns a VerificationResponseModel containing message and requestId
  Future<VerificationResponseModel> resetPassword(
      String userId, String code, String newPassword) async {
    _logger.info('[$logName] : Resetting password for user: $userId');

    try {
      final response = await _apiClient.post(
        UserVerifApiRoutes.resetPassword,
        data: {
          'user_id': userId,
          'code': code,
          'new_password': newPassword,
        },
      );
      // The response is already the JSON object, not a wrapper with .data property
      return VerificationResponseModel.fromJson(response);
    } catch (e) {
      _logger.error('[$logName] : Failed to reset password', error: e);
      throw _userVerificationExceptionMapper
          .mapApiExceptionToDomainException(e);
    }
  }
}
