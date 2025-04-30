import 'package:semo/features/profile/domain/entities/verification_response_entity.dart';

/// Data transfer object for verification response from API
class VerificationResponseModel {
  final String message;
  final String requestId;

  const VerificationResponseModel({
    required this.message,
    required this.requestId,
  });

  /// Creates a model from JSON data
  factory VerificationResponseModel.fromJson(Map<String, dynamic> json) {
    return VerificationResponseModel(
      message: json['message'] ?? '',
      requestId: json['request_id'] ?? '',
    );
  }

  /// Converts model to domain entity
  VerificationResponse toDomain() {
    return VerificationResponse(
      message: message,
      requestId: requestId,
    );
  }
}
