import '../../domain/entities/store.dart';

/// Data model for StoreBrand that handles serialization/deserialization
class StoreBrandModel {
  final String id;
  final String name;
  final String slug;
  final String type;
  final String imageLogo;
  final String imageBanner;

  StoreBrandModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.type,
    required this.imageLogo,
    required this.imageBanner,
  });

  /// Creates a StoreBrandModel from JSON data
  factory StoreBrandModel.fromJson(Map<String, dynamic> json) {
    return StoreBrandModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      type: json['type'] ?? '',
      imageLogo: json['image_logo'] ?? '',
      imageBanner: json['image_banner'] ?? '',
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'type': type,
      'image_logo': imageLogo,
      'image_banner': imageBanner,
    };
  }

  /// Creates a StoreBrandModel from a domain entity
  factory StoreBrandModel.fromEntity(StoreBrand entity) {
    return StoreBrandModel(
      id: entity.id,
      name: entity.name,
      slug: entity.slug,
      type: entity.type,
      imageLogo: entity.imageLogo,
      imageBanner: entity.imageBanner,
    );
  }

  /// Converts this model to a domain entity
  StoreBrand toEntity() {
    return StoreBrand(
      id: id,
      name: name,
      slug: slug,
      type: type,
      imageLogo: imageLogo,
      imageBanner: imageBanner,
    );
  }
}

/// Data model for NearbyStore that handles serialization/deserialization
class NearbyStoreModel {
  final StoreBrandModel storeBrand;
  final double distance;
  final String address;
  final double latitude;
  final double longitude;

  NearbyStoreModel({
    required this.storeBrand,
    required this.distance,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  /// Creates a NearbyStoreModel from JSON data
  factory NearbyStoreModel.fromJson(Map<String, dynamic> json) {
    // Handle the new StoreBrandLocation format from backend
    // The JSON now contains direct store brand fields and location data
    final storeBrand = StoreBrandModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      type: json['type'] ?? '',
      imageLogo: json['image_logo'] ?? '',
      imageBanner: json['image_banner'] ?? '',
    );
    
    // Extract distance_km from the response
    final distance = (json['distance_km'] ?? 0.0).toDouble();
    
    // Extract address
    final address = json['address'] ?? '';
    
    // Extract coordinates (which may be a nested object)
    double latitude = 0.0;
    double longitude = 0.0;
    
    if (json['coordinates'] != null) {
      // Handle nested coordinates object
      final coordinates = json['coordinates'];
      latitude = (coordinates['latitude'] ?? 0.0).toDouble();
      longitude = (coordinates['longitude'] ?? 0.0).toDouble();
    }
    
    return NearbyStoreModel(
      storeBrand: storeBrand,
      distance: distance,
      address: address,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'store_brand': storeBrand.toJson(),
      'distance': distance,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Creates a NearbyStoreModel from a domain entity
  factory NearbyStoreModel.fromEntity(NearbyStore entity) {
    return NearbyStoreModel(
      storeBrand: StoreBrandModel.fromEntity(entity.storeBrand),
      distance: entity.distance,
      address: entity.address,
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }

  /// Converts this model to a domain entity
  NearbyStore toEntity() {
    return NearbyStore(
      storeBrand: storeBrand.toEntity(),
      distance: distance,
      address: address,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
