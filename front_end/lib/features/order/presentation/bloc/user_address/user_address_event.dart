import 'package:equatable/equatable.dart';
import 'package:semo/features/profile/domain/entities/profile_entity.dart';

abstract class OrderUserAddressEvent extends Equatable {
  const OrderUserAddressEvent();

  @override
  List<Object?> get props => [];
}

class OrderGetUserAddressEvent extends OrderUserAddressEvent {
  const OrderGetUserAddressEvent();
}

class OrderCreateAddressEvent extends OrderUserAddressEvent {
  final UserAddress address;

  const OrderCreateAddressEvent({required this.address});

  @override
  List<Object?> get props => [address];
}

class OrderUpdateAddressEvent extends OrderUserAddressEvent {
  final UserAddress address;

  const OrderUpdateAddressEvent({required this.address});

  @override
  List<Object?> get props => [address];
}
