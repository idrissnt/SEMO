import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A fully responsive dimensions system for the app
/// All spacing, padding, and sizing will automatically adapt to different screen sizes

/// Access to responsive Width dimensions using ScreenUtil
class AppDimensionsWidth {
  AppDimensionsWidth._();

  static double get xxSmall => 4.w;
  static double get xSmall => 8.w;
  static double get small => 12.w;
  static double get medium => 16.w;
  static double get large => 20.w;
  static double get xl => 24.w;
  static double get xxl => 28.w;
  static double get xxxl => 32.w;
  static double get xxxxl => 36.w;
}

/// Access to responsive Height dimensions using ScreenUtil
class AppDimensionsHeight {
  AppDimensionsHeight._();
  static double get xxSmall => 4.h;
  static double get xSmall => 8.h;
  static double get small => 12.h;
  static double get medium => 16.h;
  static double get large => 20.h;
  static double get xl => 24.h;
  static double get xxl => 28.h;
  static double get xxxl => 32.h;
  static double get xxxxl => 36.h;
  static double get xxxxxl => 40.h;
}

/// Access to responsive Border radius using ScreenUtil
class AppBorderRadius {
  AppBorderRadius._();
  static double get xxSmall => 4.r;
  static double get xSmall => 8.r;
  static double get small => 12.r;
  static double get medium => 16.r;
  static double get large => 20.r;
  static double get xl => 24.r;
  static double get xxl => 28.r;
  static double get xxxl => 32.r;
}

/// Access to responsive Font size using ScreenUtil
class AppFontSize {
  AppFontSize._();
  static double get xxSmall => 4.sp;
  static double get xSmall => 8.sp;
  static double get small => 12.sp;
  static double get xMedium => 14.sp;
  static double get medium => 16.sp;
  static double get large => 20.sp;
  static double get xl => 24.sp;
  static double get xxl => 28.sp;
  static double get xxxl => 32.sp;
}

class AppIconSize {
  AppIconSize._();
  static double get xxSmall => 4.r;
  static double get xSmall => 8.r;
  static double get small => 12.r;
  static double get medium => 16.r;
  static double get large => 20.r;
  static double get xl => 24.r;
  static double get xxl => 28.r;
  static double get xxxl => 32.r;
  static double get xxxxl => 40.r;
}

/// Access to responsive Button dimensions using ScreenUtil
class AppButtonDimensions {
  AppButtonDimensions._();
  static double minWidth = 300.w;
  static double minHeight = 50.h;
}
