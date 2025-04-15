import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:semo/core/infrastructure/services/token_service.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/utils/result.dart';
import 'package:semo/features/profile/infrastructure/repositories/services/address_service.dart';
import 'package:semo/features/profile/domain/entities/profile_entity.dart';
import 'package:semo/features/profile/domain/exceptions/profile_exceptions.dart';
import 'package:semo/features/profile/domain/repositories/profile_repository.dart';

/// Implementation of the UserAddressRepository interface that delegates to AddressService
class UserAddressRepositoryImpl implements UserAddressRepository {
  final AddressService _addressService;
  final AppLogger _logger = AppLogger();

  UserAddressRepositoryImpl({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  }) : _addressService = AddressService(
          dio: dio,
          tokenService: TokenService(
            dio: dio,
            storage: secureStorage,
          ),
        );

  @override
  Future<Result<UserAddress, DomainException>> getUserAddress() async {
    try {
      final addresses = await _addressService.getUserAddresses();
      if (addresses.isEmpty) {
        return Result.failure(
            UserAddressException('No addresses found for this user'));
      }
      return Result.success(addresses.first);
    } on DioException catch (e) {
      _logger.error('DioException in getUserAddress', error: e);
      return Result.failure(_handleDioException(e));
    } catch (e, stackTrace) {
      _logger.error('Error in getUserAddress',
          error: e, stackTrace: stackTrace);
      return Result.failure(UserAddressException(e.toString()));
    }
  }

  @override
  Future<Result<UserAddress, DomainException>> getAddressById(
      String addressId) async {
    try {
      final address = await _addressService.getAddressById(addressId);
      return Result.success(address);
    } on DioException catch (e) {
      _logger.error('DioException in getAddressById', error: e);
      return Result.failure(_handleDioException(e));
    } catch (e, stackTrace) {
      _logger.error('Error in getAddressById',
          error: e, stackTrace: stackTrace);
      return Result.failure(UserAddressException(e.toString()));
    }
  }

  @override
  Future<Result<UserAddress, DomainException>> createAddress(
      UserAddress address) async {
    try {
      final createdAddress = await _addressService.createAddress(address);
      return Result.success(createdAddress);
    } on DioException catch (e) {
      _logger.error('DioException in createAddress', error: e);
      return Result.failure(_handleDioException(e));
    } catch (e, stackTrace) {
      _logger.error('Error in createAddress', error: e, stackTrace: stackTrace);
      return Result.failure(UserAddressException(e.toString()));
    }
  }

  @override
  Future<Result<UserAddress, DomainException>> updateAddress(
      UserAddress address) async {
    try {
      final updatedAddress = await _addressService.updateAddress(address);
      return Result.success(updatedAddress);
    } on DioException catch (e) {
      _logger.error('DioException in updateAddress', error: e);
      return Result.failure(_handleDioException(e));
    } catch (e, stackTrace) {
      _logger.error('Error in updateAddress', error: e, stackTrace: stackTrace);
      return Result.failure(UserAddressException(e.toString()));
    }
  }

  /// Helper method to handle DioExceptions and convert them to domain exceptions
  DomainException _handleDioException(DioException e) {
    if (e.response != null) {
      switch (e.response!.statusCode) {
        case 401:
          return AuthenticationException('Authentication required');
        case 403:
          return AuthorizationException(
              'Not authorized to perform this action');
        case 404:
          return UserAddressException('Address not found');
        case 400:
          final errorMessage = e.response!.data is Map
              ? e.response!.data['error'] ?? 'Invalid request'
              : 'Invalid request';
          return UserAddressException(errorMessage);
        default:
          return UserAddressException(
              'Server error: ${e.response!.statusCode}');
      }
    }
    return UserAddressException('Network error: ${e.message}');
  }
}
