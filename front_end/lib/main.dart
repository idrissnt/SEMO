// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports
import 'package:semo/core/app/app.dart';
import 'package:semo/core/di/injection_container.dart'; //sl = service locator
import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/utils/app_bloc_observer.dart';

// BLoC imports
import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_event.dart';
import 'package:semo/features/home/presentation/bloc/home_store/home_store_bloc.dart';
import 'package:semo/features/home/presentation/bloc/home_store/home_store_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize dependencies, service locator
    await initializeDependencies();
    final logger = sl<AppLogger>();
    await logger.initialize();

    // Register the BlocObserver to monitor all bloc events and state changes
    Bloc.observer = AppBlocObserver(logger);

    logger.debug('Dependencies initialized successfully');

    // Initialize app
    runApp(
      // Provide multiple BLoCs to the widget tree
      MultiBlocProvider(
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
          BlocProvider<HomeStoreBloc>(
            create: (context) {
              // Get the HomeStoreBloc from the service locator
              final bloc = sl<HomeStoreBloc>();
              // Immediately load store brands
              bloc.add(const LoadAllStoreBrandsEvent());
              return bloc;
            },
          ),
        ],
        // MyApp is the root widget of the app
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    sl<AppLogger>().error('Error in main()', error: e, stackTrace: stackTrace);
    rethrow;
  }
}
