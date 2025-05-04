import 'package:semo/features/profile/domain/entities/verification_response_entity.dart';

/// Data transfer object for verification response from API
class VerificationResponseModel {
  final String message;
  final String requestId;
  final bool success;

  const VerificationResponseModel({
    required this.message,
    required this.requestId,
    this.success = true,
  });

  /// Creates a model from JSON data
  factory VerificationResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle the new envelope format
    if (json.containsKey('success') && json.containsKey('data')) {
      // New format with envelope
      final data = json['data'] as Map<String, dynamic>;
      return VerificationResponseModel(
        message: data['message'] ?? '',
        requestId: data['request_id'] ?? '',
        success: json['success'] ?? true,
      );
    } else {
      // Fallback for old format or direct data
      return VerificationResponseModel(
        message: json['message'] ?? '',
        requestId: json['request_id'] ?? '',
      );
    }
  }

  /// Converts model to domain entity
  VerificationResponse toDomain() {
    return VerificationResponse(
      message: message,
      requestId: requestId,
      success: success,
    );
  }
}
