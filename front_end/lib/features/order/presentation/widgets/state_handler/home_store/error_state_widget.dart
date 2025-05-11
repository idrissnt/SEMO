import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';

/// A reusable widget for displaying error states
/// Provides consistent error UI across the application
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final bool showRetryButton;
  final String retryText;

  const ErrorStateWidget({
    Key? key,
    required this.message,
    this.icon = Icons.error_outline,
    this.onRetry,
    this.showRetryButton = false,
    required this.retryText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: AppDimensionsWidth.medium,
            vertical: AppDimensionsHeight.medium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppIconSize.xxxxl,
              color: AppColors.error,
            ),
            SizedBox(height: AppDimensionsHeight.medium),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppFontSize.medium,
                color: AppColors.secondary,
              ),
            ),
            if (showRetryButton && onRetry != null) ...[
              SizedBox(height: AppDimensionsHeight.medium),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.textPrimaryColor,
                ),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh,
                    color: AppColors.textPrimaryColor),
                label: Text(
                  retryText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppFontSize.medium,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
