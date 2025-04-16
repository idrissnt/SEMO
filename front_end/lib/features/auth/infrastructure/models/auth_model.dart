export 'package:semo/core/infrastructure/models/user_model.dart';

import 'package:semo/features/auth/domain/entities/auth_entity.dart';

/// Model class for authentication tokens response from the backend
class AuthTokensModel {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String email;
  final String firstName;
  final String? lastName;
  final String? message;
  final String? code;

  AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.email,
    required this.firstName,
    this.lastName,
    this.message,
    this.code,
  });

  /// Creates an AuthTokensModel from JSON response
  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'],
      message: json['message'],
      code: json['code'],
    );
  }

  /// Converts this model to a domain entity
  AuthTokens toEntity() {
    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      email: email,
      firstName: firstName,
      lastName: lastName,
    );
  }
}
