import 'package:equatable/equatable.dart';
import 'package:semo/features/profile/domain/entities/profile_entity.dart';
import 'package:semo/features/profile/domain/exceptions/profile_exceptions.dart';

abstract class HomeUserAddressState extends Equatable {
  const HomeUserAddressState();

  @override
  List<Object?> get props => [];
}

class HomeUserAddressInitial extends HomeUserAddressState {
  const HomeUserAddressInitial();
}

class HomeUserAddressLoading extends HomeUserAddressState {
  const HomeUserAddressLoading();
}

class HomeUserAddressError extends HomeUserAddressState {
  final DomainException exception;

  const HomeUserAddressError({required this.exception});

  @override
  List<Object?> get props => [exception];
}

class HomeUserAddressLoaded extends HomeUserAddressState {
  final UserAddress address;

  const HomeUserAddressLoaded({required this.address});

  @override
  List<Object?> get props => [address];
}

class HomeAddressCreated extends HomeUserAddressState {
  final UserAddress address;

  const HomeAddressCreated({required this.address});

  @override
  List<Object?> get props => [address];
}

class HomeAddressUpdated extends HomeUserAddressState {
  final UserAddress address;

  const HomeAddressUpdated({required this.address});

  @override
  List<Object?> get props => [address];
}
