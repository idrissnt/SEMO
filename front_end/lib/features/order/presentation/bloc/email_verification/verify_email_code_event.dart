import 'package:equatable/equatable.dart';

/// Event to verify email code
class VerifyEmailCodeEvent extends Equatable {
  final String userId;
  final String code;

  const VerifyEmailCodeEvent({
    required this.userId,
    required this.code,
  });

  @override
  List<Object?> get props => [userId, code];
}
