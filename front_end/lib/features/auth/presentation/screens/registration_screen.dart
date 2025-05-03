// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/presentation/widgets/buttons/button_factory.dart';

import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:semo/features/auth/presentation/utils/auth_validators.dart';
import 'package:semo/features/auth/presentation/widgets/shared/auth_screen_template.dart';
import 'package:semo/features/auth/presentation/widgets/shared/form/auth_form_container.dart';
import 'package:semo/features/auth/presentation/widgets/shared/form/auth_text_field.dart';
import 'package:semo/features/auth/presentation/widgets/shared/form/auth_password_field.dart';
import 'package:semo/features/auth/presentation/state_handler/auth/state_handler.dart';
import 'package:semo/features/auth/presentation/constants/auth_constants.dart';

final AppLogger logger = AppLogger();

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _firstNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  final String loadingMessage = AuthConstants.registrationLoadingMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              firstName: _firstNameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenTemplate(
      title: AuthConstants.registrationTitle,
      loadingMessage: loadingMessage,
      formBuilder: _buildRegistrationForm,
    );
  }

  Widget _buildRegistrationForm(BuildContext context, AuthState state) {
    return AuthFormContainer(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: AppDimensionsHeight.xxxl),

            // App logo or title
            Center(
              child: Text(
                AuthConstants.registrationHeading,
                style: TextStyle(
                  fontSize: AppFontSize.xxxl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
              ),
            ),
            SizedBox(height: AppDimensionsHeight.xxxl),

            // First name field
            AuthTextField(
              controller: _firstNameController,
              labelText: AuthConstants.firstNameLabel,
              prefixIcon: FontAwesomeIcons.user,
              focusNode: _firstNameFocusNode,
              nextFocusNode: _emailFocusNode,
              validator: AuthValidators.validateFirstName,
            ),
            SizedBox(height: AppDimensionsHeight.medium),

            // Email field
            AuthTextField(
              controller: _emailController,
              labelText: AuthConstants.emailLabel,
              prefixIcon: FontAwesomeIcons.envelope,
              keyboardType: TextInputType.emailAddress,
              focusNode: _emailFocusNode,
              nextFocusNode: _passwordFocusNode,
              validator: AuthValidators.validateEmail,
            ),
            SizedBox(height: AppDimensionsHeight.medium),

            // Password field
            AuthPasswordField(
              controller: _passwordController,
              labelText: AuthConstants.passwordLabel,
              focusNode: _passwordFocusNode,
              nextFocusNode: _confirmPasswordFocusNode,
              validator: AuthValidators.validateRegistrationPassword,
              helperText: AuthConstants.passwordHelperText,
            ),
            SizedBox(height: AppDimensionsHeight.xxxl),

            // Register button with loading state
            ButtonFactory.createLoadingButton(
              context: context,
              onPressed: _register,
              text: AuthConstants.registrationButtonText,
              // Determine if we're in loading state
              isLoading: AuthStateHandler.isLoading(state),
              // Colors
              backgroundColor: AppColors.primary,
              textColor: AppColors.secondary,
              splashColor: AppColors.primary,
              highlightColor: AppColors.primary,
              boxShadowColor: AppColors.primary,
              // Dimensions
              minWidth: AuthConstants.buttonMinWidth,
              minHeight: AuthConstants.buttonMinHeight,
              verticalPadding: AppDimensionsWidth.xSmall,
              horizontalPadding: AppDimensionsHeight.small,
              borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
              // Animation
              animationDuration: const Duration(
                  milliseconds: AuthConstants.animationDurationMs),
              enableHapticFeedback: true,
              // Text style
              textStyle: TextStyle(
                fontSize: AppFontSize.large,
                fontWeight: FontWeight.w800,
                color: AppColors.secondary,
              ),
            ),
            SizedBox(height: AppDimensionsHeight.xl),
          ],
        ),
      ),
    );
  }
}
