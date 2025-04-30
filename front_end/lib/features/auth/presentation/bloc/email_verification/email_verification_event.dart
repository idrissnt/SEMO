import 'package:equatable/equatable.dart';

/// Base class for all email verification events
abstract class EmailVerificationEvent extends Equatable {
  const EmailVerificationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to request email verification
class RequestEmailVerificationEvent extends EmailVerificationEvent {
  final String email;

  const RequestEmailVerificationEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Event to verify email code
class VerifyEmailCodeEvent extends EmailVerificationEvent {
  final String userId;
  final String code;

  const VerifyEmailCodeEvent({
    required this.userId,
    required this.code,
  });

  @override
  List<Object?> get props => [userId, code];
}
