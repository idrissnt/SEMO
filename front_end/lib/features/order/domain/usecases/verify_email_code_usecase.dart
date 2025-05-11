import 'package:semo/core/utils/result.dart';
import 'package:semo/features/profile/domain/entities/verification_response_entity.dart';
import 'package:semo/features/profile/domain/exceptions/user_verifications/verif_exceptions.dart';
import 'package:semo/features/profile/domain/repositories/user_verification/user_verification_repository.dart';

class VerifyEmailCodeUseCase {
  final UserVerificationRepository _verificationRepository;

  VerifyEmailCodeUseCase({
    required UserVerificationRepository verificationRepository,
  }) : _verificationRepository = verificationRepository;

  Future<Result<VerificationResponse, UserVerifException>> verifyEmailCode(
      String userId, String code) async {
    return await _verificationRepository.verifyCode(
        userId, code, VerificationType.email);
  }
}
