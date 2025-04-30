import 'package:equatable/equatable.dart';
import 'package:semo/features/profile/domain/repositories/user_verification/user_verification_repository.dart';

/// Base class for all user verification events
abstract class UserVerificationEvent extends Equatable {
  const UserVerificationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to request email verification
class RequestEmailVerificationEvent extends UserVerificationEvent {
  final String email;

  const RequestEmailVerificationEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Event to request phone verification
class RequestPhoneVerificationEvent extends UserVerificationEvent {
  final String phoneNumber;

  const RequestPhoneVerificationEvent({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

/// Event to verify a code
class VerifyCodeEvent extends UserVerificationEvent {
  final String userId;
  final String code;
  final VerificationType verificationType;

  const VerifyCodeEvent({
    required this.userId,
    required this.code,
    required this.verificationType,
  });

  @override
  List<Object?> get props => [userId, code, verificationType];
}

/// Event to request password reset
class RequestPasswordResetEvent extends UserVerificationEvent {
  final String? email;
  final String? phoneNumber;

  const RequestPasswordResetEvent({
    this.email,
    this.phoneNumber,
  }) : assert(email != null || phoneNumber != null,
            'Either email or phoneNumber must be provided');

  @override
  List<Object?> get props => [email, phoneNumber];
}

/// Event to reset password
class ResetPasswordEvent extends UserVerificationEvent {
  final String userId;
  final String code;
  final String newPassword;

  const ResetPasswordEvent({
    required this.userId,
    required this.code,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [userId, code, newPassword];
}
