import 'package:equatable/equatable.dart';

class Store extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final double? rating;
  final bool? isOpen;
  final double? distance;
  final int? estimatedTime;
  final String? address;
  final List<Map<String, dynamic>>? categories;
  final List<Map<String, dynamic>>? products;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // New fields from backend
  final int? totalProducts;
  final bool? isBigStore;
  final String? deliveryType;
  final bool? isCurrentlyOpen;
  final double? deliveryFee;
  final double? minimumOrder;
  final double? freeDeliveryThreshold;
  final int? totalReviews;

  const Store({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.rating,
    this.isOpen,
    this.distance,
    this.estimatedTime,
    this.address,
    this.categories,
    this.products,
    this.createdAt,
    this.updatedAt,
    // New fields
    this.totalProducts,
    this.isBigStore,
    this.deliveryType,
    this.isCurrentlyOpen,
    this.deliveryFee,
    this.minimumOrder,
    this.freeDeliveryThreshold,
    this.totalReviews,
  });

  @override
  List<Object?> get props => [
        id, name, description, logoUrl, rating,
        isOpen, distance, estimatedTime, address,
        categories, products, createdAt, updatedAt,
        // New fields
        totalProducts, isBigStore, deliveryType,
        isCurrentlyOpen, deliveryFee, minimumOrder,
        freeDeliveryThreshold, totalReviews,
      ];
}
