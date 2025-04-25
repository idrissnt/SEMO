// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/theme_services/app_colors.dart';
import 'package:semo/core/presentation/theme/theme_services/app_dimensions.dart';

import 'package:semo/core/utils/logger.dart';

import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_state.dart';

import 'package:semo/features/auth/presentation/widgets/shared/auth_header.dart';
import 'package:semo/features/auth/presentation/widgets/shared/auth_state_handler.dart';
import 'package:semo/features/auth/presentation/widgets/login/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final AppLogger _logger = AppLogger();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _logger.debug('LoginScreen: Initializing animation controllers',
        {'component': 'LoginScreen'});
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _logger.debug(
        'LoginScreen: Disposing controllers', {'component': 'LoginScreen'});
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        _logger.debug(
          'Login State',
          {'component': 'LoginScreen', 'state': state.toString()},
        );
        if (state is AuthAuthenticated) {
          _logger.info('Navigating to main screen');
          context.go('/homeScreen');
        }
      },
      child: AuthStateHandler(
        loadingWidget: const CircularProgressIndicator(color: Colors.white),
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.secondary,
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(AppDimensionsWidth.xl),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios,
                                color: Colors.white),
                            onPressed: () => context.go('/welcome'),
                          ),
                          const SizedBox(height: 32),
                          const AuthHeader(
                            title: 'Welcome\nBack',
                            subtitle: 'Sign in to continue',
                          ),
                          const SizedBox(height: 48),
                          LoginFormWidget(authBloc: context.read<AuthBloc>()),
                          const SizedBox(height: 24),
                          // SocialLoginWidget(),
                          // const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Don\'t have an account? ',
                                style: TextStyle(
                                  fontSize: AppDimensionsWidth.medium,
                                  color: Colors.white70,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.go('/register');
                                },
                                child: Text(
                                  'Register',
                                  style: TextStyle(
                                    fontSize: AppDimensionsWidth.medium,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
