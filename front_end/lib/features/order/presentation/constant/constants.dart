import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderConstants {
  // Bottom Navigation Screen labels
  static const String order = 'Commander';

  // App Bar
  static double addressSizedBoxWidth = 150.w;
  static double horizontalDensityBetweenIconAndText = -2.w;
  static double searchBarHeight = 45.h;
  static double searchBarWidth = double.infinity;
  static double queryLength = 2; // minimum length for auto completion

  static const Duration animationDuration = Duration(milliseconds: 300);

  static const String searchHintText = 'Search...';
  static const String defaultLocationText = 'Votre adresse';
}
