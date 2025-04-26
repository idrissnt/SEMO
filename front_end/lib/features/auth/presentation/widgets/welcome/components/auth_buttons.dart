import 'package:flutter/material.dart';

import 'package:semo/core/presentation/navigation/previous/router_services/route_constants.dart';
import 'package:semo/core/presentation/theme/theme_services/app_colors.dart';
import 'package:semo/core/presentation/theme/theme_services/app_dimensions.dart';

import 'package:semo/features/auth/presentation/widgets/welcome/styles/company_and_store_theme.dart';
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
    final double spacingBetweenButtons = AppDimensionsHeight.small;
    final double minWidth = WelcomeDimensions.minWidthButton;
    final double minHeight = WelcomeDimensions.minHeightButton;
    final double verticalPadding = AppDimensionsWidth.xSmall;
    final double horizontalPadding = AppDimensionsHeight.small;

    // Default styles for the register button
    final Map<String, dynamic> defaultRegisterStyle = {
      'text': 'Créer un compte',
      'textColor': AppColors.textSecondaryColor,
      'backgroundColor': AppColors.primary,
      'foregroundColor': AppColors.textSecondaryColor,
      'verticalPadding': verticalPadding,
      'horizontalPadding': horizontalPadding,
      'minWidth': minWidth,
      'minHeight': minHeight,
    };

    // Default styles for the login button
    final Map<String, dynamic> defaultLoginStyle = {
      'text': 'Se connecter',
      'textColor': AppColors.textPrimaryColor,
      'backgroundColor': AppColors.secondaryVariant,
      'foregroundColor': AppColors.textPrimaryColor,
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
