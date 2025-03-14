import 'package:logging/logging.dart';
import '../../../../data/models/error/api_error.dart';

/// Handles error message formatting for user-friendly display
class ErrorMessageService {
  static final _logger = Logger('ErrorMessageService');

  /// Converts any error into a user-friendly message
  static String getErrorMessage(dynamic error) {
    // Log the original error for debugging
    _logger.warning('Processing error: $error');
    
    // Convert to structured ApiError
    final apiError = error is ApiError ? error : ApiError.fromException(error);
    
    // Log structured error details
    _logger.warning('Structured error: $apiError');
    
    // Handle based on error type
    if (apiError.isAuthError) {
      return _getAuthErrorMessage(apiError);
    }
    
    if (apiError.isNetworkError) {
      return _getNetworkErrorMessage(apiError);
    }
    
    if (apiError.isValidationError) {
      return _getValidationErrorMessage(apiError);
    }
    
    // Generic error handling based on error message content
    return _getGenericErrorMessage(apiError);
  }
  
  /// Handles authentication-specific errors
  static String _getAuthErrorMessage(ApiError error) {
    final message = error.message.toLowerCase();
    final statusCode = error.statusCode;
    
    // Handle specific status codes
    if (statusCode == 401) {
      return 'Invalid email or password. Please try again.';
    }
    
    if (statusCode == 403) {
      return 'You do not have permission to perform this action.';
    }
    
    // Handle specific error messages
    if (message.contains('token expired') || message.contains('expired token')) {
      return 'Your session has expired. Please log in again.';
    }
    
    if (message.contains('invalid token') || message.contains('token invalid')) {
      return 'Authentication failed. Please log in again.';
    }
    
    if (message.contains('password')) {
      if (message.contains('required')) {
        return 'Password is required.';
      }
      if (message.contains('6 characters') || message.contains('too short')) {
        return 'Password must be at least 6 characters long.';
      }
      if (message.contains('incorrect') || message.contains('invalid')) {
        return 'Incorrect password. Please try again.';
      }
      return 'Please check your password.';
    }
    
    // Default auth error message
    return 'Authentication failed. Please check your credentials and try again.';
  }
  
  /// Handles network-related errors
  static String _getNetworkErrorMessage(ApiError error) {
    final message = error.message.toLowerCase();
    
    if (message.contains('timeout')) {
      return 'Request timed out. Please check your internet connection and try again.';
    }
    
    if (message.contains('connection refused')) {
      return 'Unable to connect to server. Please try again later.';
    }
    
    // Default network error
    return 'Network error. Please check your internet connection and try again.';
  }
  
  /// Handles validation errors
  static String _getValidationErrorMessage(ApiError error) {
    final message = error.message.toLowerCase();
    final details = error.details;
    
    // If we have field-specific errors, use them
    if (details != null && details.isNotEmpty) {
      // Get the first field error
      final firstField = details.keys.first;
      final firstError = details[firstField];
      
      if (firstError is List && firstError.isNotEmpty) {
        return firstError.first.toString();
      } else if (firstError != null) {
        return firstError.toString();
      }
    }
    
    // Email validation errors
    if (message.contains('email')) {
      if (message.contains('already exists')) {
        return 'This email is already registered. Please try logging in.';
      }
      if (message.contains('required')) {
        return 'Email address is required.';
      }
      if (message.contains('valid')) {
        return 'Please enter a valid email address.';
      }
      return 'Please check your email address.';
    }
    
    // Name validation errors
    if (message.contains('first_name')) {
      return 'Please enter your first name.';
    }
    if (message.contains('last_name')) {
      return 'Please enter your last name.';
    }
    
    // Default validation error
    return 'Please check your input and try again.';
  }
  
  /// Handles generic errors
  static String _getGenericErrorMessage(ApiError error) {
    final message = error.message;
    final statusCode = error.statusCode;
    
    // Handle specific status codes
    if (statusCode == 404) {
      return 'The requested resource was not found.';
    }
    
    if (statusCode == 500) {
      return 'Server error. Please try again later.';
    }
    
    // If we can't identify a specific error, show a cleaned version of the message
    return message.replaceAll('Exception: ', '');
  }
}

/// Shorthand function for getting error messages
String getErrorMessage(dynamic error) {
  return ErrorMessageService.getErrorMessage(error);
}
