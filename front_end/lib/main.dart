// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/features/auth/bloc/auth_bloc.dart';
import 'package:semo/features/auth/bloc/auth_event.dart';
import 'package:semo/features/auth/domain/repositories/auth_repository.dart';
import 'core/config/router_services/app_router.dart';
import 'core/di/injection_container.dart'; //sl = service locator
import 'core/theme/theme_services/app_colors.dart';
import 'core/utils/logger.dart';
import 'domain/repositories/store/store_repository.dart';
import 'presentation/blocs/store/store_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize dependencies
    await initializeDependencies();
    final logger = sl<AppLogger>();
    await logger.initialize();

    logger.debug('Dependencies initialized successfully');

    // Initialize service locator
    runApp(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<UserAuthRepository>.value(value: sl()),
          RepositoryProvider<StoreRepository>.value(value: sl()),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) {
                final bloc = AuthBloc(
                  authRepository: sl(),
                );
                bloc.add(AuthCheckRequested());
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
      routerConfig: AppRouter.router,
    );
  }
}
