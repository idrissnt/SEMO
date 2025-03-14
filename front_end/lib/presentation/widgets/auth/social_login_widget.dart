import 'package:flutter/material.dart';
import 'package:semo/core/extensions/theme_extension.dart';
import 'package:semo/core/utils/logger.dart';

/// A widget for displaying social login options
class SocialLoginWidget extends StatelessWidget {
  final AppLogger _logger = AppLogger();

  SocialLoginWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: Colors.white54)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or continue with',
                style: context.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Colors.white54)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialButton(
              context,
              'assets/icons/google.png',
              'Google',
              () {
                _logger.info('Google sign-in clicked');
                // TODO: Implement Google sign-in
              },
            ),
            const SizedBox(width: 20),
            _socialButton(
              context,
              'assets/icons/facebook.png',
              'Facebook',
              () {
                _logger.info('Facebook sign-in clicked');
                // TODO: Implement Facebook sign-in
              },
            ),
            const SizedBox(width: 20),
            _socialButton(
              context,
              'assets/icons/apple.png',
              'Apple',
              () {
                _logger.info('Apple sign-in clicked');
                // TODO: Implement Apple sign-in
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _socialButton(
    BuildContext context,
    String iconPath,
    String label,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Image.asset(
            iconPath,
            width: 30,
            height: 30,
            errorBuilder: (context, error, stackTrace) {
              _logger.warning('Failed to load social icon: $iconPath',
                  error: error);
              return const Icon(
                Icons.login,
                color: Colors.white,
                size: 24,
              );
            },
          ),
        ),
      ),
    );
  }
}
