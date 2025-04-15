import 'package:equatable/equatable.dart';
import 'package:semo/features/profile/domain/entities/profile_entity.dart';

abstract class UserAddressEvent extends Equatable {
  const UserAddressEvent();

  @override
  List<Object?> get props => [];
}

class GetUserAddressEvent extends UserAddressEvent {
  const GetUserAddressEvent();
}

class GetUserAddressByIdEvent extends UserAddressEvent {
  final String addressId;

  const GetUserAddressByIdEvent({required this.addressId});

  @override
  List<Object?> get props => [addressId];
}

class CreateUserAddressEvent extends UserAddressEvent {
  final UserAddress address;

  const CreateUserAddressEvent({required this.address});

  @override
  List<Object?> get props => [address];
}

class UpdateUserAddressEvent extends UserAddressEvent {
  final UserAddress address;

  const UpdateUserAddressEvent({required this.address});

  @override
  List<Object?> get props => [address];
}
