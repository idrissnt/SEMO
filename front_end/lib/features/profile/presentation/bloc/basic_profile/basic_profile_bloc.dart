import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/profile/domain/usecases/basic_profile_usecases.dart';
import 'package:semo/features/profile/presentation/bloc/basic_profile/basic_profile_event.dart';
import 'package:semo/features/profile/presentation/bloc/basic_profile/basic_profile_state.dart';

/// BLoC for managing basic profile operations
class BasicProfileBloc extends Bloc<BasicProfileEvent, BasicProfileState> {
  final BasicProfileUseCases _profileUseCases;
  final AppLogger _logger = AppLogger();

  BasicProfileBloc({
    required BasicProfileUseCases profileUseCases,
  })  : _profileUseCases = profileUseCases,
        super(const BasicProfileInitial()) {
    on<GetCurrentUserEvent>(_onGetCurrentUser);
    on<UpdateUserProfileEvent>(_onUpdateUserProfile);
    on<DeleteAccountEvent>(_onDeleteAccount);
  }

  Future<void> _onGetCurrentUser(
    GetCurrentUserEvent event,
    Emitter<BasicProfileState> emit,
  ) async {
    _logger.debug('Getting current user profile');
    emit(const BasicProfileLoading());

    final result = await _profileUseCases.getCurrentUser();

    emit(result.fold(
      (user) {
        _logger.debug('Successfully loaded user profile');
        return UserProfileLoaded(user: user);
      },
      (exception) {
        _logger.error('Error loading user profile', error: exception);
        return BasicProfileError(exception: exception);
      },
    ));
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfileEvent event,
    Emitter<BasicProfileState> emit,
  ) async {
    _logger.debug('Updating user profile');
    emit(const BasicProfileLoading());

    final result = await _profileUseCases.updateUserProfile(
      firstName: event.firstName,
      lastName: event.lastName,
      email: event.email,
      profilePhotoUrl: event.profilePhotoUrl,
      phoneNumber: event.phoneNumber,
    );

    emit(result.fold(
      (user) {
        _logger.debug('Successfully updated user profile');
        return UserProfileUpdated(user: user);
      },
      (exception) {
        _logger.error('Error updating user profile', error: exception);
        return BasicProfileError(exception: exception);
      },
    ));
  }

  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<BasicProfileState> emit,
  ) async {
    _logger.debug('Deleting user account');
    emit(const BasicProfileLoading());

    final result = await _profileUseCases.deleteAccount();

    emit(result.fold(
      (success) {
        _logger.debug('Successfully deleted user account');
        return const AccountDeleted();
      },
      (exception) {
        _logger.error('Error deleting user account', error: exception);
        return BasicProfileError(exception: exception);
      },
    ));
  }
}
