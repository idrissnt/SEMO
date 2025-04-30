import 'package:equatable/equatable.dart';
import 'package:semo/features/profile/domain/entities/verification_response_entity.dart';

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
  final VerificationResponse response;

  const EmailVerificationRequested({required this.response});

  @override
  List<Object?> get props => [response];
}

/// State when phone verification request is successful
class PhoneVerificationRequested extends UserVerificationState {
  final VerificationResponse response;

  const PhoneVerificationRequested({required this.response});

  @override
  List<Object?> get props => [response];
}

/// State when code verification is successful
class CodeVerified extends UserVerificationState {
  final VerificationResponse response;

  const CodeVerified({required this.response});

  @override
  List<Object?> get props => [response];
}

/// State when password reset request is successful
class PasswordResetRequested extends UserVerificationState {
  final VerificationResponse response;

  const PasswordResetRequested({required this.response});

  @override
  List<Object?> get props => [response];
}

/// State when password reset is successful
class PasswordReset extends UserVerificationState {
  final VerificationResponse response;

  const PasswordReset({required this.response});

  @override
  List<Object?> get props => [response];
}

/// Base class for all verification failure states
abstract class UserVerificationFailureState extends UserVerificationState {
  final String message;
  final bool canRetry;

  const UserVerificationFailureState(
    this.message, {
    this.canRetry = true,
  });

  @override
  List<Object?> get props => [message, canRetry];
}

/// Network failure (no internet connection)
class UserVerificationNetworkFailure extends UserVerificationFailureState {
  const UserVerificationNetworkFailure(
    String message, {
    bool canRetry = true,
  }) : super(message, canRetry: canRetry);
}

/// Server failure (backend issue)
class UserVerificationServerFailure extends UserVerificationFailureState {
  const UserVerificationServerFailure(
    String message, {
    bool canRetry = true,
  }) : super(message, canRetry: canRetry);
}

/// User not found failure
class UserNotFoundFailure extends UserVerificationFailureState {
  const UserNotFoundFailure(
    String message, {
    bool canRetry = true,
  }) : super(message, canRetry: canRetry);
}

/// Invalid verification code failure
class InvalidVerificationCodeFailure extends UserVerificationFailureState {
  const InvalidVerificationCodeFailure(
    String message, {
    bool canRetry = true,
  }) : super(message, canRetry: canRetry);
}

/// Email verification request failure
class EmailVerificationRequestFailure extends UserVerificationFailureState {
  const EmailVerificationRequestFailure(
    String message, {
    bool canRetry = true,
  }) : super(message, canRetry: canRetry);
}

/// Phone verification request failure
class PhoneVerificationRequestFailure extends UserVerificationFailureState {
  const PhoneVerificationRequestFailure(
    String message, {
    bool canRetry = true,
  }) : super(message, canRetry: canRetry);
}

/// Password reset request failure
class PasswordResetRequestFailure extends UserVerificationFailureState {
  const PasswordResetRequestFailure(
    String message, {
    bool canRetry = true,
  }) : super(message, canRetry: canRetry);
}

/// Password reset failure
class PasswordResetFailure extends UserVerificationFailureState {
  const PasswordResetFailure(
    String message, {
    bool canRetry = true,
  }) : super(message, canRetry: canRetry);
}

/// Generic verification failure
class GenericVerificationFailure extends UserVerificationFailureState {
  const GenericVerificationFailure(
    String message, {
    bool canRetry = false,
  }) : super(message, canRetry: canRetry);
}
