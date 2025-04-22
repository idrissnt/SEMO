import 'package:equatable/equatable.dart';
import 'package:semo/features/auth/domain/entities/auth_entity.dart';
import 'package:semo/features/profile/domain/entities/profile_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

/// Base class for all auth failure states
abstract class AuthFailureState extends AuthState {
  final String message;
  final bool canRetry;

  const AuthFailureState(this.message, {this.canRetry = false});

  @override
  List<Object?> get props => [message, canRetry];
}

/// Generic authentication failure
class AuthFailure extends AuthFailureState {
  /// Get the error message (for backward compatibility)
  String get error => message;

  const AuthFailure(String message, {bool canRetry = false})
      : super(message, canRetry: canRetry);
}

/// Credentials error (wrong email/password)
class InvalidCredentialsFailure extends AuthFailureState {
  const InvalidCredentialsFailure(String message)
      : super(message, canRetry: true);
}

/// User already exists (409 Conflict)
class UserAlreadyExistsFailure extends AuthFailureState {
  const UserAlreadyExistsFailure(String message)
      : super(message, canRetry: true);
}

/// Invalid input error (invalid input data)
class InvalidInputFailure extends AuthFailureState {
  final Map<String, dynamic>? validationErrors;

  const InvalidInputFailure(String message, {this.validationErrors})
      : super(message, canRetry: true);

  @override
  List<Object?> get props => [message, canRetry, validationErrors];
}

/// Network error (no internet connection)
class NetworkFailure extends AuthFailureState {
  const NetworkFailure(String message) : super(message, canRetry: true);
}

/// Server error (backend issue)
class ServerFailure extends AuthFailureState {
  const ServerFailure(String message) : super(message, canRetry: false);
}

/// Profile fetch error (login succeeded but profile fetch failed)
class ProfileFetchFailure extends AuthFailureState {
  const ProfileFetchFailure(String message) : super(message, canRetry: true);
}
