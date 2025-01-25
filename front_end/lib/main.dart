// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/routes.dart';
import 'core/config/theme.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/store_repository_impl.dart';
import 'data/repositories/recipe_repository_impl.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/get_home_data_usecase.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/auth/auth_state.dart';
import 'presentation/blocs/home/home_bloc.dart';
import 'presentation/screens/auth/login_screen.dart';
// import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/main/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  final client = http.Client();
  const secureStorage = FlutterSecureStorage();

  // Initialize repositories
  final authRepository = AuthRepositoryImpl(
    client: client,
    storage: secureStorage,
  );
  final storeRepository = StoreRepositoryImpl(client: client);
  final recipeRepository = RecipeRepositoryImpl(client: client);
  final productRepository = ProductRepositoryImpl(client: client);

  // Initialize use case
  final getHomeDataUseCase = GetHomeDataUseCase(
    storeRepository: storeRepository,
    recipeRepository: recipeRepository,
    productRepository: productRepository,
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<http.Client>.value(value: client),
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<StoreRepositoryImpl>.value(value: storeRepository),
        RepositoryProvider<RecipeRepositoryImpl>.value(value: recipeRepository),
        RepositoryProvider<ProductRepositoryImpl>.value(
            value: productRepository),
        RepositoryProvider<GetHomeDataUseCase>.value(value: getHomeDataUseCase),
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
          BlocProvider<HomeBloc>(
            create: (context) => HomeBloc(
              getHomeDataUseCase: context.read<GetHomeDataUseCase>(),
            ),
          ),
        ],
        child: MyApp(hasSeenOnboarding: hasSeenOnboarding),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const MyApp({
    Key? key,
    required this.hasSeenOnboarding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SEMO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppTheme.primaryColor,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: AppTheme.primaryColor),
          titleTextStyle: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      initialRoute: hasSeenOnboarding ? AppRoutes.login : AppRoutes.onboarding,
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
  }
}
