import '../../../domain/entities/user_auth/user.dart';
import '../../../core/utils/logger.dart';

class UserModel extends User {
  static final AppLogger _logger = AppLogger();

  UserModel({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    String? profileImage,
    DateTime? createdAt,
    String? address,
  }) : super(
          id: id,
          email: email,
          firstName: firstName,
          lastName: lastName,
          profileImage: profileImage,
          createdAt: createdAt ?? DateTime.now(),
          address: address,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    _logger.debug('Creating UserModel from JSON: $json');

    // Check if user data is nested
    final userData = json['user'] ?? json;

    return UserModel(
      id: userData['id']?.toString() ?? '',
      email: userData['email'] ?? '',
      firstName: userData['first_name'] ?? '',
      lastName: userData['last_name'] ?? '',
      profileImage: userData['profile_image'],
      createdAt: userData['created_at'] != null
          ? DateTime.parse(userData['created_at'])
          : DateTime.now(),
      address: userData['address'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'profile_image': profileImage,
        'created_at': createdAt.toIso8601String(),
        'address': address,
      };
}
