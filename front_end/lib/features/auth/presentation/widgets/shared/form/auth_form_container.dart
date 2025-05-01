import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';

/// A container for authentication forms with consistent styling
class AuthFormContainer extends StatelessWidget {
  /// The form content to display
  final Widget child;

  /// The height of the container
  final double? height;

  /// The width of the container
  final double? width;

  /// Additional padding to apply
  final EdgeInsetsGeometry? padding;

  const AuthFormContainer({
    Key? key,
    required this.child,
    this.height,
    this.width,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Container(
          height: height ?? 600.h,
          width: width,
          padding: padding ??
              EdgeInsets.symmetric(
                horizontal: AppDimensionsWidth.medium,
              ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.large),
          ),
          child: child,
        ),
      ),
    );
  }
}
