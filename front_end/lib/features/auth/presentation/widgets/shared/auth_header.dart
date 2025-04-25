import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/theme_services/app_dimensions.dart';

/// A header widget for authentication screens
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
              fontSize: AppDimensionsWidth.medium,
              color: Colors.black87,
            )),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: AppDimensionsWidth.medium,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
