import 'package:dio/dio.dart';
import 'package:semo/core/infrastructure/api/api_routes.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/infrastructure/services/token_service.dart';
import 'package:semo/features/profile/infrastructure/models/profile_model.dart';
import 'package:semo/features/profile/domain/entities/profile_entity.dart';

/// Handles address-related operations like getting, creating, and updating addresses
class AddressService {
  final Dio _dio;
  final TokenService _tokenService;
  final AppLogger _logger = AppLogger();

  AddressService({
    required Dio dio,
    required TokenService tokenService,
  })  : _dio = dio,
        _tokenService = tokenService;

  /// Retrieves all addresses for the authenticated user
  Future<List<UserAddress>> getUserAddresses() async {
    try {
      final token = await _tokenService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      final response = await _dio.get(
        UserAddressApiRoutes.getUserAddresses,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> addressesData = response.data;
        final addresses = addressesData
            .map((addressData) =>
                UserAddressModel.fromJson(addressData).toEntity())
            .toList();
        return addresses;
      } else {
        throw Exception('Failed to retrieve addresses: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logger.error('Error getting user addresses',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Retrieves a specific address by ID
  Future<UserAddress> getAddressById(String addressId) async {
    try {
      final token = await _tokenService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      final response = await _dio.get(
        UserAddressApiRoutes.getAddressById(addressId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final address = UserAddressModel.fromJson(response.data).toEntity();
        return address;
      } else {
        throw Exception('Failed to retrieve address: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logger.error('Error getting address by ID',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Creates a new address for the authenticated user
  Future<UserAddress> createAddress(UserAddress address) async {
    try {
      final token = await _tokenService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      final addressModel = UserAddressModel.fromEntity(address);
      final response = await _dio.post(
        UserAddressApiRoutes.createAddress,
        data: addressModel.toJson(),
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 201) {
        final createdAddress =
            UserAddressModel.fromJson(response.data).toEntity();
        return createdAddress;
      } else {
        throw Exception('Failed to create address: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logger.error('Error creating address', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Updates an existing address
  Future<UserAddress> updateAddress(UserAddress address) async {
    try {
      final token = await _tokenService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      final addressModel = UserAddressModel.fromEntity(address);
      final response = await _dio.put(
        UserAddressApiRoutes.updateAddressById(address.addressId),
        data: addressModel.toJson(),
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        final updatedAddress =
            UserAddressModel.fromJson(response.data).toEntity();
        return updatedAddress;
      } else {
        throw Exception('Failed to update address: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logger.error('Error updating address', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Deletes an address by ID
  Future<bool> deleteAddress(String addressId) async {
    try {
      final token = await _tokenService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      final response = await _dio.delete(
        UserAddressApiRoutes.deleteAddressById(addressId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 204;
    } catch (e, stackTrace) {
      _logger.error('Error deleting address', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
