import 'package:equatable/equatable.dart';
import 'package:semo/features/profile/domain/entities/verification_response_entity.dart';

/// Base class for all email verification code states
abstract class VerifyEmailCodeState extends Equatable {
  const VerifyEmailCodeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class VerifyEmailCodeInitial extends VerifyEmailCodeState {
  const VerifyEmailCodeInitial();
}

/// Loading state
class VerifyEmailCodeLoading extends VerifyEmailCodeState {
  const VerifyEmailCodeLoading();
}

/// State when email code verification is successful
class VerifyEmailCodeVerified extends VerifyEmailCodeState {
  final VerificationResponse response;

  const VerifyEmailCodeVerified({required this.response});

  @override
  List<Object?> get props => [response];
}

/// Base class for all email verification failure states
abstract class VerifyEmailCodeFailureState extends VerifyEmailCodeState {
  final String message;
  final bool canRetry;

  const VerifyEmailCodeFailureState(
    this.message, {
    this.canRetry = true,
  });

  @override
  List<Object?> get props => [message, canRetry];
}

/// Network failure (no internet connection)
class VerifyEmailCodeNetworkFailure extends VerifyEmailCodeFailureState {
  const VerifyEmailCodeNetworkFailure(
    String message, {
    bool canRetry = true,
  }) : super(message, canRetry: canRetry);
}

/// Server failure (backend issue)
class VerifyEmailCodeServerFailure extends VerifyEmailCodeFailureState {
  const VerifyEmailCodeServerFailure(
    String message, {
    bool canRetry = true,
  }) : super(message, canRetry: canRetry);
}

/// Invalid verification code failure
class VerifyEmailCodeInvalid extends VerifyEmailCodeFailureState {
  const VerifyEmailCodeInvalid(
    String message, {
    bool canRetry = true,
  }) : super(message, canRetry: canRetry);
}

/// Generic verification failure
class GenericVerifyEmailCodeFailure extends VerifyEmailCodeFailureState {
  const GenericVerifyEmailCodeFailure(
    String message, {
    bool canRetry = false,
  }) : super(message, canRetry: canRetry);
}
