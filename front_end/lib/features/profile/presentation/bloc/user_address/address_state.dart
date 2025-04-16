import 'package:equatable/equatable.dart';
import 'package:semo/features/profile/domain/entities/profile_entity.dart';
import 'package:semo/features/profile/domain/exceptions/profile_exceptions.dart';

abstract class UserAddressState extends Equatable {
  const UserAddressState();

  @override
  List<Object?> get props => [];
}

class UserAddressInitial extends UserAddressState {
  const UserAddressInitial();
}

class UserAddressLoading extends UserAddressState {
  const UserAddressLoading();
}

class UserAddressError extends UserAddressState {
  final UserAddressException exception;

  const UserAddressError({required this.exception});

  @override
  List<Object?> get props => [exception];
}

class UserAddressLoaded extends UserAddressState {
  final UserAddress address;

  const UserAddressLoaded({required this.address});

  @override
  List<Object?> get props => [address];
}

class UserAddressCreated extends UserAddressState {
  final UserAddress address;

  const UserAddressCreated({required this.address});

  @override
  List<Object?> get props => [address];
}

class UserAddressUpdated extends UserAddressState {
  final UserAddress address;

  const UserAddressUpdated({required this.address});

  @override
  List<Object?> get props => [address];
}
