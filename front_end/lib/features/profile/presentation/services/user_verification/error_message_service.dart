import 'package:semo/core/domain/exceptions/api_error_extensions.dart';
import 'package:semo/features/profile/domain/exceptions/user_verifications/verif_exceptions.dart';

/// Service for generating user-friendly error messages for verification errors
class UserVerificationErrorMessageService {
  /// Get a user-friendly error message for verification errors
  String getUserFriendlyMessage(dynamic error, String verificationType) {
    String verificationTypeInFrench =
        _getVerificationTypeInFrench(verificationType);

    if (error == null) {
      return 'Une erreur inattendue s\'est produite lors du traitement de votre demande de $verificationTypeInFrench.';
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
    } else if (error is PhoneVerificationRequestFailedException) {
      return 'Nous n\'avons pas pu envoyer un code de vérification à votre téléphone. Veuillez vérifier votre numéro de téléphone et réessayer.';
    } else if (error is PasswordResetRequestFailedException) {
      return 'Nous n\'avons pas pu traiter votre demande de réinitialisation de mot de passe. Veuillez réessayer ultérieurement.';
    } else if (error is PasswordResetFailedException) {
      return 'Nous n\'avons pas pu réinitialiser votre mot de passe. Veuillez réessayer avec un code valide.';
    } else if (error is GenericUserVerifException) {
      return 'Une erreur s\'est produite lors de la vérification. Veuillez réessayer.';
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
        return 'vérification d\'email';
      case 'phone verification':
        return 'vérification de téléphone';
      case 'code verification':
        return 'vérification de code';
      case 'password reset':
        return 'réinitialisation de mot de passe';
      case 'password reset request':
        return 'demande de réinitialisation de mot de passe';
      default:
        return 'vérification';
    }
  }
}
