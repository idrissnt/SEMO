import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// A comprehensive text styles class that provides consistent typography across the app
/// All text styles should be accessed through this class to maintain consistency
class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  /// Returns a responsive font size based on the base size and device width
  static double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    // Scale down font size slightly on smaller screens
    if (width < 360) return baseSize * 0.8;
    if (width < 600) return baseSize * 0.9;
    // Scale up font size slightly on larger screens
    if (width > 1200) return baseSize * 1.2;
    return baseSize;
  }

  static TextStyle semoWelcome(BuildContext context) => GoogleFonts.poppins(
        fontSize: _getResponsiveFontSize(context, 50),
        fontWeight: FontWeight.bold,
        color: AppColors.semoWelcome,
        height: 1.2,
      );

  // Headline Styles - Context-aware versions
  static TextStyle headline1(BuildContext context) => GoogleFonts.poppins(
        fontSize: _getResponsiveFontSize(context, 32),
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryColor,
        height: 1.2,
      );

  static TextStyle headline2(BuildContext context) => GoogleFonts.poppins(
        fontSize: _getResponsiveFontSize(context, 24),
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryColor,
        height: 1.3,
      );

  static TextStyle headline3(BuildContext context) => GoogleFonts.poppins(
        fontSize: _getResponsiveFontSize(context, 20),
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryColor,
        height: 1.4,
      );

  static TextStyle headline4(BuildContext context) => GoogleFonts.poppins(
        fontSize: _getResponsiveFontSize(context, 18),
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryColor,
        height: 1.4,
      );

  // Section title style - commonly used for section headers
  static TextStyle sectionTitle(BuildContext context) => GoogleFonts.poppins(
        fontSize: _getResponsiveFontSize(context, 18),
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryColor,
        height: 1.4,
      );

  // Body Styles - Context-aware versions
  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.poppins(
        fontSize: _getResponsiveFontSize(context, 16),
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimaryColor,
        height: 1.5,
      );

  static TextStyle appBarTitle(BuildContext context) => GoogleFonts.poppins(
        fontSize: _getResponsiveFontSize(context, 16),
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryColor,
        height: 1.4,
      );

  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.poppins(
        fontSize: _getResponsiveFontSize(context, 14),
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimaryColor,
        height: 1.5,
      );

  static TextStyle bodySmall(BuildContext context) => GoogleFonts.poppins(
        fontSize: _getResponsiveFontSize(context, 12),
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondaryColor,
        height: 1.5,
      );

  static TextStyle caption(BuildContext context) => GoogleFonts.poppins(
        fontSize: _getResponsiveFontSize(context, 12),
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondaryColor,
        height: 1.4,
      );

  // Button Styles - Context-aware versions

  static TextStyle buttonVeryLarge(BuildContext context) => GoogleFonts.poppins(
        fontSize: _getResponsiveFontSize(context, 24),
        fontWeight: FontWeight.w900,
        color: Colors.white,
        height: 1.4,
      );
  static TextStyle buttonLarge(BuildContext context) => GoogleFonts.poppins(
        fontSize: _getResponsiveFontSize(context, 20),
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.4,
      );

  static TextStyle buttonMedium(BuildContext context) => GoogleFonts.poppins(
        fontSize: _getResponsiveFontSize(context, 16),
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.4,
      );

  static TextStyle buttonSmall(BuildContext context) => GoogleFonts.poppins(
        fontSize: _getResponsiveFontSize(context, 14),
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.4,
      );

  static TextStyle buttonExtraSmall(BuildContext context) =>
      GoogleFonts.poppins(
        fontSize: _getResponsiveFontSize(context, 12),
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.4,
      );

  // Special Styles - Context-aware versions
  static TextStyle errorText(BuildContext context) => GoogleFonts.poppins(
        fontSize: _getResponsiveFontSize(context, 14),
        fontWeight: FontWeight.normal,
        color: AppColors.error,
        height: 1.4,
      );

  static TextStyle successText(BuildContext context) => GoogleFonts.poppins(
        fontSize: _getResponsiveFontSize(context, 14),
        fontWeight: FontWeight.normal,
        color: AppColors.success,
        height: 1.4,
      );

  // Card Styles - Context-aware versions
  static TextStyle cardTitle(BuildContext context) => GoogleFonts.poppins(
        fontSize: _getResponsiveFontSize(context, 16),
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.4,
        shadows: const [
          Shadow(
            blurRadius: 10.0,
            color: Colors.black54,
            offset: Offset(2.0, 2.0),
          ),
        ],
      );

  static TextStyle cardSubtitle(BuildContext context) => GoogleFonts.poppins(
        fontSize: _getResponsiveFontSize(context, 12),
        color: Colors.white70,
        height: 1.4,
        shadows: const [
          Shadow(
            blurRadius: 5.0,
            color: Colors.black54,
            offset: Offset(1.0, 1.0),
          ),
        ],
      );

  // Badge Styles - Context-aware versions
  static TextStyle badgeText(BuildContext context) => GoogleFonts.poppins(
        fontSize: _getResponsiveFontSize(context, 10),
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.2,
      );

  // List item styles
  static TextStyle listItemTitle(BuildContext context) => GoogleFonts.poppins(
        fontSize: _getResponsiveFontSize(context, 14),
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryColor,
        height: 1.4,
      );

  static TextStyle listItemSubtitle(BuildContext context) =>
      GoogleFonts.poppins(
        fontSize: _getResponsiveFontSize(context, 12),
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondaryColor,
        height: 1.4,
      );
}
