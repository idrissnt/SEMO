import 'package:flutter/material.dart';
import 'package:semo/core/extensions/theme_extension.dart';

/// A widget that displays social login options
class SocialLoginButtons extends StatelessWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onFacebookPressed;
  final VoidCallback? onApplePressed;

  const SocialLoginButtons({
    Key? key,
    this.onGooglePressed,
    this.onFacebookPressed,
    this.onApplePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or continue with',
                style: context.bodyMedium.copyWith(color: Colors.grey[600]),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _SocialButton(
              icon: 'assets/icons/google.png',
              onPressed: onGooglePressed,
            ),
            _SocialButton(
              icon: 'assets/icons/facebook.png',
              onPressed: onFacebookPressed,
            ),
            _SocialButton(
              icon: 'assets/icons/apple.png',
              onPressed: onApplePressed,
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String icon;
  final VoidCallback? onPressed;

  const _SocialButton({
    Key? key,
    required this.icon,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Image.asset(
            icon,
            width: 30,
            height: 30,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.login,
                color: Theme.of(context).primaryColor,
              );
            },
          ),
        ),
      ),
    );
  }
}
