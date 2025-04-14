import 'package:semo/shared/entities/address_entity.dart';
import 'package:semo/core/utils/logger.dart';

/// Data model for user address that handles serialization/deserialization
class UserAddressModel {
  static final AppLogger _logger = AppLogger();

  final String addressId;
  final String userId;
  final int streetNumber;
  final String streetName;
  final String city;
  final int zipCode;
  final String country;

  UserAddressModel({
    required this.addressId,
    required this.userId,
    required this.streetNumber,
    required this.streetName,
    required this.city,
    required this.zipCode,
    required this.country,
  });

  /// Creates a UserAddressModel from JSON data
  factory UserAddressModel.fromJson(Map<String, dynamic> json) {
    _logger.debug('Creating UserAddressModel from JSON: $json');
    return UserAddressModel(
      addressId: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      streetNumber: json['street_number']?.toInt() ?? 0,
      streetName: json['street_name']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      zipCode: json['zip_code']?.toInt() ?? 0,
      country: json['country']?.toString() ?? '',
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'street_number': streetNumber,
      'street_name': streetName,
      'city': city,
      'zip_code': zipCode,
      'country': country,
    };
  }

  /// Creates a UserAddressModel from a domain entity
  factory UserAddressModel.fromEntity(UserAddress address) {
    return UserAddressModel(
      addressId: address.addressId,
      userId: address.userId,
      streetNumber: address.streetNumber,
      streetName: address.streetName,
      city: address.city,
      zipCode: address.zipCode,
      country: address.country,
    );
  }

  /// Converts this model to a domain entity
  UserAddress toEntity() {
    return UserAddress(
      addressId: addressId,
      userId: userId,
      streetNumber: streetNumber,
      streetName: streetName,
      city: city,
      zipCode: zipCode,
      country: country,
    );
  }

  @override
  String toString() {
    return '$streetNumber $streetName, $city, $zipCode, $country';
  }
}
