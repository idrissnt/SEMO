import 'package:flutter/material.dart';
import 'package:semo/core/extensions/theme_extension.dart';

/// A customized text field for authentication screens
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String? helperText;
  final bool obscureText;
  final bool enabled;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const AuthTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.helperText,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: context.bodyLarge.copyWith(color: Colors.black87),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        labelStyle: context.bodyMedium.copyWith(color: Colors.grey[700]),
        hintStyle: context.bodyMedium.copyWith(color: Colors.grey[400]),
        helperText: helperText,
        helperStyle: context.bodySmall.copyWith(color: Colors.grey[600]),
      ),
      validator: validator,
    );
  }
}
