// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:hive/hive.dart';
import '../../core/config/app_config.dart';
import '../../domain/entities/store.dart';
import '../../core/utils/logger.dart';

part 'store_model.g.dart';

@HiveType(typeId: 0)
class StoreModel extends Store {
  static final AppLogger _logger = AppLogger();

  @override
  @HiveField(0)
  // ignore: overridden_fields
  final String? logoUrl;

  @HiveField(1)
  final DateTime cachedAt;

  StoreModel({
    String? id,
    required String name,
    String? description,
    double? rating,
    bool? isOpen,
    double? distance,
    int? estimatedTime,
    String? address,
    List<Map<String, dynamic>>? categories,
    List<Map<String, dynamic>>? products,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalProducts,
    bool? isBigStore,
    String? deliveryType,
    bool? isCurrentlyOpen,
    double? deliveryFee,
    double? minimumOrder,
    double? freeDeliveryThreshold,
    int? totalReviews,
    this.logoUrl,
    DateTime? cachedAt,
  })  : cachedAt = cachedAt ?? DateTime.now(),
        super(
          id: id ?? '',
          name: name ?? 'Unnamed Store',
          description: description ?? '',
          rating: rating ?? 0.0,
          isOpen: isOpen ?? false,
          distance: distance ?? 0.0,
          estimatedTime: estimatedTime ?? 0,
          address: address ?? '',
          categories: categories ?? [],
          products: products ?? [],
          createdAt: createdAt,
          updatedAt: updatedAt,
          totalProducts: totalProducts ?? 0,
          isBigStore: isBigStore ?? false,
          deliveryType: deliveryType ?? '',
          isCurrentlyOpen: isCurrentlyOpen ?? false,
          deliveryFee: deliveryFee ?? 0.0,
          minimumOrder: minimumOrder ?? 0.0,
          freeDeliveryThreshold: freeDeliveryThreshold ?? 0.0,
          totalReviews: totalReviews ?? 0,
        );

  static dynamic parseNumeric(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    try {
      return num.tryParse(value.toString());
    } catch (e) {
      _logger.warning('Failed to parse numeric value: $value');
      return null;
    }
  }

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    try {
      String? logoUrl = json['logo_url']?.toString();
      if (logoUrl != null && !logoUrl.startsWith('http')) {
        logoUrl = '${AppConfig.mediaBaseUrl}$logoUrl';
      }

      return StoreModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
        rating: parseNumeric(json['rating'])?.toDouble(),
        isOpen: (json['is_open']?.toString().toLowerCase() == 'true'),
        distance: parseNumeric(json['distance'])?.toDouble(),
        estimatedTime: parseNumeric(json['estimated_time'])?.toInt(),
        address: json['address']?.toString(),
        categories: (json['categories'] as List?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList(),
        products: (json['products'] as List?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList(),
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
        updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
        totalProducts: parseNumeric(json['total_products'])?.toInt(),
        isBigStore: (json['is_big_store']?.toString().toLowerCase() == 'true'),
        deliveryType: json['delivery_type']?.toString(),
        isCurrentlyOpen:
            (json['is_currently_open']?.toString().toLowerCase() == 'true'),
        deliveryFee: parseNumeric(json['delivery_fee'])?.toDouble(),
        minimumOrder: parseNumeric(json['minimum_order'])?.toDouble(),
        freeDeliveryThreshold:
            parseNumeric(json['free_delivery_threshold'])?.toDouble(),
        logoUrl: logoUrl,
        cachedAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      _logger.error(
        'Error parsing StoreModel from JSON',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  factory StoreModel.fromEntity(Store store) {
    _logger.debug('Converting Store entity to StoreModel: ${store.name}');

    if (store is StoreModel) {
      return store;
    }

    return StoreModel(
      id: store.id,
      name: store.name,
      description: store.description,
      rating: store.rating,
      isOpen: store.isOpen,
      distance: store.distance,
      estimatedTime: store.estimatedTime,
      address: store.address,
      categories: store.categories,
      products: store.products,
      createdAt: store.createdAt,
      updatedAt: store.updatedAt,
      totalProducts: store.totalProducts,
      isBigStore: store.isBigStore,
      deliveryType: store.deliveryType,
      isCurrentlyOpen: store.isCurrentlyOpen,
      deliveryFee: store.deliveryFee,
      minimumOrder: store.minimumOrder,
      freeDeliveryThreshold: store.freeDeliveryThreshold,
      totalReviews: store.totalReviews,
      logoUrl: store is StoreModel ? store.logoUrl : null,
      cachedAt: DateTime.now(),
    );
  }

  factory StoreModel.toModel(Store store) {
    _logger.debug('Converting Store to StoreModel: ${store.name}');
    return StoreModel(
      id: store.id,
      name: store.name,
      description: store.description,
      rating: store.rating,
      isOpen: store.isOpen,
      distance: store.distance,
      estimatedTime: store.estimatedTime,
      address: store.address,
      categories: store.categories,
      products: store.products,
      createdAt: store.createdAt,
      updatedAt: store.updatedAt,
      totalProducts: store.totalProducts,
      isBigStore: store.isBigStore,
      deliveryType: store.deliveryType,
      isCurrentlyOpen: store.isCurrentlyOpen,
      deliveryFee: store.deliveryFee,
      minimumOrder: store.minimumOrder,
      freeDeliveryThreshold: store.freeDeliveryThreshold,
      totalReviews: store.totalReviews,
      logoUrl: store is StoreModel ? store.logoUrl : null,
      cachedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Basic store information
      'id': id,
      'name': name,
      'description': description,

      // Image URLs
      'logo_url': logoUrl,

      // Ratings and status
      'rating': rating,
      'is_open': isOpen,
      'total_reviews': totalReviews,

      // Location and distance
      'distance': distance,
      'estimated_time': estimatedTime,
      'address': address,

      // Additional store details
      'total_products': totalProducts,
      'is_big_store': isBigStore,
      'delivery_type': deliveryType,
      'is_currently_open': isCurrentlyOpen,
      'delivery_fee': deliveryFee,
      'minimum_order': minimumOrder,
      'free_delivery_threshold': freeDeliveryThreshold,

      // Nested data
      'categories': categories,
      'products': products,

      // Timestamps
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'cached_at': cachedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'StoreModel(id: $id, name: $name, rating: $rating, isOpen: $isOpen)';
  }
}
