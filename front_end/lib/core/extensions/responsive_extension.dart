import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

extension ResponsiveExtension on BuildContext {
  /// Get the current device type
  DeviceType get deviceType => ResponsiveUtils.getDeviceType(this);

  /// Calculate a responsive size based on screen width percentage
  double responsiveSize(double percentage) => 
    ResponsiveUtils.getResponsiveSize(this, percentage);

  /// Check if the current device is mobile
  bool get isMobile => ResponsiveUtils.isMobile(this);

  /// Check if the current device is tablet
  bool get isTablet => ResponsiveUtils.isTablet(this);

  /// Check if the current device is desktop
  bool get isDesktop => ResponsiveUtils.isDesktop(this);

  /// Get a responsive widget based on device type
  Widget responsiveWidget({
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) => ResponsiveUtils.getResponsiveWidget(
    context: this,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
  );
}
