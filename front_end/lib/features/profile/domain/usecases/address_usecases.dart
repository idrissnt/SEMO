import 'package:semo/core/utils/result.dart';
import 'package:semo/features/profile/domain/entities/profile_entity.dart';
import 'package:semo/features/profile/domain/exceptions/profile_exceptions.dart';
import 'package:semo/features/profile/domain/repositories/services/user_address_repository.dart';

/// Use cases for the Profile feature
class UserAddressUseCases {
  final UserAddressRepository _userAddressRepository;

  UserAddressUseCases({
    required UserAddressRepository userAddressRepository,
  }) : _userAddressRepository = userAddressRepository;

  /// Get the user's address
  Future<Result<UserAddress, DomainException>> getUserAddress() {
    return _userAddressRepository.getUserAddress();
  }

  /// Get a specific address by ID
  Future<Result<UserAddress, DomainException>> getAddressById(
      String addressId) {
    return _userAddressRepository.getAddressById(addressId);
  }

  /// Create a new address
  Future<Result<UserAddress, DomainException>> createAddress(
      UserAddress address) {
    return _userAddressRepository.createAddress(address);
  }

  /// Update an existing address
  Future<Result<UserAddress, DomainException>> updateAddress(
      UserAddress address) {
    return _userAddressRepository.updateAddress(address);
  }
}
