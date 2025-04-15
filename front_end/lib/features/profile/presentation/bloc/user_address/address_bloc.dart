import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/profile/domain/usecases/address_usecases.dart';
import 'package:semo/features/profile/presentation/bloc/user_address/address_event.dart';
import 'package:semo/features/profile/presentation/bloc/user_address/address_state.dart';

class UserAddressBloc extends Bloc<UserAddressEvent, UserAddressState> {
  final UserAddressUseCases _userAddressUseCases;
  final AppLogger _logger = AppLogger();

  UserAddressBloc({
    required UserAddressUseCases userAddressUseCases,
  })  : _userAddressUseCases = userAddressUseCases,
        super(const UserAddressInitial()) {
    on<GetUserAddressEvent>(_onGetUserAddress);
    on<GetUserAddressByIdEvent>(_onGetUserAddressById);
    on<CreateUserAddressEvent>(_onCreateUserAddress);
    on<UpdateUserAddressEvent>(_onUpdateUserAddress);
  }

  Future<void> _onGetUserAddress(
    GetUserAddressEvent event,
    Emitter<UserAddressState> emit,
  ) async {
    _logger.debug('Getting user address');
    emit(const UserAddressLoading());

    final result = await _userAddressUseCases.getUserAddress();

    emit(result.fold(
      (address) {
        _logger.debug('Successfully loaded user address');
        return UserAddressLoaded(address: address);
      },
      (exception) {
        _logger.error('Error loading user address', error: exception);
        return UserAddressError(exception: exception);
      },
    ));
  }

  Future<void> _onGetUserAddressById(
    GetUserAddressByIdEvent event,
    Emitter<UserAddressState> emit,
  ) async {
    _logger.debug('Getting user address by ID: ${event.addressId}');
    emit(const UserAddressLoading());

    final result = await _userAddressUseCases.getAddressById(event.addressId);

    emit(result.fold(
      (address) {
        _logger.debug('Successfully loaded address by ID');
        return UserAddressLoaded(address: address);
      },
      (exception) {
        _logger.error('Error loading address by ID', error: exception);
        return UserAddressError(exception: exception);
      },
    ));
  }

  Future<void> _onCreateUserAddress(
    CreateUserAddressEvent event,
    Emitter<UserAddressState> emit,
  ) async {
    _logger.debug('Creating new user address');
    emit(const UserAddressLoading());

    final result = await _userAddressUseCases.createAddress(event.address);

    emit(result.fold(
      (address) {
        _logger.debug('Successfully created new address');
        return UserAddressCreated(address: address);
      },
      (exception) {
        _logger.error('Error creating new address', error: exception);
        return UserAddressError(exception: exception);
      },
    ));
  }

  Future<void> _onUpdateUserAddress(
    UpdateUserAddressEvent event,
    Emitter<UserAddressState> emit,
  ) async {
    _logger.debug('Updating user address');
    emit(const UserAddressLoading());

    final result = await _userAddressUseCases.updateAddress(event.address);

    emit(result.fold(
      (address) {
        _logger.debug('Successfully updated address');
        return UserAddressUpdated(address: address);
      },
      (exception) {
        _logger.error('Error updating address', error: exception);
        return UserAddressError(exception: exception);
      },
    ));
  }
}
