import 'package:semo/core/domain/exceptions/api_exceptions.dart';
import 'package:semo/features/auth/domain/exceptions/welcom/exceptions_wlecom.dart';
import 'package:semo/core/domain/exceptions/api_error_extensions.dart';

/// A service that provides user-friendly error messages for domain exceptions
/// This centralizes error message personalization in the presentation layer
class ErrorMessageService {
  /// Returns a user-friendly message for a welcome exception
  /// This method is specifically designed for the welcome screen
  String getUserFriendlyWelcomeMessage(
    dynamic exception,
    String assetType,
  ) {
    // Handle API-specific exceptions
    if (exception is DomainException) {
      if (exception.isNetworkError) {
        return 'Veuillez vérifier votre connexion internet et réessayer.';
      } else if (exception.isServerError) {
        return 'Nos serveurs rencontrent actuellement des problèmes. Veuillez réessayer plus tard.';
      }
    }

    // Handle welcome-specific exceptions
    if (exception is WelcomeAssetsNotFoundException) {
      return 'Nous n\'avons pas pu trouver les données que vous recherchez. Veuillez réessayer plus tard.';
    } else if (exception is WelcomeAssetsFetchException) {
      return 'Nous avons rencontré des difficultés à charger les données. Veuillez réessayer.';
    } else if (exception is GenericWelcomeException) {
      return 'Une erreur s\'est produite lors du chargement des données. Veuillez réessayer.';
    }
    // Default fallback for any unhandled exception types
    return 'Une erreur s\'est produite. Veuillez réessayer plus tard.';
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
