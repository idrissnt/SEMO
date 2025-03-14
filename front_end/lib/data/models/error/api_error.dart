/// Represents a structured API error response
class ApiError {
  /// HTTP status code
  final int? statusCode;
  
  /// Error code from the API (if available)
  final String? errorCode;
  
  /// Error message
  final String message;
  
  /// Additional error details (field-specific errors)
  final Map<String, dynamic>? details;
  
  /// Original exception or error object
  final dynamic originalError;

  const ApiError({
    this.statusCode,
    this.errorCode,
    required this.message,
    this.details,
    required this.originalError,
  });

  /// Create an ApiError from a DioError or other exception
  factory ApiError.fromException(dynamic error) {
    // Default values
    int? statusCode;
    String? errorCode;
    String message = error.toString();
    Map<String, dynamic>? details;
    
    // Try to extract more information if it's a DioError
    if (error.toString().contains('DioError')) {
      try {
        // Extract status code if available
        final responseData = error.response?.data;
        
        if (responseData != null && responseData is Map<String, dynamic>) {
          // Extract status code
          statusCode = error.response?.statusCode;
          
          // Extract error code if available
          errorCode = responseData['code'] as String?;
          
          // Extract message
          if (responseData.containsKey('message')) {
            message = responseData['message'] as String;
          } else if (responseData.containsKey('detail')) {
            message = responseData['detail'] as String;
          }
          
          // Extract field-specific errors
          if (responseData.containsKey('errors')) {
            details = responseData['errors'] as Map<String, dynamic>?;
          }
        }
      } catch (e) {
        // If parsing fails, use the original error message
        message = 'Failed to parse error response: ${error.toString()}';
      }
    }
    
    return ApiError(
      statusCode: statusCode,
      errorCode: errorCode,
      message: message,
      details: details,
      originalError: error,
    );
  }

  /// Check if this error is related to authentication
  bool get isAuthError => 
      statusCode == 401 || 
      statusCode == 403 || 
      errorCode == 'authentication_failed' ||
      errorCode == 'invalid_token' ||
      message.toLowerCase().contains('authentication') ||
      message.toLowerCase().contains('token') ||
      message.toLowerCase().contains('login') ||
      message.toLowerCase().contains('password');

  /// Check if this error is related to network connectivity
  bool get isNetworkError =>
      message.toLowerCase().contains('network') ||
      message.toLowerCase().contains('connection') ||
      message.toLowerCase().contains('timeout') ||
      message.toLowerCase().contains('socket');

  /// Check if this error is related to validation
  bool get isValidationError =>
      statusCode == 400 ||
      errorCode == 'validation_error' ||
      details != null;

  @override
  String toString() {
    return 'ApiError{statusCode: $statusCode, errorCode: $errorCode, message: $message, details: $details}';
  }
}
