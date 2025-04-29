import 'package:semo/core/domain/exceptions/api_exceptions.dart';
import 'package:semo/core/domain/exceptions/api_error_extensions.dart';
import 'package:semo/features/auth/domain/exceptions/auth/auth_exceptions.dart';

/// A service that provides user-friendly error messages for authentication exceptions
/// This centralizes error message personalization in the presentation layer
class AuthErrorMessageService {
  /// Returns a user-friendly message for an authentication exception
  /// This method is specifically designed for authentication operations
  /// @param exception The exception that was thrown
  /// @param operation The operation being performed (login, registration, logout)
  String getUserFriendlyAuthMessage(
    dynamic exception,
    String operation,
  ) {
    // Handle specific authentication exceptions
    if (exception is InvalidCredentialsException) {
      return 'L\'email ou le mot de passe que vous avez saisi est incorrect.';
    } else if (exception is InvalidInputException) {
      return 'Veuillez vérifier les informations saisies et réessayer.';
    } else if (exception is UserAlreadyExistsException) {
      return 'Avez-vous déjà un compte Semo ? cette adresse e-mail est déjà associée à un compte. Veuillez vous connecter.';
    } else if (exception is MissingRefreshTokenException) {
      return 'Votre session a expiré. Veuillez vous reconnecter.';
    }

    // Handle API-specific exceptions
    if (exception is DomainException) {
      if (exception.isNetworkError) {
        return 'Veuillez vérifier votre connexion internet et réessayer.';
      } else if (exception.isServerError) {
        return 'Nos serveurs rencontrent actuellement des problèmes. Veuillez réessayer plus tard.';
      }
    }

    // Default fallback for any unhandled exception types
    switch (operation) {
      case 'login':
        return 'Une erreur s\'est produite lors de la connexion. Veuillez réessayer.';
      case 'registration':
        return 'Une erreur s\'est produite lors de l\'inscription. Veuillez réessayer.';
      case 'logout':
        return 'Une erreur s\'est produite lors de la déconnexion. Veuillez réessayer.';
      case 'profile':
        return 'Une erreur s\'est produite lors du chargement de votre profil. Veuillez réessayer.';
      default:
        return 'Une erreur s\'est produite. Veuillez réessayer plus tard.';
    }
  }

  /// Returns a more detailed error message for debugging purposes
  /// This can be used for logging or displaying in developer mode
  String getTechnicalErrorDetails(dynamic exception) {
    if (exception is DomainException) {
      final details = <String>['Message: ${exception.message}'];

      if (exception.code != null) {
        details.add('Code: ${exception.code}');
      }

      if (exception.requestId != null) {
        details.add('Request ID: ${exception.requestId}');
      }

      return details.join(' | ');
    }

    return exception.toString();
  }
}
