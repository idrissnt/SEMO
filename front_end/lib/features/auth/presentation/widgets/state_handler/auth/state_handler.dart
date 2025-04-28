import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:semo/core/presentation/widgets/popup_notification.dart';
import 'package:semo/features/auth/domain/entities/auth_entity.dart';

import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_state.dart';

/// A utility class that handles state management for widgets
/// Provides consistent UI for loading, error, and success states
class AuthStateHandler {
  /// Handles authentication states and returns appropriate widgets
  /// Now shows errors as popups and keeps loading state in the button
  static Widget handleAuthState({
    required BuildContext context,
    required AuthState state,
    required Widget Function(User user) onSuccess,
    required Widget Function() onInitial,
    required Widget Function() onUnauthenticated,
    String? loadingMessage,
  }) {
    // Handle success state
    if (state is AuthAuthenticated) {
      return onSuccess(state.user);
    }

    // Handle initial state
    if (state is AuthInitial) {
      return onInitial();
    }

    // Handle unauthenticated state
    if (state is AuthUnauthenticated) {
      return onUnauthenticated();
    }

    // Handle error states by showing a popup notification
    if (state is AuthFailureState) {
      // Delay slightly to ensure the context is ready
      Future.microtask(() {
        if (!context.mounted) return;
        _showErrorPopup(context, state);

        // Clear the error state after showing the popup
        // This prevents the error from persisting when navigating between screens
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!context.mounted) return;
          context.read<AuthBloc>().add(AuthResetState());
        });
      });

      // Return the normal content (initial or unauthenticated)
      return state is AuthUnauthenticated ? onUnauthenticated() : onInitial();
    }

    // For loading and any other unhandled state, show the appropriate content
    // Loading state will be handled by the LoadingButton in the UI
    return state is AuthUnauthenticated ? onUnauthenticated() : onInitial();
  }

  /// Shows an error popup notification based on the failure state
  static void _showErrorPopup(BuildContext context, AuthFailureState state) {
    IconData icon;
    Color backgroundColor = Colors.red.shade700;

    // Determine the appropriate icon based on error type
    if (state is NetworkFailure) {
      icon = Icons.signal_wifi_off;
    } else if (state is ServerFailure) {
      icon = Icons.cloud_off;
    } else if (state is InvalidCredentialsFailure) {
      icon = Icons.lock_outline;
    } else if (state is UserAlreadyExistsFailure) {
      icon = Icons.person_add_disabled;
    } else if (state is InvalidInputFailure) {
      icon = Icons.error_outline;
    } else if (state is ProfileFetchFailure) {
      icon = Icons.person_off;
    } else {
      icon = Icons.error_outline;
    }

    // Show the popup notification
    PopupNotification.show(
      context: context,
      message: state.message,
      icon: icon,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      duration: const Duration(seconds: 10),
      onDismiss: state.canRetry ? () => _retryAuthCheck(context) : null,
    );
  }

  /// Helper method to retry auth check
  static void _retryAuthCheck(BuildContext context) {
    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  /// Determines if the current state is a loading state
  static bool isLoading(AuthState state) {
    return state is AuthLoading;
  }

  /// Gets the appropriate loading message based on the state
  static String? getLoadingMessage(AuthState state, String defaultMessage) {
    if (state is AuthLoading) {
      // AuthLoading doesn't have a message property, so just return the default
      return defaultMessage;
    }
    return null;
  }
}
