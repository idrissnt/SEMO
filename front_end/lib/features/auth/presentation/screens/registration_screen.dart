// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:semo/core/presentation/theme/theme_services/app_colors.dart';
import 'package:semo/core/presentation/theme/theme_services/app_dimensions.dart';
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
import 'package:semo/features/auth/presentation/widgets/state_handler/auth/state_handler.dart';

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

  final String loadingMessage = 'Création de votre compte...';

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
      title: 'Inscription',
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
            SizedBox(height: 30.h),

            // App logo or title
            Center(
              child: Text(
                'Créer un compte',
                style: TextStyle(
                  fontSize: AppFontSize.xxxl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
              ),
            ),
            SizedBox(height: 30.h),

            // First name field
            AuthTextField(
              controller: _firstNameController,
              labelText: 'Prénom',
              prefixIcon: FontAwesomeIcons.user,
              focusNode: _firstNameFocusNode,
              nextFocusNode: _emailFocusNode,
              validator: (value) =>
                  AuthValidators.validateRequired(value, 'prénom'),
            ),
            SizedBox(height: 16.h),

            // Email field
            AuthTextField(
              controller: _emailController,
              labelText: 'E-mail',
              prefixIcon: FontAwesomeIcons.envelope,
              keyboardType: TextInputType.emailAddress,
              focusNode: _emailFocusNode,
              nextFocusNode: _passwordFocusNode,
              validator: AuthValidators.validateEmail,
            ),
            SizedBox(height: 16.h),

            // Password field
            AuthPasswordField(
              controller: _passwordController,
              labelText: 'Mot de passe',
              focusNode: _passwordFocusNode,
              nextFocusNode: _confirmPasswordFocusNode,
              validator: AuthValidators.validatePassword,
              helperText: 'Minimum 6 caractères',
            ),
            SizedBox(height: 30.h),

            // Register button with loading state
            ButtonFactory.createLoadingButton(
              context: context,
              onPressed: _register,
              text: 'Créer un compte',
              // Determine if we're in loading state
              isLoading: AuthStateHandler.isLoading(state),
              // Colors
              backgroundColor: AppColors.primary,
              textColor: Colors.white,
              splashColor: AppColors.primary,
              highlightColor: AppColors.primary,
              boxShadowColor: AppColors.primary,
              // Dimensions
              minWidth: 300.w,
              minHeight: 50.h,
              verticalPadding: AppDimensionsWidth.xSmall,
              horizontalPadding: AppDimensionsHeight.small,
              borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
              // Animation
              animationDuration: const Duration(milliseconds: 300),
              enableHapticFeedback: true,
              // Text style
              textStyle: TextStyle(
                fontSize: AppFontSize.large,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
