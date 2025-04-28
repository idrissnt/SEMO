import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:semo/core/presentation/theme/theme_services/app_colors.dart';
import 'package:semo/core/presentation/theme/theme_services/app_dimensions.dart';

import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:semo/features/auth/presentation/widgets/shared/background.dart';
import 'package:semo/features/auth/presentation/widgets/state_handler/auth/state_handler.dart';

/// A reusable template for authentication screens (login, registration, etc.)
///
/// This template provides a consistent layout and behavior for all auth screens,
/// including background, back button, and state handling.
class AuthScreenTemplate extends StatelessWidget {
  /// The title of the screen
  final String title;

  /// The form content to display
  final Widget Function(BuildContext context, AuthState state) formBuilder;

  /// The loading message to display when in loading state
  final String loadingMessage;

  /// Whether to show the back button
  final bool showBackButton;

  const AuthScreenTemplate({
    Key? key,
    required this.title,
    required this.formBuilder,
    required this.loadingMessage,
    this.showBackButton = true,
  }) : super(key: key);

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
                    onInitial: () => formBuilder(context, state),
                    onUnauthenticated: () => formBuilder(context, state),
                  );
                },
              ),
            ),
          ),
          // Back button (optional)
          if (showBackButton)
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
}
