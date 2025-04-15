import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/home/domain/usecases/user_address_usecases.dart';
import 'package:semo/features/home/presentation/bloc/user_address/user_address_event.dart';
import 'package:semo/features/home/presentation/bloc/user_address/user_address_state.dart';

class HomeUserAddressBloc extends Bloc<HomeUserAddressEvent, HomeUserAddressState> {
  final HomeUserAddressUseCases _userAddressUseCases;
  final AppLogger _logger = AppLogger();

  HomeUserAddressBloc({
    required HomeUserAddressUseCases userAddressUseCases,
  })  : _userAddressUseCases = userAddressUseCases,
        super(const HomeUserAddressInitial()) {
    on<HomeGetUserAddressEvent>(_onGetUserAddress);
    on<HomeCreateAddressEvent>(_onCreateAddress);
    on<HomeUpdateAddressEvent>(_onUpdateAddress);
  }

  Future<void> _onGetUserAddress(
    HomeGetUserAddressEvent event,
    Emitter<HomeUserAddressState> emit,
  ) async {
    _logger.debug('Home: Getting user address');
    emit(const HomeUserAddressLoading());

    final result = await _userAddressUseCases.getUserAddress();

    emit(result.fold(
      (address) {
        _logger.debug('Home: Successfully loaded user address');
        return HomeUserAddressLoaded(address: address);
      },
      (exception) {
        _logger.error('Home: Error loading user address', error: exception);
        return HomeUserAddressError(exception: exception);
      },
    ));
  }

  Future<void> _onCreateAddress(
    HomeCreateAddressEvent event,
    Emitter<HomeUserAddressState> emit,
  ) async {
    _logger.debug('Home: Creating new address');
    emit(const HomeUserAddressLoading());

    final result = await _userAddressUseCases.createAddress(event.address);

    emit(result.fold(
      (address) {
        _logger.debug('Home: Successfully created new address');
        return HomeAddressCreated(address: address);
      },
      (exception) {
        _logger.error('Home: Error creating new address', error: exception);
        return HomeUserAddressError(exception: exception);
      },
    ));
  }

  Future<void> _onUpdateAddress(
    HomeUpdateAddressEvent event,
    Emitter<HomeUserAddressState> emit,
  ) async {
    _logger.debug('Home: Updating address');
    emit(const HomeUserAddressLoading());

    final result = await _userAddressUseCases.updateAddress(event.address);

    emit(result.fold(
      (address) {
        _logger.debug('Home: Successfully updated address');
        return HomeAddressUpdated(address: address);
      },
      (exception) {
        _logger.error('Home: Error updating address', error: exception);
        return HomeUserAddressError(exception: exception);
      },
    ));
  }
}
