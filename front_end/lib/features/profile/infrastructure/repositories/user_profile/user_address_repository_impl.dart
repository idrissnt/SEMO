import 'package:semo/core/domain/services/api_client.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/utils/result.dart';
import 'package:semo/features/profile/domain/repositories/user_profile/user_address_repository.dart';
import 'package:semo/features/profile/infrastructure/repositories/user_profile/services/address_service.dart';
import 'package:semo/features/profile/domain/entities/profile_entity.dart';
import 'package:semo/features/profile/domain/exceptions/profile/profile_exceptions.dart';

/// Implementation of the UserAddressRepository interface that delegates to AddressService
class UserAddressRepositoryImpl implements UserAddressRepository {
  final AddressService _addressService;
  final AppLogger _logger;

  UserAddressRepositoryImpl({
    required ApiClient apiClient,
    required AppLogger logger,
  })  : _logger = logger,
        _addressService = AddressService(
          apiClient: apiClient,
          logger: logger,
        );

  @override
  Future<Result<UserAddress, UserAddressException>> getUserAddress() async {
    try {
      final addresses = await _addressService.getUserAddresses();
      if (addresses.isEmpty) {
        return Result.failure(
            UserAddressException('No addresses found for this user'));
      }
      return Result.success(addresses.first);
    } catch (e, stackTrace) {
      _logger.error('Error in getUserAddress',
          error: e, stackTrace: stackTrace);
      return Result.failure(UserAddressException(e.toString()));
    }
  }

  @override
  Future<Result<UserAddress, UserAddressException>> getAddressById(
      String addressId) async {
    try {
      final address = await _addressService.getAddressById(addressId);
      return Result.success(address);
    } catch (e, stackTrace) {
      _logger.error('Error in getAddressById',
          error: e, stackTrace: stackTrace);
      return Result.failure(UserAddressException(e.toString()));
    }
  }

  @override
  Future<Result<UserAddress, UserAddressException>> createAddress(
      UserAddress address) async {
    try {
      final createdAddress = await _addressService.createAddress(address);
      return Result.success(createdAddress);
    } catch (e, stackTrace) {
      _logger.error('Error in createAddress', error: e, stackTrace: stackTrace);
      return Result.failure(UserAddressException(e.toString()));
    }
  }

  @override
  Future<Result<UserAddress, UserAddressException>> updateAddress(
      UserAddress address) async {
    try {
      final updatedAddress = await _addressService.updateAddress(address);
      return Result.success(updatedAddress);
    } catch (e, stackTrace) {
      _logger.error('Error in updateAddress', error: e, stackTrace: stackTrace);
      return Result.failure(UserAddressException(e.toString()));
    }
  }
}
