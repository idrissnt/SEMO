import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';

/// Domain entity representing a store brand
class StoreBrand {
  final String id;
  final String name;
  final String slug;
  final String type;
  final String imageLogo;
  final String imageBanner;
  final List<StoreAisle>? aisles;

  StoreBrand({
    required this.id,
    required this.name,
    required this.slug,
    required this.type,
    required this.imageLogo,
    required this.imageBanner,
    this.aisles,
  });

  @override
  String toString() => name;
}

/// Domain entity representing a store with location information
class NearbyStore {
  final StoreBrand storeBrand;
  final double distance; // in kilometers
  final String address;
  final double latitude;
  final double longitude;

  NearbyStore({
    required this.storeBrand,
    required this.distance,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}
