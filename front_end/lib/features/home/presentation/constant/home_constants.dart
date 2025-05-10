import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeConstants {
  // Bottom Navigation Screen labels
  static const String home = 'Accueil';
  static const String order = 'Commander';
  static const String deliver = 'Livrer';
  static const String message = 'Message';
  // static const String semoAi = 'SEMO AI';

  // App Bar
  static double addressSizedBoxWidth = 120.w;
  static double horizontalDensityBetweenIconAndText = -2.w;
  static double searchBarHeight = 45.h;
  static double searchBarWidth = double.infinity;
  static double queryLength = 2; // minimum length for auto completion

  static const Duration animationDuration = Duration(milliseconds: 300);

  static const String searchHintText = 'Search...';
  static const String defaultLocationText = 'Votre adresse';
}
