import 'package:equatable/equatable.dart';
import 'package:semo/core/domain/exceptions/api_exceptions.dart';
import 'package:semo/features/profile/domain/entities/profile_entity.dart';

abstract class OrderUserAddressState extends Equatable {
  const OrderUserAddressState();

  @override
  List<Object?> get props => [];
}

class OrderUserAddressInitial extends OrderUserAddressState {
  const OrderUserAddressInitial();
}

class OrderUserAddressLoading extends OrderUserAddressState {
  const OrderUserAddressLoading();
}

class OrderUserAddressError extends OrderUserAddressState {
  final DomainException exception;

  const OrderUserAddressError({required this.exception});

  @override
  List<Object?> get props => [exception];
}

class OrderUserAddressLoaded extends OrderUserAddressState {
  final UserAddress address;

  const OrderUserAddressLoaded({required this.address});

  @override
  List<Object?> get props => [address];
}

class OrderAddressCreated extends OrderUserAddressState {
  final UserAddress address;

  const OrderAddressCreated({required this.address});

  @override
  List<Object?> get props => [address];
}

class OrderAddressUpdated extends OrderUserAddressState {
  final UserAddress address;

  const OrderAddressUpdated({required this.address});

  @override
  List<Object?> get props => [address];
}
