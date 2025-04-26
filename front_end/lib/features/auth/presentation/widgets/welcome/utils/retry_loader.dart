import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_event.dart';

/// Utility class for handling retry loading operations in welcome screens
class RetryLoader {
  /// Schedules a retry for loading all assets after a specified delay
  ///
  /// [context] - The BuildContext used to access the BLoC
  /// [delaySeconds] - Optional delay in seconds before retrying (default: 3)
  static void scheduleRetryLoad(BuildContext context, {int delaySeconds = 3}) {
    Future.delayed(Duration(seconds: delaySeconds), () {
      if (context.mounted) {
        context.read<WelcomeAssetsBloc>().add(const LoadAllAssetsEvent());
      }
    });
  }
}
