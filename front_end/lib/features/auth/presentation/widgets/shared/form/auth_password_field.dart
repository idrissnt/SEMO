import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';

/// A reusable password field component for authentication forms
///
/// This component includes a toggle to show/hide the password
class AuthPasswordField extends StatefulWidget {
  /// The controller for the text field
  final TextEditingController controller;

  /// The label text to display
  final String labelText;

  /// The validation function
  final String? Function(String?)? validator;

  /// Whether to enable auto-validation
  final bool autovalidate;

  /// The action to perform when the next button is pressed
  final TextInputAction textInputAction;

  /// The focus node for this field
  final FocusNode? focusNode;

  /// The focus node to request focus for when this field is submitted
  final FocusNode? nextFocusNode;

  /// The callback to execute when the field is submitted
  final VoidCallback? onSubmitted;

  /// Helper text to display below the field
  final String? helperText;

  const AuthPasswordField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.autovalidate = false,
    this.textInputAction = TextInputAction.done,
    this.focusNode,
    this.nextFocusNode,
    this.onSubmitted,
    this.helperText,
  }) : super(key: key);

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _obscurePassword,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        ),
        labelText: widget.labelText,
        helperText: widget.helperText,
        helperStyle: const TextStyle(fontSize: 12),
        prefixIcon: const Padding(
          padding: EdgeInsets.all(15),
          child: FaIcon(FontAwesomeIcons.lock, size: 22),
        ),
        suffixIcon: IconButton(
          icon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: FaIcon(
              _obscurePassword
                  ? FontAwesomeIcons.eye
                  : FontAwesomeIcons.eyeSlash,
              size: 22,
            ),
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: widget.validator,
      autovalidateMode: widget.autovalidate
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      onFieldSubmitted: (_) {
        if (widget.nextFocusNode != null) {
          FocusScope.of(context).requestFocus(widget.nextFocusNode);
        } else if (widget.onSubmitted != null) {
          widget.onSubmitted!();
        }
      },
    );
  }
}
