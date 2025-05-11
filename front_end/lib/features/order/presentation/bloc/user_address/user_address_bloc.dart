import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/order/domain/usecases/user_address_usecases.dart';
import 'package:semo/features/order/presentation/bloc/user_address/user_address_event.dart';
import 'package:semo/features/order/presentation/bloc/user_address/user_address_state.dart';

class OrderUserAddressBloc
    extends Bloc<OrderUserAddressEvent, OrderUserAddressState> {
  final OrderUserAddressUseCases _userAddressUseCases;
  final AppLogger _logger = AppLogger();

  OrderUserAddressBloc({
    required OrderUserAddressUseCases userAddressUseCases,
  })  : _userAddressUseCases = userAddressUseCases,
        super(const OrderUserAddressInitial()) {
    on<OrderGetUserAddressEvent>(_onGetUserAddress);
    on<OrderCreateAddressEvent>(_onCreateAddress);
    on<OrderUpdateAddressEvent>(_onUpdateAddress);
  }

  Future<void> _onGetUserAddress(
    OrderGetUserAddressEvent event,
    Emitter<OrderUserAddressState> emit,
  ) async {
    _logger.debug('Order: Getting user address');
    emit(const OrderUserAddressLoading());

    final result = await _userAddressUseCases.getUserAddress();

    emit(result.fold(
      (address) {
        _logger.debug('Order: Successfully loaded user address');
        return OrderUserAddressLoaded(address: address);
      },
      (exception) {
        _logger.error('Order: Error loading user address', error: exception);
        return OrderUserAddressError(exception: exception);
      },
    ));
  }

  Future<void> _onCreateAddress(
    OrderCreateAddressEvent event,
    Emitter<OrderUserAddressState> emit,
  ) async {
    _logger.debug('Order: Creating new address');
    emit(const OrderUserAddressLoading());

    final result = await _userAddressUseCases.createAddress(event.address);

    emit(result.fold(
      (address) {
        _logger.debug('Order: Successfully created new address');
        return OrderAddressCreated(address: address);
      },
      (exception) {
        _logger.error('Order: Error creating new address', error: exception);
        return OrderUserAddressError(exception: exception);
      },
    ));
  }

  Future<void> _onUpdateAddress(
    OrderUpdateAddressEvent event,
    Emitter<OrderUserAddressState> emit,
  ) async {
    _logger.debug('Order: Updating address');
    emit(const OrderUserAddressLoading());

    final result = await _userAddressUseCases.updateAddress(event.address);

    emit(result.fold(
      (address) {
        _logger.debug('Order: Successfully updated address');
        return OrderAddressUpdated(address: address);
      },
      (exception) {
        _logger.error('Order: Error updating address', error: exception);
        return OrderUserAddressError(exception: exception);
      },
    ));
  }
}
