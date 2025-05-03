// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

// Core imports
import 'package:semo/core/app/app.dart';
import 'package:semo/core/di/injection_container.dart'; //sl = service locator
import 'package:semo/core/presentation/navigation/app_routes/app_router.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/utils/app_bloc_observer.dart';

// BLoC imports
import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_event.dart';
import 'package:semo/features/auth/presentation/coordinators/auth_flow_coordinator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force keyboard to close on app start and hot reload
  SystemChannels.textInput.invokeMethod('TextInput.hide');

  try {
    // Initialize dependencies, service locator
    await initializeDependencies();
    final logger = sl<AppLogger>();
    await logger.initialize();

    // Register the BlocObserver to monitor all bloc events and state changes
    Bloc.observer = AppBlocObserver(logger);

    // Initialize router and register all tabs
    AppRouter.initialize();

    // Initialize the auth flow coordinator
    // This starts listening to auth state changes and handling navigation
    final authFlowCoordinator = sl<AuthFlowCoordinator>();

    logger.debug('Dependencies and navigation initialized successfully');

    // Initialize app
    runApp(
      // Provide services to the widget tree
      MultiProvider(
        providers: [
          // Provide the AuthFlowCoordinator to the widget tree
          Provider<AuthFlowCoordinator>.value(value: authFlowCoordinator),
        ],
        // Wrap with BlocProvider for state management
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) {
                // Get the AuthBloc directly from the service locator
                final bloc = sl<AuthBloc>();
                // Immediately check if the user is already authenticated
                bloc.add(AuthCheckRequested());
                return bloc;
              },
            ),
            BlocProvider<WelcomeAssetsBloc>(
              create: (context) {
                // Get the WelcomeAssetsBloc from the service locator
                final bloc = sl<WelcomeAssetsBloc>();
                // Immediately load all welcome assets at once
                bloc.add(const LoadAllAssetsEvent());
                return bloc;
              },
            ),
          ],
          // MyApp is the root widget of the app
          child: const MyApp(),
        ),
      ),
    );
  } catch (e, stackTrace) {
    sl<AppLogger>().error('Error in main()', error: e, stackTrace: stackTrace);
    rethrow;
  }
}
