import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WelcomeDimensions {
  // Private constructor to prevent instantiation
  WelcomeDimensions._();

  // Static dimensions for welcome screen
  static double get bigCardHeight => 540.h;

  // Store card dimensions
  static double get storeSectionHeight => 150.h;
  static double get storeContainerHeight => 80.h;
  static double get storeSectionTitleSize => 18.sp;
  static double get storeImageSize => 50.r;
  static const Color secondTitleColor = Colors.red;

  // Company asset dimensions
  static double get companyLogoSize => 55.r;
  static double get companyNameSize => 40.sp;

  // Auth button dimensions
  static double get minHeightButton => 50.h;
  static double get minWidthButton => 250.w;
  static double get textFontSize => 10.sp;
}
