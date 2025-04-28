// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:semo/core/presentation/theme/theme_services/app_colors.dart';
import 'package:semo/core/presentation/theme/theme_services/app_dimensions.dart';
import 'package:semo/core/utils/logger.dart';

import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:semo/features/auth/presentation/widgets/shared/background.dart';
import 'package:semo/features/auth/presentation/widgets/shared/loading_button.dart';
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

  bool _obscurePassword = true;
  final String loadingMessage = 'Création de votre compte...';

  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
    return Scaffold(
      body: Stack(
        children: [
          // Background
          CustomPaint(
            painter: AuthBackgroundPainter(),
            size: Size.infinite,
          ),
          // Content
          SafeArea(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppDimensionsWidth.medium),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return AuthStateHandler.handleAuthState(
                    context: context,
                    state: state,
                    loadingMessage: loadingMessage,
                    onSuccess: (_) {
                      // This will be handled by the app's navigation logic
                      // when AuthAuthenticated state is emitted
                      return const SizedBox.shrink();
                    },
                    onInitial: () => _buildRegistrationForm(context, state),
                    onUnauthenticated: () =>
                        _buildRegistrationForm(context, state),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: AppDimensionsHeight.xxxxxl,
            left: AppDimensionsWidth.medium,
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: AppColors.background,
              ),
              icon: const Icon(Icons.arrow_back,
                  color: AppColors.iconColorFirstColor),
              onPressed: () => context.pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm(BuildContext context, AuthState state) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Container(
          height: 600.h,
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensionsWidth.medium,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.all(
              Radius.circular(AppBorderRadius.xl),
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontSize: AppFontSize.xxl,
                    color: AppColors.textPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // First name field
                TextFormField(
                  controller: _firstNameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    labelText: 'Prénom',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(15),
                      child: FaIcon(FontAwesomeIcons.person, size: 22),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppBorderRadius.medium),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre prénom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    labelText: 'E-mail',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(15),
                      child: FaIcon(FontAwesomeIcons.envelope, size: 22),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppBorderRadius.medium),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre e-mail';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Veuillez entrer un e-mail valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppBorderRadius.medium),
                    ),
                    labelText: 'Mot de passe',
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 50.h),

                // Register button with loading state
                LoadingButton(
                  onPressed: _register,
                  // Determine if we're in loading state
                  isLoading: AuthStateHandler.isLoading(state),
                  // Custom splash color for better visual feedback
                  splashColor: AppColors.primary,
                  highlightColor: AppColors.primary,
                  boxShadowColor: AppColors.primary,
                  // Slightly faster animation for a snappier feel
                  animationDuration: const Duration(milliseconds: 300),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(300, 50.h),
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(
                        vertical: AppDimensionsWidth.xSmall,
                        horizontal: AppDimensionsHeight.small),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
                    ),
                  ),
                  child: Text(
                    'Créer un compte',
                    style: TextStyle(
                      fontSize: AppFontSize.large,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(height: 50.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
