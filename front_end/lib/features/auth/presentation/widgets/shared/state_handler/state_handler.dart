import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:semo/features/auth/domain/entities/auth_entity.dart';

import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_state.dart';

import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_event.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_state.dart';

import 'package:semo/features/auth/presentation/widgets/shared/state_handler/error_state_widget.dart';
import 'package:semo/features/auth/presentation/widgets/shared/state_handler/loading_state_widget.dart';

/// A utility class that handles state management for widgets
/// Provides consistent UI for loading, error, and success states
class StateHandler {
  /// Handles welcome assets states and returns appropriate widgets
  static Widget handleWelcomeAssetsState<T>({
    required BuildContext context,
    required WelcomeAssetsState state,
    required Widget Function(T data) onSuccess,
    T Function(AllAssetsLoaded state)? dataSelector,
    String? loadingMessage,
    bool useShimmerLoading = false,
  }) {
    // Retry text
    const String retryText = 'Réessayer';

    // Handle success state
    if (state is AllAssetsLoaded && dataSelector != null) {
      final data = dataSelector(state);
      return onSuccess(data);
    }

    // Handle loading state
    if (state is WelcomeAssetsLoading) {
      return LoadingStateWidget(
        message: loadingMessage,
        useShimmer: useShimmerLoading,
      );
    }

    // Handle different error states
    if (state is WelcomeAssetsFailureState) {
      // For network errors, show a specific icon
      if (state is WelcomeAssetsNetworkFailure) {
        return ErrorStateWidget(
          message: state.message,
          icon: Icons.signal_wifi_off,
          showRetryButton: state.canRetry,
          retryText: retryText,
          onRetry: state.canRetry ? () => _retryLoad(context) : null,
        );
      }

      // For server errors
      if (state is WelcomeAssetsServerFailure) {
        return ErrorStateWidget(
          message: state.message,
          icon: Icons.cloud_off,
          showRetryButton: state.canRetry,
          retryText: retryText,
          onRetry: state.canRetry ? () => _retryLoad(context) : null,
        );
      }

      // For not found errors
      if (state is WelcomeAssetsNotFoundFailure) {
        return ErrorStateWidget(
          message: state.message,
          icon: Icons.search_off,
          showRetryButton: state.canRetry,
          retryText: retryText,
          onRetry: state.canRetry ? () => _retryLoad(context) : null,
        );
      }

      // For fetch failures
      if (state is WelcomeAssetsFetchFailure) {
        return ErrorStateWidget(
          message: state.message,
          icon: Icons.error_outline,
          showRetryButton: state.canRetry,
          retryText: retryText,
          onRetry: state.canRetry ? () => _retryLoad(context) : null,
        );
      }

      // For generic errors
      return ErrorStateWidget(
        message: state.message,
        icon: Icons.error_outline,
        showRetryButton: state.canRetry,
        retryText: retryText,
        onRetry: state.canRetry ? () => _retryLoad(context) : null,
      );
    }

    // For initial state or any other unhandled state, show loading
    if (state is WelcomeAssetsInitial) {
      // Trigger loading if we're in initial state
      _retryLoad(context);
    }

    return LoadingStateWidget(
      message: loadingMessage,
      useShimmer: useShimmerLoading,
    );
  }

  /// Helper method to retry loading assets
  static void _retryLoad(BuildContext context) {
    context.read<WelcomeAssetsBloc>().add(const LoadAllAssetsEvent());
  }

  /// Schedule a retry after a delay (useful for automatic retries)
  static void scheduleRetryLoad(BuildContext context,
      {int delayMilliseconds = 3000}) {
    Future.delayed(Duration(milliseconds: delayMilliseconds), () {
      // Only retry if the context is still valid
      if (context.mounted) {
        _retryLoad(context);
      }
    });
  }

  /// Handles authentication states and returns appropriate widgets
  static Widget handleAuthState({
    required BuildContext context,
    required AuthState state,
    required Widget Function(User user) onSuccess,
    required Widget Function() onInitial,
    required Widget Function() onUnauthenticated,
    String? loadingMessage,
    bool useShimmerLoading = false,
  }) {
    // Retry text
    const String retryText = 'Réessayer';

    // Handle success state
    if (state is AuthAuthenticated) {
      return onSuccess(state.user);
    }

    // Handle loading state
    if (state is AuthLoading) {
      return LoadingStateWidget(
        message: loadingMessage,
        useShimmer: useShimmerLoading,
      );
    }

    // Handle initial state
    if (state is AuthInitial) {
      return onInitial();
    }

    // Handle unauthenticated state
    if (state is AuthUnauthenticated) {
      return onUnauthenticated();
    }

    // Handle different error states
    if (state is AuthFailureState) {
      // For network errors, show a specific icon
      if (state is NetworkFailure) {
        return ErrorStateWidget(
          message: state.message,
          icon: Icons.signal_wifi_off,
          showRetryButton: state.canRetry,
          retryText: retryText,
          onRetry: state.canRetry ? () => _retryAuthCheck(context) : null,
        );
      }

      // For server errors
      if (state is ServerFailure) {
        return ErrorStateWidget(
          message: state.message,
          icon: Icons.cloud_off,
          showRetryButton: state.canRetry,
          retryText: retryText,
          onRetry: state.canRetry ? () => _retryAuthCheck(context) : null,
        );
      }

      // For invalid credentials
      if (state is InvalidCredentialsFailure) {
        return ErrorStateWidget(
          message: state.message,
          icon: Icons.lock_outline,
          showRetryButton: false,
          retryText: '',
        );
      }

      // For user already exists
      if (state is UserAlreadyExistsFailure) {
        return ErrorStateWidget(
          message: state.message,
          icon: Icons.person_add_disabled,
          showRetryButton: false,
          retryText: '',
        );
      }

      // For invalid input
      if (state is InvalidInputFailure) {
        return ErrorStateWidget(
          message: state.message,
          icon: Icons.error_outline,
          showRetryButton: false,
          retryText: '',
        );
      }

      // For profile fetch failures
      if (state is ProfileFetchFailure) {
        return ErrorStateWidget(
          message: state.message,
          icon: Icons.person_off,
          showRetryButton: state.canRetry,
          retryText: retryText,
          onRetry: state.canRetry ? () => _retryAuthCheck(context) : null,
        );
      }

      // For generic errors
      return ErrorStateWidget(
        message: state.message,
        icon: Icons.error_outline,
        showRetryButton: state.canRetry,
        retryText: retryText,
        onRetry: state.canRetry ? () => _retryAuthCheck(context) : null,
      );
    }

    // For any other unhandled state, show the initial state
    return onInitial();
  }

  /// Helper method to retry auth check
  static void _retryAuthCheck(BuildContext context) {
    context.read<AuthBloc>().add(AuthCheckRequested());
  }
}
