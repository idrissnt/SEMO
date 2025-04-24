import 'package:flutter/material.dart';
import 'package:semo/core/presentation/navigation/router_services/route_constants.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';
import 'package:semo/features/auth/presentation/widgets/welcome/utils/button_builder.dart';

/// A reusable component that displays the authentication buttons
/// (Create Account and Login) in a consistent manner across the app
class AuthButtons extends StatelessWidget {
  /// Optional custom styling for the register button
  final Map<String, dynamic>? registerButtonStyle;

  /// Optional custom styling for the login button
  final Map<String, dynamic>? loginButtonStyle;

  /// Creates an AuthButtons widget with optional custom styling
  const AuthButtons({
    Key? key,
    this.registerButtonStyle,
    this.loginButtonStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double spacingBetweenButtons = context.smallHeight;
    final double minWidth = context.getResponsiveWidthValue(250.0);
    final double minHeight = context.getResponsiveHeightValue(50.0);
    final double verticalPadding = context.xsWidth;
    final double horizontalPadding = context.smallHeight;

    // Default styles for the register button
    final Map<String, dynamic> defaultRegisterStyle = {
      'text': 'Créer un compte',
      'textColor': context.textSecondaryColor,
      'backgroundColor': context.primaryColor,
      'foregroundColor': context.textSecondaryColor,
      'verticalPadding': verticalPadding,
      'horizontalPadding': horizontalPadding,
      'minWidth': minWidth,
      'minHeight': minHeight,
    };

    // Default styles for the login button
    final Map<String, dynamic> defaultLoginStyle = {
      'text': 'Se connecter',
      'textColor': context.textPrimaryColor,
      'backgroundColor': context.surfaceColor,
      'foregroundColor': context.textPrimaryColor,
      'verticalPadding': verticalPadding,
      'horizontalPadding': horizontalPadding,
      'minWidth': minWidth,
      'minHeight': minHeight,
    };

    // Merge default styles with any custom styles provided
    final registerStyle = {...defaultRegisterStyle, ...?registerButtonStyle};
    final loginStyle = {...defaultLoginStyle, ...?loginButtonStyle};

    return Column(
      children: [
        ButtonBuilder(
          context: context,
          route: AppRoutes.register,
          text: registerStyle['text'] as String,
          textColor: registerStyle['textColor'] as Color,
          backgroundColor: registerStyle['backgroundColor'] as Color,
          foregroundColor: registerStyle['foregroundColor'] as Color,
          verticalPadding: registerStyle['verticalPadding'] as double,
          horizontalPadding: registerStyle['horizontalPadding'] as double,
          minWidth: registerStyle['minWidth'] as double,
          minHeight: registerStyle['minHeight'] as double,
        ).buildButtons(),
        SizedBox(height: spacingBetweenButtons),
        ButtonBuilder(
          context: context,
          route: AppRoutes.login,
          text: loginStyle['text'] as String,
          textColor: loginStyle['textColor'] as Color,
          backgroundColor: loginStyle['backgroundColor'] as Color,
          foregroundColor: loginStyle['foregroundColor'] as Color,
          verticalPadding: loginStyle['verticalPadding'] as double,
          horizontalPadding: loginStyle['horizontalPadding'] as double,
          minWidth: loginStyle['minWidth'] as double,
          minHeight: loginStyle['minHeight'] as double,
        ).buildButtons(),
      ],
    );
  }
}
