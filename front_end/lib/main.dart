// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:semo/features/auth/domain/repositories/auth_repository.dart';
import 'features/store/domain/repositories/store_repository.dart';

import 'package:semo/features/auth/bloc/auth_bloc.dart';
import 'package:semo/features/auth/bloc/auth_event.dart';
import 'features/store/bloc/store_bloc.dart';

import 'core/config/router_services/app_router.dart';
import 'core/di/injection_container.dart'; //sl = service locator
import 'core/theme/theme_services/app_colors.dart';
import 'core/utils/logger.dart';

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
      // MultiRepositoryProvider is used to provide repositories to the widget tree
      // it provided UserAuthRepository and StoreRepository
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<UserAuthRepository>.value(value: sl()),
          RepositoryProvider<StoreRepository>.value(value: sl()),
        ],
        // MultiBlocProvider is used to provide blocs to the widget tree
        // it provided BLoC instances to the widget tree.
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) {
                final bloc = AuthBloc(
                  // Gets the authRepository from the service locator
                  // Creates the AuthBloc with this repository
                  authRepository: sl(),
                );
                // Immediately adds an AuthCheckRequested event
                // to check if the user is already authenticated
                bloc.add(AuthCheckRequested());
                // Returns the bloc to be provided to the widget tree
                return bloc;
              },
            ),
            BlocProvider<StoreBloc>(
              create: (context) => StoreBloc(
                getStoresUseCase: sl(),
                storeRepository: sl(),
              ),
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

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SEMO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
        ),
        // Add platform-specific gesture settings
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      // this is set as the routing configuration
      // Based on the authentication state from the AuthBloc,
      // the router decides which screen to show first
      routerConfig: AppRouter.router,
    );
  }
}
