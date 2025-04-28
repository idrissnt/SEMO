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

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final String loadingMessage = 'Connexion en cours...';

  @override
  void initState() {
    super.initState();
    logger.debug('LoginScreen: Initializing', {'component': 'LoginScreen'});
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenTemplate(
      title: 'Connexion',
      loadingMessage: loadingMessage,
      formBuilder: _buildLoginForm,
    );
  }

  Widget _buildLoginForm(BuildContext context, AuthState state) {
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
                'Connexion',
                style: TextStyle(
                  fontSize: AppFontSize.xxxl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
              ),
            ),
            SizedBox(height: 30.h),

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
            const SizedBox(height: 16),

            // Password field
            AuthPasswordField(
              controller: _passwordController,
              labelText: 'Mot de passe',
              focusNode: _passwordFocusNode,
              onSubmitted: _login,
              validator: (value) =>
                  AuthValidators.validateRequired(value, 'mot de passe'),
            ),
            const SizedBox(height: 8),

            // Forgot password link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Navigate to forgot password screen
                },
                child: const Text('Mot de passe oublié ?'),
              ),
            ),
            const SizedBox(height: 24),

            // Login button with loading state
            ButtonFactory.createLoadingButton(
              context: context,
              onPressed: _login,
              text: 'Se connecter',
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
