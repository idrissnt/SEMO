import 'package:semo/core/utils/result.dart';
import 'package:semo/features/profile/domain/exceptions/profile_exceptions.dart';
import 'package:semo/features/profile/domain/entities/profile_entity.dart';

abstract class UserAddressRepository {
  /// Retrieves address for the authenticated user
  Future<Result<UserAddress, UserAddressException>> getUserAddress();

  /// Retrieves a specific address by ID
  Future<Result<UserAddress, UserAddressException>> getAddressById(
      String addressId);

  /// Creates a new address for the authenticated user
  Future<Result<UserAddress, UserAddressException>> createAddress(
      UserAddress address);

  /// Updates an existing address
  Future<Result<UserAddress, UserAddressException>> updateAddress(
      UserAddress address);
}
