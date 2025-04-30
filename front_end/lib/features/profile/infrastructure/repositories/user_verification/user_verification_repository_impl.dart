import 'package:semo/core/domain/exceptions/api_exceptions.dart';
import 'package:semo/core/domain/services/api_client.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/utils/result.dart';
import 'package:semo/features/profile/domain/entities/verification_response_entity.dart';
import 'package:semo/features/profile/domain/exceptions/user_verifications/verif_exception_mapper.dart';
import 'package:semo/features/profile/domain/exceptions/user_verifications/verif_exceptions.dart';
import 'package:semo/features/profile/domain/repositories/user_verification/user_verification_repository.dart';
import 'package:semo/features/profile/infrastructure/repositories/user_verification/services/user_verification_service.dart';

/// Implementation of the UserVerificationRepository interface
class UserVerificationRepositoryImpl implements UserVerificationRepository {
  final UserVerificationService _verificationService;
  final AppLogger _logger;

  UserVerificationRepositoryImpl({
    required ApiClient apiClient,
    required AppLogger logger,
    required UserVerificationExceptionMapper userVerificationExceptionMapper,
  })  : _logger = logger,
        _verificationService = UserVerificationService(
          userVerificationExceptionMapper: userVerificationExceptionMapper,
          apiClient: apiClient,
          logger: logger,
        );

  @override
  Future<Result<VerificationResponse, UserVerifException>>
      requestEmailVerification(String email) async {
    try {
      final responseModel =
          await _verificationService.requestEmailVerification(email);
      return Result.success(responseModel.toDomain());
    } catch (e, stackTrace) {
      _logger.error('Error requesting email verification',
          error: e, stackTrace: stackTrace);
      return _handleUserVerifError(e, 'Email verification');
    }
  }

  @override
  Future<Result<VerificationResponse, UserVerifException>>
      requestPhoneVerification(String phoneNumber) async {
    try {
      final responseModel =
          await _verificationService.requestPhoneVerification(phoneNumber);
      return Result.success(responseModel.toDomain());
    } catch (e, stackTrace) {
      _logger.error('Error requesting phone verification',
          error: e, stackTrace: stackTrace);
      return _handleUserVerifError(e, 'Phone verification');
    }
  }

  @override
  Future<Result<VerificationResponse, UserVerifException>> verifyCode(
      String userId, String code, VerificationType verificationType) async {
    try {
      final responseModel =
          await _verificationService.verifyCode(userId, code, verificationType);
      return Result.success(responseModel.toDomain());
    } catch (e, stackTrace) {
      _logger.error('Error verifying code', error: e, stackTrace: stackTrace);

      return _handleUserVerifError(e, 'Code verification');
    }
  }

  @override
  Future<Result<VerificationResponse, UserVerifException>> requestPasswordReset(
      {String? email, String? phoneNumber}) async {
    try {
      final responseModel = await _verificationService.requestPasswordReset(
          email: email, phoneNumber: phoneNumber);
      return Result.success(responseModel.toDomain());
    } catch (e, stackTrace) {
      _logger.error('Error requesting password reset',
          error: e, stackTrace: stackTrace);
      return _handleUserVerifError(e, 'Password reset');
    }
  }

  @override
  Future<Result<VerificationResponse, UserVerifException>> resetPassword(
      String userId, String code, String newPassword) async {
    try {
      final responseModel =
          await _verificationService.resetPassword(userId, code, newPassword);
      return Result.success(responseModel.toDomain());
    } catch (e, stackTrace) {
      _logger.error('Error resetting password',
          error: e, stackTrace: stackTrace);
      return _handleUserVerifError(e, 'Password reset');
    }
  }

  Result<T, UserVerifException> _handleUserVerifError<T>(
      dynamic e, String assetType) {
    _logger.error('Error fetching $assetType: $e');

    // Handle domain-specific exceptions
    if (e is UserVerifException) {
      // User verification exceptions can be directly returned
      return Result.failure(e);
    } else if (e is ApiException) {
      // API exceptions can be directly returned as they extend DomainException
      // We need to wrap them in a UserVerifException to match the return type
      return Result.failure(UserVerifException(
        'Failed to fetch $assetType: ${e.message}',
        code: e.code,
        requestId: e.requestId,
      ));
    }

    // For all other exceptions, create a generic user verification exception
    return Result.failure(
      GenericUserVerifException('Failed to fetch $assetType: $e'),
    );
  }
}
