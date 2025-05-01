import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';

/// A reusable text field component for authentication forms
class AuthTextField extends StatelessWidget {
  /// The controller for the text field
  final TextEditingController controller;

  /// The label text to display
  final String labelText;

  /// The icon to display as a prefix
  final IconData prefixIcon;

  /// The validation function
  final String? Function(String?)? validator;

  /// Whether to enable auto-validation
  final bool autovalidate;

  /// The text input type (email, number, etc.)
  final TextInputType keyboardType;

  /// The action to perform when the next button is pressed
  final TextInputAction textInputAction;

  /// The focus node for this field
  final FocusNode? focusNode;

  /// The focus node to request focus for when this field is submitted
  final FocusNode? nextFocusNode;

  /// The callback to execute when the field is submitted
  final VoidCallback? onSubmitted;

  const AuthTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.validator,
    this.autovalidate = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.nextFocusNode,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        ),
        labelText: labelText,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(15),
          child: FaIcon(prefixIcon, size: 22),
        ),
      ),
      validator: validator,
      autovalidateMode: autovalidate
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      onFieldSubmitted: (_) {
        if (nextFocusNode != null) {
          FocusScope.of(context).requestFocus(nextFocusNode);
        } else if (onSubmitted != null) {
          onSubmitted!();
        }
      },
    );
  }
}
