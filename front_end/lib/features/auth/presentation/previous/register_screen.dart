import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/theme_services/app_colors.dart';
import 'package:semo/core/presentation/theme/theme_services/app_dimensions.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_state.dart';

import 'package:semo/features/auth/presentation/widgets/shared/auth_header.dart';
import 'package:semo/features/auth/presentation/widgets/register/register_form.dart';

class RegisterScreenPrevious extends StatefulWidget {
  const RegisterScreenPrevious({Key? key}) : super(key: key);

  @override
  State<RegisterScreenPrevious> createState() => _RegisterScreenPreviousState();
}

class _RegisterScreenPreviousState extends State<RegisterScreenPrevious>
    with SingleTickerProviderStateMixin {
  final AppLogger _logger = AppLogger();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _logger.debug('RegisterScreen: Initializing animation controllers',
        {'component': 'RegisterScreen'});

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
    _logger.debug('RegisterScreen: Disposing controllers',
        {'component': 'RegisterScreen'});
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _logger.info('User registered and authenticated successfully');
          context.go('/homeScreen');
        } else if (state is AuthFailure) {
          _logger.error('Registration error: ${state.error}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
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
                  padding: const EdgeInsets.all(24.0),
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
                          title: 'Create\nAccount',
                          subtitle: 'Sign up to get started',
                        ),
                        const SizedBox(height: 48),
                        RegisterFormWidget(authBloc: context.read<AuthBloc>()),
                        const SizedBox(height: 24),
                        // SocialLoginWidget(),
                        // const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(
                                fontSize: AppDimensionsWidth.medium,
                                color: Colors.white70,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/login'),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: AppDimensionsWidth.medium,
                                  color: const Color.fromARGB(255, 39, 35, 35),
                                  fontWeight: FontWeight.w600,
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
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthFailure) {
                  return Positioned(
                    top: MediaQuery.of(context).size.height * 0.1,
                    left: 0,
                    right: 0,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.error,
                              style: TextStyle(
                                fontSize: AppDimensionsWidth.medium,
                                color: Colors.red.shade700,
                                height: 1.2,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.red.shade700,
                              size: 20,
                            ),
                            onPressed: () {
                              // Trigger a rebuild to hide the error
                              context
                                  .read<AuthBloc>()
                                  .add(AuthCheckRequested());
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
