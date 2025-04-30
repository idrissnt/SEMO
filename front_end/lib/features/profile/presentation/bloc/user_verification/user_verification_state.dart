import 'package:equatable/equatable.dart';
import 'package:semo/features/profile/domain/exceptions/user_verifications/verif_exceptions.dart';

/// Base class for all user verification states
abstract class UserVerificationState extends Equatable {
  const UserVerificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class UserVerificationInitial extends UserVerificationState {
  const UserVerificationInitial();
}

/// Loading state
class UserVerificationLoading extends UserVerificationState {
  const UserVerificationLoading();
}

/// State when email verification request is successful
class EmailVerificationRequested extends UserVerificationState {
  const EmailVerificationRequested();
}

/// State when phone verification request is successful
class PhoneVerificationRequested extends UserVerificationState {
  const PhoneVerificationRequested();
}

/// State when code verification is successful
class CodeVerified extends UserVerificationState {
  const CodeVerified();
}

/// State when password reset request is successful
class PasswordResetRequested extends UserVerificationState {
  const PasswordResetRequested();
}

/// State when password reset is successful
class PasswordReset extends UserVerificationState {
  const PasswordReset();
}

/// Error state
class UserVerificationError extends UserVerificationState {
  final UserVerifException exception;

  const UserVerificationError({required this.exception});

  @override
  List<Object?> get props => [exception];
}
