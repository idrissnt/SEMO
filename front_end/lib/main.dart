// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports
import 'package:semo/core/app/app.dart';
import 'package:semo/core/di/injection_container.dart'; //sl = service locator
import 'package:semo/core/utils/logger.dart';

// BLoC imports
import 'package:semo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize dependencies, service locator
    await initializeDependencies();
    final logger = sl<AppLogger>();
    await logger.initialize();

    logger.debug('Dependencies initialized successfully');

    // Initialize app
    runApp(
      // Provide the AuthBloc to the widget tree
      BlocProvider<AuthBloc>(
        create: (context) {
          final bloc = AuthBloc(
            // Gets the authRepository from the service locator
            // Creates the AuthBloc with this repository
            authRepository: sl(),
          );
          // Immediately check if the user is already authenticated
          bloc.add(AuthCheckRequested());
          return bloc;
        },
        // MyApp is the root widget of the app
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    sl<AppLogger>().error('Error in main()', error: e, stackTrace: stackTrace);
    rethrow;
  }
}
