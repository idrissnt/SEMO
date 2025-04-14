import 'package:semo/core/utils/result.dart';
import 'package:semo/features/profile/domain/exceptions/profile_exceptions.dart';
import 'package:semo/features/profile/domain/entities/profile_entity.dart';

abstract class UserAddressRepository {
  /// Retrieves address for the authenticated user
  Future<Result<UserAddress, DomainException>> getUserAddress();

  /// Retrieves a specific address by ID
  Future<Result<UserAddress, DomainException>> getAddressById(String addressId);

  /// Creates a new address for the authenticated user
  Future<Result<UserAddress, DomainException>> createAddress(
      UserAddress address);

  /// Updates an existing address
  Future<Result<UserAddress, DomainException>> updateAddress(
      UserAddress address);
}
