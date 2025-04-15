import 'package:equatable/equatable.dart';

/// Base class for all basic profile events
abstract class BasicProfileEvent extends Equatable {
  const BasicProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event to get the current user's profile
class GetCurrentUserEvent extends BasicProfileEvent {
  const GetCurrentUserEvent();
}

/// Event to update the user's profile
class UpdateUserProfileEvent extends BasicProfileEvent {
  final String firstName;
  final String lastName;
  final String? email;
  final String? profilePhotoUrl;
  final String? phoneNumber;

  const UpdateUserProfileEvent({
    required this.firstName,
    required this.lastName,
    this.email,
    this.profilePhotoUrl,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        email,
        profilePhotoUrl,
        phoneNumber,
      ];
}

/// Event to delete the user's account
class DeleteAccountEvent extends BasicProfileEvent {
  const DeleteAccountEvent();
}
