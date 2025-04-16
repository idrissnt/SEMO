import 'dart:convert';

/// Model for API error responses
class ErrorResponseModel {
  final String? error;
  final String? code;
  final String? requestId;
  final Map<String, dynamic>? details;

  ErrorResponseModel({
    this.error,
    this.code,
    this.requestId,
    this.details,
  });

  /// Creates an ErrorResponseModel from a JSON response
  factory ErrorResponseModel.fromJson(Map<String, dynamic> json) {
    return ErrorResponseModel(
      error: json['error'],
      code: json['code'],
      requestId: json['request_id'],
      details: json['details'],
    );
  }

  /// Attempts to parse an error response from a DioException
  static ErrorResponseModel? fromDioError(dynamic error) {
    try {
      // Try to extract the response data
      final responseData = error.response?.data;
      
      if (responseData == null) {
        return null;
      }
      
      // If it's already a Map, use it directly
      if (responseData is Map<String, dynamic>) {
        return ErrorResponseModel.fromJson(responseData);
      }
      
      // If it's a string, try to parse it as JSON
      if (responseData is String) {
        try {
          final jsonData = json.decode(responseData);
          if (jsonData is Map<String, dynamic>) {
            return ErrorResponseModel.fromJson(jsonData);
          }
        } catch (_) {
          // Not valid JSON
        }
      }
      
      return null;
    } catch (_) {
      return null;
    }
  }
}
