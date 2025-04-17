import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/presentation/global/app_globals.dart';
import 'package:semo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth_event.dart';
import 'package:semo/features/auth/presentation/bloc/auth_state.dart';

/// A widget that handles different auth states and provides appropriate UI feedback
/// This demonstrates how to use BlocConsumer to react to different states
class AuthStateHandler extends StatelessWidget {
  /// The child widget to display when authenticated or during normal operation
  final Widget child;
  
  /// Optional widget to show during loading state, defaults to CircularProgressIndicator
  final Widget? loadingWidget;
  
  const AuthStateHandler({
    Key? key, 
    required this.child,
    this.loadingWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        // Only trigger listener for state changes that require user feedback
        return current is AuthFailureState || 
               (previous is AuthLoading && current is AuthAuthenticated);
      },
      listener: (context, state) {
        // Handle side effects based on state
        if (state is AuthFailureState) {
          _showErrorSnackBar(context, state);
        } else if (state is AuthAuthenticated) {
          // Clear any existing snackbars and show success message
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Successfully authenticated'),
                backgroundColor: Colors.green,
              ),
            );
        }
      },
      builder: (context, state) {
        // Show loading indicator during loading state
        if (state is AuthLoading) {
          return Center(
            child: loadingWidget ?? const CircularProgressIndicator(),
          );
        }
        
        // For all other states, show the child widget
        return child;
      },
    );
  }
  
  /// Shows an appropriate snackbar based on the failure state
  void _showErrorSnackBar(BuildContext context, AuthFailureState state) {
    // Create the snackbar with appropriate styling and actions
    final snackBar = SnackBar(
      content: Text(state.message),
      backgroundColor: _getErrorColor(state),
      action: state.canRetry
          ? SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                // Determine appropriate retry action based on state type
                if (state is ProfileFetchFailure) {
                  context.read<AuthBloc>().add(AuthCheckRequested());
                } else if (state is NetworkFailure) {
                  context.read<AuthBloc>().add(AuthCheckRequested());
                }
              },
            )
          : null,
      duration: const Duration(seconds: 5),
    );

    // Use the global ScaffoldMessengerKey to show the snackbar
    // This works regardless of the current context's position in the widget tree
    Future.microtask(() {
      final messenger = AppGlobals.scaffoldMessengerKey.currentState;
      if (messenger != null) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      } else {
        debugPrint('Could not show error snackbar: ScaffoldMessengerState is null');
      }
    });
  }
  
  /// Returns an appropriate color based on the error type
  Color _getErrorColor(AuthFailureState state) {
    if (state is InvalidCredentialsFailure) {
      return Colors.orange;
    } else if (state is ValidationFailure) {
      return Colors.amber;
    } else if (state is NetworkFailure) {
      return Colors.blue;
    } else if (state is ServerFailure) {
      return Colors.red;
    } else if (state is ProfileFetchFailure) {
      return Colors.purple;
    } else {
      return Colors.red;
    }
  }
}
