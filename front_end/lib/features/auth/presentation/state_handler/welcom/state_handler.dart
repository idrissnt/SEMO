import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_event.dart';

import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_state.dart';

import 'package:semo/features/auth/presentation/state_handler/welcom/error_state_widget.dart';
import 'package:semo/features/auth/presentation/state_handler/welcom/loading_state_widget.dart';

/// A utility class that handles state management for widgets
/// Provides consistent UI for loading, error, and success states
class WelcomeStateHandler {
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
    context.read<AuthBloc>().add(AuthCheckRequested());
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
}
