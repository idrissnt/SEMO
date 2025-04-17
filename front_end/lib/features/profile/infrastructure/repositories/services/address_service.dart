import 'package:semo/core/domain/services/api_client.dart';
import 'package:semo/core/infrastructure/api/api_routes.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/profile/infrastructure/models/profile_model.dart';
import 'package:semo/features/profile/domain/entities/profile_entity.dart';

/// Handles address-related operations like getting, creating, and updating addresses
class AddressService {
  final ApiClient _apiClient;
  final AppLogger _logger;

  AddressService({
    required ApiClient apiClient,
    required AppLogger logger,
  }) : _apiClient = apiClient,
       _logger = logger;

  /// Retrieves all addresses for the authenticated user
  Future<List<UserAddress>> getUserAddresses() async {
    try {
      _logger.debug('Fetching user addresses');

      // The ApiClient automatically handles authentication headers and token refresh
      final List<dynamic> addressesData = await _apiClient.get<List<dynamic>>(
        UserAddressApiRoutes.getUserAddresses,
      );

      // Convert the response data to domain entities
      final addresses = addressesData
          .map((addressData) =>
              UserAddressModel.fromJson(addressData).toEntity())
          .toList();

      _logger.debug('Successfully retrieved ${addresses.length} addresses');
      return addresses;
    } catch (e) {
      _logger.error('Error getting user addresses', error: e);
      rethrow;
    }
  }

  /// Retrieves a specific address by ID
  Future<UserAddress> getAddressById(String addressId) async {
    try {
      _logger.debug('Fetching address with ID: $addressId');

      // The ApiClient automatically handles authentication headers and token refresh
      final addressData = await _apiClient.get<Map<String, dynamic>>(
        UserAddressApiRoutes.getAddressById(addressId),
      );

      // Convert the response data to a domain entity
      final address = UserAddressModel.fromJson(addressData).toEntity();
      _logger.debug('Successfully retrieved address');

      return address;
    } catch (e) {
      _logger.error('Error getting address by ID', error: e);
      rethrow;
    }
  }

  /// Creates a new address for the authenticated user
  Future<UserAddress> createAddress(UserAddress address) async {
    try {
      _logger.debug('Creating new address');

      // Convert the domain entity to a model for serialization
      final addressModel = UserAddressModel.fromEntity(address);

      // The ApiClient automatically handles authentication headers and token refresh
      final createdAddressData = await _apiClient.post<Map<String, dynamic>>(
        UserAddressApiRoutes.createAddress,
        data: addressModel.toJson(),
      );

      // Convert the response data to a domain entity
      final createdAddress =
          UserAddressModel.fromJson(createdAddressData).toEntity();
      _logger.debug('Successfully created address');

      return createdAddress;
    } catch (e) {
      _logger.error('Error creating address', error: e);
      rethrow;
    }
  }

  /// Updates an existing address
  Future<UserAddress> updateAddress(UserAddress address) async {
    try {
      _logger.debug('Updating address with ID: ${address.addressId}');

      // Convert the domain entity to a model for serialization
      final addressModel = UserAddressModel.fromEntity(address);

      // The ApiClient automatically handles authentication headers and token refresh
      final updatedAddressData = await _apiClient.put<Map<String, dynamic>>(
        UserAddressApiRoutes.getAddressById(address.addressId),
        data: addressModel.toJson(),
      );

      // Convert the response data to a domain entity
      final updatedAddress =
          UserAddressModel.fromJson(updatedAddressData).toEntity();
      _logger.debug('Successfully updated address');

      return updatedAddress;
    } catch (e) {
      _logger.error('Error updating address', error: e);
      rethrow;
    }
  }

  /// Deletes an address by ID
  Future<bool> deleteAddress(String addressId) async {
    try {
      _logger.debug('Deleting address with ID: $addressId');

      // The ApiClient automatically handles authentication headers and token refresh
      await _apiClient.delete<void>(
        UserAddressApiRoutes.deleteAddressById(addressId),
      );

      _logger.debug('Successfully deleted address');
      return true;
    } catch (e) {
      _logger.error('Error deleting address', error: e);
      rethrow;
    }
  }
}
