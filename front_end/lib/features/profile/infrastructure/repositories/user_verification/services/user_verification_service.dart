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
    _logger.info('Requesting email verification for: $email');

    try {
      final response = await _apiClient.post(
        UserVerifApiRoutes.requestEmailVerification,
        data: {'email': email},
      );
      return VerificationResponseModel.fromJson(response.data);
    } catch (e) {
      _logger.error('Failed to request email verification', error: e);
      _userVerificationExceptionMapper.mapApiExceptionToDomainException(e);
    }
  }

  /// Request phone verification code
  /// Returns a VerificationResponseModel containing message and requestId
  Future<VerificationResponseModel> requestPhoneVerification(
      String phoneNumber) async {
    _logger.info('Requesting phone verification for: $phoneNumber');

    try {
      final response = await _apiClient.post(
        UserVerifApiRoutes.requestPhoneVerification,
        data: {'phone_number': phoneNumber},
      );
      return VerificationResponseModel.fromJson(response.data);
    } catch (e) {
      _logger.error('Failed to request phone verification', error: e);
      _userVerificationExceptionMapper.mapApiExceptionToDomainException(e);
    }
  }

  /// code to verify the email or phone number of a user or to reset the password
  /// Returns a VerificationResponseModel containing message and requestId
  Future<VerificationResponseModel> verifyCode(
      String userId, String code, VerificationType verificationType) async {
    _logger.info('Verifying code for user: $userId, type: $verificationType');

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
      return VerificationResponseModel.fromJson(response.data);
    } catch (e) {
      _logger.error('Failed to verify code', error: e);
      _userVerificationExceptionMapper.mapApiExceptionToDomainException(e);
    }
  }

  /// Request password reset code
  /// Returns a VerificationResponseModel containing message and requestId
  Future<VerificationResponseModel> requestPasswordReset(
      {String? email, String? phoneNumber}) async {
    _logger.info('Requesting password reset for: ${email ?? phoneNumber}');

    final data = <String, dynamic>{};
    if (email != null) data['email'] = email;
    if (phoneNumber != null) data['phone_number'] = phoneNumber;

    try {
      final response = await _apiClient.post(
        UserVerifApiRoutes.requestPasswordReset,
        data: data,
      );
      return VerificationResponseModel.fromJson(response.data);
    } catch (e) {
      _logger.error('Failed to request password reset', error: e);
      _userVerificationExceptionMapper.mapApiExceptionToDomainException(e);
    }
  }

  /// Reset password with verification code
  /// Returns a VerificationResponseModel containing message and requestId
  Future<VerificationResponseModel> resetPassword(
      String userId, String code, String newPassword) async {
    _logger.info('Resetting password for user: $userId');

    try {
      final response = await _apiClient.post(
        UserVerifApiRoutes.resetPassword,
        data: {
          'user_id': userId,
          'code': code,
          'new_password': newPassword,
        },
      );
      return VerificationResponseModel.fromJson(response.data);
    } catch (e) {
      _logger.error('Failed to reset password', error: e);
      _userVerificationExceptionMapper.mapApiExceptionToDomainException(e);
    }
  }
}
