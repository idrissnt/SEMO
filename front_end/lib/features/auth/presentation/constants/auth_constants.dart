/// Constants used in the authentication feature screens and widgets
class AuthConstants {
  /// //===========================================================================
  /// Splash Screen Constants
  /// //===========================================================================
  static const int splashDuration =
      2000; // 2 seconds to wait for Auth check and assets loading
  static const String splashLoadingMessage = 'Chargement de l\'app...';
  static const String splashLoadingMessageBeforeData = 'Semo';

  /// //===========================================================================
  /// Welcome Screen Constants
  /// //===========================================================================
  static const int welcomePageCount = 2;
  static const String welcomeLoadingMessage = 'Chargement des données...';
  static const String skipButtonLabel = 'Passer';

  /// //===========================================================================
  /// Common Form Constants
  /// //===========================================================================
  static const String emailLabel = 'E-mail';
  static const String passwordLabel = 'Mot de passe';
  static const String emailFieldMessage = 'Veuillez entrer votre e-mail';
  static const String emailFieldMessageInvalid =
      'Veuillez entrer un e-mail valide';
  static const String passwordHelperText = 'Minimum 6 caractères';

  /// //===========================================================================
  /// Login Screen Constants
  /// //===========================================================================
  static const String loginTitle = 'Connexion';
  static const String loginLoadingMessage = 'Connexion en cours...';
  static const String loginButtonText = 'Se connecter';
  static const String forgotPasswordText = 'Mot de passe oublié ?';
  static const String passwordLoginFieldMessage =
      'Veuillez entrer votre mot de passe';

  /// //===========================================================================
  /// Registration Screen Constants
  /// //===========================================================================
  static const String registrationTitle = 'Inscription';
  static const String registrationHeading = 'Créer un compte';
  static const String registrationLoadingMessage =
      'Création de votre compte...';
  static const String registrationButtonText = 'Créer un compte';
  static const String firstNameLabel = 'Prénom';
  static const String firstNameFieldMessage = 'Veuillez entrer votre prénom';
  static const String passwordRegistrationFieldMessage =
      'Veuillez entrer un mot de passe';

  /// //===========================================================================
  /// UI Constants
  /// //===========================================================================
}
