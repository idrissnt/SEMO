import 'package:equatable/equatable.dart';
import 'package:semo/features/profile/domain/entities/verification_response_entity.dart';

/// Base class for all email verification states
abstract class EmailVerificationState extends Equatable {
  const EmailVerificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class EmailVerificationInitial extends EmailVerificationState {
  const EmailVerificationInitial();
}

/// Loading state
class EmailVerificationLoading extends EmailVerificationState {
  const EmailVerificationLoading();
}

/// State when email verification request is successful
class EmailVerificationRequested extends EmailVerificationState {
  final VerificationResponse response;

  const EmailVerificationRequested({required this.response});

  @override
  List<Object?> get props => [response];
}

/// State when email code verification is successful
class EmailCodeVerified extends EmailVerificationState {
  final VerificationResponse response;

  const EmailCodeVerified({required this.response});

  @override
  List<Object?> get props => [response];
}

/// Base class for all email verification failure states
abstract class EmailVerificationFailureState extends EmailVerificationState {
  final String message;
  final bool canRetry;

  const EmailVerificationFailureState(
    this.message, {
    this.canRetry = true,
  });

  @override
  List<Object?> get props => [message, canRetry];
}

/// Network failure (no internet connection)
class EmailVerificationNetworkFailure extends EmailVerificationFailureState {
  const EmailVerificationNetworkFailure(
    String message, {
    bool canRetry = true,
  }) : super(message, canRetry: canRetry);
}

/// Server failure (backend issue)
class EmailVerificationServerFailure extends EmailVerificationFailureState {
  const EmailVerificationServerFailure(
    String message, {
    bool canRetry = true,
  }) : super(message, canRetry: canRetry);
}

/// User not found failure
class EmailUserNotFoundFailure extends EmailVerificationFailureState {
  const EmailUserNotFoundFailure(
    String message, {
    bool canRetry = true,
  }) : super(message, canRetry: canRetry);
}

/// Invalid verification code failure
class InvalidEmailVerificationCodeFailure extends EmailVerificationFailureState {
  const InvalidEmailVerificationCodeFailure(
    String message, {
    bool canRetry = true,
  }) : super(message, canRetry: canRetry);
}

/// Email verification request failure
class EmailVerificationRequestFailure extends EmailVerificationFailureState {
  const EmailVerificationRequestFailure(
    String message, {
    bool canRetry = true,
  }) : super(message, canRetry: canRetry);
}

/// Generic verification failure
class GenericEmailVerificationFailure extends EmailVerificationFailureState {
  const GenericEmailVerificationFailure(
    String message, {
    bool canRetry = false,
  }) : super(message, canRetry: canRetry);
}
