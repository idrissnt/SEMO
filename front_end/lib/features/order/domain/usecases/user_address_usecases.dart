import 'package:semo/core/utils/result.dart';
import 'package:semo/features/profile/domain/entities/profile_entity.dart';
import 'package:semo/features/profile/domain/exceptions/profile/profile_exceptions.dart';
import 'package:semo/features/profile/domain/repositories/user_profile/user_address_repository.dart';

/// Use cases for user address operations in the Order feature
class OrderUserAddressUseCases {
  final UserAddressRepository _userAddressRepository;

  OrderUserAddressUseCases({
    required UserAddressRepository userAddressRepository,
  }) : _userAddressRepository = userAddressRepository;

  /// Get the user's address
  Future<Result<UserAddress, UserAddressException>> getUserAddress() {
    return _userAddressRepository.getUserAddress();
  }

  /// Create a new address
  Future<Result<UserAddress, UserAddressException>> createAddress(
      UserAddress address) {
    return _userAddressRepository.createAddress(address);
  }

  /// Update an existing address
  Future<Result<UserAddress, UserAddressException>> updateAddress(
      UserAddress address) {
    return _userAddressRepository.updateAddress(address);
  }
}
