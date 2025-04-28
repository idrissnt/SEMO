/// Utility class for form validation in authentication screens
class AuthValidators {
  /// Validates that a field is not empty
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre $fieldName';
    }
    return null;
  }

  /// Validates that an email is in the correct format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre e-mail';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Veuillez entrer un e-mail valide';
    }
    return null;
  }

  /// Validates that a password meets minimum requirements
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }
}
