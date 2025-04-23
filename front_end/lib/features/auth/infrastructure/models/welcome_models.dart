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
  final String cardTitleOne;
  final String cardTitleTwo;
  final String storeTitle;
  final String storeLogoOneUrl;
  final String storeLogoTwoUrl;
  final String storeLogoThreeUrl;

  const StoreAssetModel({
    required this.id,
    required this.cardTitleOne,
    required this.cardTitleTwo,
    required this.storeTitle,
    required this.storeLogoOneUrl,
    required this.storeLogoTwoUrl,
    required this.storeLogoThreeUrl,
  });

  /// Creates a model from JSON data
  factory StoreAssetModel.fromJson(Map<String, dynamic> json) {
    return StoreAssetModel(
      id: json['id'] ?? '',
      cardTitleOne: json['card_title_one'] ?? '',
      cardTitleTwo: json['card_title_two'] ?? '',
      storeTitle: json['store_title'] ?? '',
      storeLogoOneUrl: json['store_logo_one_url'] ?? '',
      storeLogoTwoUrl: json['store_logo_two_url'] ?? '',
      storeLogoThreeUrl: json['store_logo_three_url'] ?? '',
    );
  }

  /// Converts model to domain entity
  StoreAsset toDomain() {
    return StoreAsset(
      id: id,
      cardTitleOne: cardTitleOne,
      cardTitleTwo: cardTitleTwo,
      storeTitle: storeTitle,
      storeLogoOneUrl: storeLogoOneUrl,
      storeLogoTwoUrl: storeLogoTwoUrl,
      storeLogoThreeUrl: storeLogoThreeUrl,
    );
  }
}

/// Data transfer object for task asset from API
class TaskAssetModel {
  final String id;
  final String title;
  final String taskImage;
  final String taskerProfileImageUrl;
  final String taskerProfileTitle;

  const TaskAssetModel({
    required this.id,
    required this.title,
    required this.taskImage,
    required this.taskerProfileImageUrl,
    required this.taskerProfileTitle,
  });

  /// Creates a model from JSON data
  factory TaskAssetModel.fromJson(Map<String, dynamic> json) {
    return TaskAssetModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      taskImage: json['task_image_url'] ?? '',
      taskerProfileImageUrl: json['tasker_profile_image_url'] ?? '',
      taskerProfileTitle: json['tasker_profile_title'] ?? '',
    );
  }

  /// Converts model to domain entity
  TaskAsset toDomain() {
    return TaskAsset(
      id: id,
      title: title,
      taskImage: taskImage,
      taskerProfileImageUrl: taskerProfileImageUrl,
      taskerProfileTitle: taskerProfileTitle,
    );
  }
}
