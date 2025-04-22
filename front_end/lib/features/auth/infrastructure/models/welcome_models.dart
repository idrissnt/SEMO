import 'package:semo/features/auth/domain/entities/welcom_entity.dart';

/// Data transfer object for company asset from API
class CompanyAssetModel {
  final String id;
  final String name;
  final String logoUrl;

  const CompanyAssetModel({
    required this.id,
    required this.name,
    required this.logoUrl,
  });

  /// Creates a model from JSON data
  factory CompanyAssetModel.fromJson(Map<String, dynamic> json) {
    return CompanyAssetModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logoUrl: json['logo_url'] ?? '',
    );
  }

  /// Converts model to domain entity
  CompanyAsset toDomain() {
    return CompanyAsset(
      id: id,
      logoUrl: logoUrl,
    );
  }
}

/// Data transfer object for store asset from API
class StoreAssetModel {
  final String id;
  final String titleOne;
  final String titleTwo;
  final String firstLogoUrl;
  final String secondLogoUrl;
  final String thirdLogoUrl;

  const StoreAssetModel({
    required this.id,
    required this.titleOne,
    required this.titleTwo,
    required this.firstLogoUrl,
    required this.secondLogoUrl,
    required this.thirdLogoUrl,
  });

  /// Creates a model from JSON data
  factory StoreAssetModel.fromJson(Map<String, dynamic> json) {
    return StoreAssetModel(
      id: json['id'] ?? '',
      titleOne: json['title_one'] ?? '',
      titleTwo: json['title_two'] ?? '',
      firstLogoUrl: json['first_logo_url'] ?? '',
      secondLogoUrl: json['second_logo_url'] ?? '',
      thirdLogoUrl: json['third_logo_url'] ?? '',
    );
  }

  /// Converts model to domain entity
  StoreAsset toDomain() {
    return StoreAsset(
      id: id,
      titleOne: titleOne,
      titleTwo: titleTwo,
      firstLogoUrl: firstLogoUrl,
      secondLogoUrl: secondLogoUrl,
      thirdLogoUrl: thirdLogoUrl,
    );
  }
}

/// Data transfer object for task asset from API
class TaskAssetModel {
  final String id;
  final String titleOne;
  final String titleTwo;
  final String firstImage;
  final String secondImage;
  final String thirdImage;
  final String fourthImage;
  final String fifthImage;

  const TaskAssetModel({
    required this.id,
    required this.titleOne,
    required this.titleTwo,
    required this.firstImage,
    required this.secondImage,
    required this.thirdImage,
    required this.fourthImage,
    required this.fifthImage,
  });

  /// Creates a model from JSON data
  factory TaskAssetModel.fromJson(Map<String, dynamic> json) {
    return TaskAssetModel(
      id: json['id'] ?? '',
      titleOne: json['title_one'] ?? '',
      titleTwo: json['title_two'] ?? '',
      firstImage: json['first_image_url'] ?? '',
      secondImage: json['second_image_url'] ?? '',
      thirdImage: json['third_image_url'] ?? '',
      fourthImage: json['fourth_image_url'] ?? '',
      fifthImage: json['fifth_image_url'] ?? '',
    );
  }

  /// Converts model to domain entity
  TaskAsset toDomain() {
    return TaskAsset(
      id: id,
      titleOne: titleOne,
      titleTwo: titleTwo,
      firstImage: firstImage,
      secondImage: secondImage,
      thirdImage: thirdImage,
      fourthImage: fourthImage,
      fifthImage: fifthImage,
    );
  }
}
