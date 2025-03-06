// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'core/config/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/utils/logger.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/store_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/store_repository.dart';
import 'domain/usecases/get_stores_usecase.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/store/store_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logger first
  final logger = AppLogger();
  await logger.initialize();

  try {
    // Initialize services
    logger.debug('Initializing other services');
    final client = http.Client();
    const secureStorage = FlutterSecureStorage();

    // Initialize repositories
    logger.debug('Initializing repositories');
    final authRepository = AuthRepositoryImpl(
      client: client,
      storage: secureStorage,
    );
    final storeRepository = StoreRepositoryImpl(
      client: client,
    );

    // Initialize service locator
    runApp(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<http.Client>.value(value: client),
          RepositoryProvider<AuthRepository>.value(value: authRepository),
          RepositoryProvider<StoreRepository>.value(value: storeRepository),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) {
                final bloc = AuthBloc(
                  authRepository: context.read<AuthRepository>(),
                );
                bloc.add(AuthCheckRequested());
                return bloc;
              },
            ),
            BlocProvider<StoreBloc>(
              create: (context) => StoreBloc(
                getStoresUseCase: GetStoresUseCase(
                  storeRepository: context.read<StoreRepository>(),
                ),
                storeRepository: context.read<StoreRepository>(),
              ),
            ),
          ],
          child: const MyApp(),
        ),
      ),
    );
  } catch (e, stackTrace) {
    logger.error('Error in main()', error: e, stackTrace: stackTrace);
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
