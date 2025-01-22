// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_config.dart';
import 'core/config/theme.dart';
import 'core/config/routes.dart';
import 'core/di/service_locator.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/auth/auth_state.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize service locator
  await setupServiceLocator();

  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  // Initialize logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint(
      '${record.level.name}: ${record.time}: '
      '${record.loggerName}: '
      '${record.message}',
    );
  });

  if (!kDebugMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) {
            print('Creating AuthBloc and triggering auth check');
            final bloc = getIt<AuthBloc>();
            // Explicitly trigger auth check
            bloc.add(AuthCheckRequested());
            return bloc;
          },
        ),
      ],
      child: MyApp(hasSeenOnboarding: hasSeenOnboarding),
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
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          print('Current AuthState: $state');

          // Show splash screen while checking authentication
          if (state is AuthInitial || state is AuthLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // If authenticated, show home screen
          if (state is AuthAuthenticated) {
            print('User is authenticated, showing home screen');
            return const HomeScreen();
          }

          // Otherwise show login or onboarding
          print('User is not authenticated, showing login/onboarding');
          return hasSeenOnboarding
              ? const LoginScreen()
              : const OnboardingScreen();
        },
      ),
      routes: AppRoutes.routes,
    );
  }
}
