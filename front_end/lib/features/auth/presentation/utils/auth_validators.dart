import 'package:semo/features/auth/presentation/constants/auth_constants.dart';

/// Utility class for form validation in authentication screens
class AuthValidators {
  /// Validates that a field is not empty
  static String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return AuthConstants.firstNameFieldMessage;
    }
    return null;
  }

  /// Validates that an email is in the correct format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AuthConstants.emailFieldMessage;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return AuthConstants.emailFieldMessageInvalid;
    }
    return null;
  }

  /// Validates that a password meets minimum requirements
  static String? validateRegistrationPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AuthConstants.passwordRegistrationFieldMessage;
    }
    if (value.length < 6) {
      return AuthConstants.passwordHelperText;
    }
    return null;
  }

  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AuthConstants.passwordLoginFieldMessage;
    }
    return null;
  }
}
