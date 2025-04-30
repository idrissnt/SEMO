import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Constants used in the authentication feature screens and widgets
class AuthConstants {
  // Welcome Screen Constants
  static const int welcomePageCount = 2;
  static const String welcomeLoadingMessage = 'Chargement des données...';

  // login and registration screen constants Form Error Messages
  static const String emailFieldMessage = 'Veuillez entrer votre e-mail';
  static const String emailFieldMessageInvalid =
      'Veuillez entrer un e-mail valide';

  // Login Screen Constants
  static const String loginTitle = 'Connexion';
  static const String loginLoadingMessage = 'Connexion en cours...';
  static const String loginButtonText = 'Se connecter';
  static const String forgotPasswordText = 'Mot de passe oublié ?';

  // Login Form Labels
  static const String emailLabel = 'E-mail';
  static const String passwordLabel = 'Mot de passe';

  // Login Form Error Messages
  static const String passwordLoginFieldMessage =
      'Veuillez entrer votre mot de passe';

  // Registration Screen Constants
  static const String registrationTitle = 'Inscription';
  static const String registrationHeading = 'Créer un compte';
  static const String registrationLoadingMessage =
      'Création de votre compte...';
  static const String registrationButtonText = 'Créer un compte';

  // Registration Form Labels
  static const String firstNameLabel = 'Prénom';
  static const String passwordHelperText = 'Minimum 6 caractères';

  // Registration Form Error Messages
  static const String firstNameFieldMessage = 'Veuillez entrer votre prénom';
  static const String passwordRegistrationFieldMessage =
      'Veuillez entrer un mot de passe';

  // UI Constants
  static const int animationDurationMs = 300;

  // Button dimensions
  static double buttonMinWidth = 300.w;
  static double buttonMinHeight = 50.h;
}
