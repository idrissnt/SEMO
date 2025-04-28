import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:semo/core/presentation/theme/theme_services/app_colors.dart';
import 'package:semo/core/presentation/theme/theme_services/app_dimensions.dart';
import 'package:semo/features/auth/presentation/widgets/for_welcome/styles/company_and_store_theme.dart';

/// A reusable widget for displaying loading states
/// Provides consistent loading UI across the application
class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final bool useShimmer;

  const LoadingStateWidget({
    Key? key,
    this.message,
    this.useShimmer = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (useShimmer) {
      return _buildShimmerLoading(context);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 4.r,
            backgroundColor: AppColors.secondary,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          if (message != null) ...[
            SizedBox(height: AppDimensionsHeight.medium),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppFontSize.medium,
                color: AppColors.secondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    // Simple shimmer effect using Container with gradient
    return Container(
      width: double.infinity,
      height: WelcomeDimensions.bigCardHeight,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
      ),
      child: message != null
          ? Center(
              child: Text(
                message!,
                style: TextStyle(
                  fontSize: AppFontSize.medium,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
