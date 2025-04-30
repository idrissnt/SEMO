import 'package:semo/core/domain/exceptions/api_error_extensions.dart';
import 'package:semo/features/profile/domain/exceptions/user_verifications/verif_exceptions.dart';

/// Service for generating user-friendly error messages for email verification errors
class EmailVerificationErrorMessageService {
  /// Get a user-friendly error message for email verification errors
  String getUserFriendlyMessage(dynamic error, String verificationType) {
    String verificationTypeInFrench = _getVerificationTypeInFrench(verificationType);

    if (error == null) {
      return 'Une erreur inattendue s\'est produite lors du processus de $verificationTypeInFrench.';
    }

    // Network errors
    if (error is UserVerifException && error.isNetworkError) {
      return 'Problème de connexion réseau. Veuillez vérifier votre connexion internet et réessayer.';
    }

    // Server errors
    if (error is UserVerifException && error.isServerError) {
      return 'Nos serveurs rencontrent des problèmes. Veuillez réessayer ultérieurement.';
    }

    // Specific error types
    if (error is UserNotFoundException) {
      return 'Utilisateur introuvable. Veuillez vérifier vos identifiants et réessayer.';
    } else if (error is InvalidVerificationCodeException) {
      return 'Le code de vérification que vous avez saisi est invalide ou a expiré. Veuillez réessayer ou demander un nouveau code.';
    } else if (error is EmailVerificationRequestFailedException) {
      return 'Nous n\'avons pas pu envoyer un code de vérification à votre email. Veuillez vérifier votre adresse email et réessayer.';
    } else if (error is GenericUserVerifException) {
      return 'Une erreur s\'est produite lors de la vérification d\'email. Veuillez réessayer.';
    }

    // Fallback for unknown errors
    return 'Une erreur inattendue s\'est produite. Veuillez réessayer ultérieurement.';
  }

  /// Get technical error details for logging
  String getTechnicalErrorDetails(UserVerifException error) {
    return 'Error Code: ${error.code ?? "N/A"}, '
        'Message: ${error.message}, '
        'Request ID: ${error.requestId ?? "N/A"}';
  }
  
  /// Translates verification type to French
  String _getVerificationTypeInFrench(String verificationType) {
    switch (verificationType.toLowerCase()) {
      case 'email verification':
      case 'email verification request':
        return 'vérification d\'email';
      case 'email code verification':
        return 'vérification du code d\'email';
      default:
        return 'vérification d\'email';
    }
  }
}
