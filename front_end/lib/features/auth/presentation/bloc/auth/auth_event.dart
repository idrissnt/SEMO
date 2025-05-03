import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String firstName;
  final String email;
  final String password;
  final String? phoneNumber;
  final String? profilePhotoUrl;

  const AuthRegisterRequested({
    required this.firstName,
    required this.email,
    required this.password,
    this.phoneNumber,
    this.profilePhotoUrl,
  });

  @override
  List<Object?> get props =>
      [firstName, email, password, phoneNumber, profilePhotoUrl];
}

class AuthLogoutRequested extends AuthEvent {
  // No parameters needed for better security
  const AuthLogoutRequested();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

/// Event to reset the auth state to initial
/// Used when navigating between auth screens to clear any error states
class AuthResetState extends AuthEvent {}

/// Event to enter guest mode, allowing access to the app without authentication
/// This is used for the "Passer" button to skip the login process
class EnterGuestMode extends AuthEvent {}
