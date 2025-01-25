import '../../domain/entities/store.dart';

class StoreModel extends Store {
  StoreModel({
    required int id,
    required String name,
    required String imageUrl,
    required double rating,
    required bool isOpen,
    double? distance,
    int? estimatedTime,
    required String address,
  }) : super(
          id: id,
          name: name,
          imageUrl: imageUrl,
          rating: rating,
          isOpen: isOpen,
          distance: distance,
          estimatedTime: estimatedTime,
          address: address,
        );

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Store',
      imageUrl: json['image_url'] ?? '',
      rating: double.parse(json['rating']?.toString() ?? '0.0'),
      isOpen: true, // Since it's not in the API response, default to true
      distance: null, // Not provided by API
      estimatedTime: null, // Not provided by API
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'rating': rating,
      'is_open': isOpen,
      'distance': distance,
      'estimated_time': estimatedTime,
      'address': address,
    };
  }
}
