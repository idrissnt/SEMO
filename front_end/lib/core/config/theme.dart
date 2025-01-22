import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF00BFA6);
  static const Color secondaryColor = Color(0xFF6C63FF);
  static const Color errorColor = Color(0xFFE53935);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  
  // Text Styles
  static TextStyle get headingLarge => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  
  static TextStyle get headingMedium => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static TextStyle get headingSmall => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
  
  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
  );

  static TextStyle get bodySmall => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
  );
  
  // Theme Data
  static ThemeData get lightTheme => ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}
