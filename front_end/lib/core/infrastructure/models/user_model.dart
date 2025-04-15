import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/domain/entities/user_entity.dart';

final AppLogger _logger = AppLogger();

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String? lastName;
  final String? profilePhotoUrl;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    this.lastName,
    this.profilePhotoUrl,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    _logger.debug('Creating UserModel from JSON: $json');

    // Check if user data is nested
    final userData = json['user'] ?? json;

    return UserModel(
      id: userData['id']?.toString() ?? '',
      email: userData['email'] ?? '',
      firstName: userData['first_name'] ?? '',
      lastName: userData['last_name'] ?? '',
      profilePhotoUrl: userData['profile_image']?.toString(),
      createdAt: userData['created_at'] != null
          ? DateTime.parse(userData['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'profile_image': profilePhotoUrl,
        'created_at': createdAt?.toIso8601String(),
      };

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      profilePhotoUrl: user.profilePhotoUrl,
      createdAt: user.createdAt,
    );
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      profilePhotoUrl: profilePhotoUrl,
      createdAt: createdAt,
    );
  }

  @override
  String toString() => 'UserModel(email: $email, firstName: $firstName)';
}
