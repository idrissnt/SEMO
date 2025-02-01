// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/routes.dart';
import 'core/theme/app_colors.dart';
import 'core/utils/logger.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/store_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/store_repository.dart';
import 'domain/usecases/get_stores_usecase.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/auth/auth_state.dart';
import 'presentation/blocs/store/store_bloc.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/main/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logger first
  final logger = AppLogger();
  await logger.initialize();

  try {
    // Initialize services
    logger.debug('Initializing other services');
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

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
                if (hasSeenOnboarding) {
                  bloc.add(AuthCheckRequested());
                }
                return bloc;
              },
            ),
            BlocProvider<StoreBloc>(
              create: (context) => StoreBloc(
                getStoresUseCase: GetStoresUseCase(
                  storeRepository: context.read<StoreRepository>(),
                ),
              ),
            ),
          ],
          child: MyApp(hasSeenOnboarding: hasSeenOnboarding),
        ),
      ),
    );
  } catch (e, stackTrace) {
    logger.error('Error during initialization: $e',
        error: e, stackTrace: stackTrace);
    // Re-throw to prevent app from starting in a broken state
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const MyApp({
    Key? key,
    required this.hasSeenOnboarding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      final logger = AppLogger();
      logger.debug('Building MyApp widget');

      return MaterialApp(
        title: 'SEMO',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primaryColor,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: AppColors.primaryColor),
            titleTextStyle: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        initialRoute:
            hasSeenOnboarding ? AppRoutes.login : AppRoutes.onboarding,
        onGenerateRoute: AppRoutes.generateRoute,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (!hasSeenOnboarding) {
              return const OnboardingScreen();
            }

            if (state is AuthAuthenticated) {
              return const MainScreen();
            }

            return const LoginScreen();
          },
        ),
      );
    } catch (e, stackTrace) {
      final logger = AppLogger();
      logger.error('Error building MyApp', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
