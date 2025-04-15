import 'package:equatable/equatable.dart';
import 'package:semo/features/profile/domain/entities/profile_entity.dart';
import 'package:semo/features/profile/domain/exceptions/profile_exceptions.dart';

/// Base class for all basic profile states
abstract class BasicProfileState extends Equatable {
  const BasicProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BasicProfileInitial extends BasicProfileState {
  const BasicProfileInitial();
}

/// Loading state
class BasicProfileLoading extends BasicProfileState {
  const BasicProfileLoading();
}

/// State when user profile is loaded successfully
class UserProfileLoaded extends BasicProfileState {
  final User user;

  const UserProfileLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

/// State when user profile is updated successfully
class UserProfileUpdated extends BasicProfileState {
  final User user;

  const UserProfileUpdated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// State when account deletion is successful
class AccountDeleted extends BasicProfileState {
  const AccountDeleted();
}

/// Error state
class BasicProfileError extends BasicProfileState {
  final BasicProfileException exception;

  const BasicProfileError({required this.exception});

  @override
  List<Object?> get props => [exception];
}
