import 'package:equatable/equatable.dart';
import 'package:semo/features/profile/domain/entities/profile_entity.dart';

abstract class HomeUserAddressEvent extends Equatable {
  const HomeUserAddressEvent();

  @override
  List<Object?> get props => [];
}

class HomeGetUserAddressEvent extends HomeUserAddressEvent {
  const HomeGetUserAddressEvent();
}

class HomeCreateAddressEvent extends HomeUserAddressEvent {
  final UserAddress address;

  const HomeCreateAddressEvent({required this.address});

  @override
  List<Object?> get props => [address];
}

class HomeUpdateAddressEvent extends HomeUserAddressEvent {
  final UserAddress address;

  const HomeUpdateAddressEvent({required this.address});

  @override
  List<Object?> get props => [address];
}
