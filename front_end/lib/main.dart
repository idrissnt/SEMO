// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'app.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  // Initialize logging
  Logger.root.level = Level.ALL; // Set to show all log levels
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    }
  });

  // Disable developer mode warnings in production
  if (!kDebugMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  runApp(
    MyApp(hasSeenOnboarding: hasSeenOnboarding),
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
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => AuthService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authService: context.read<AuthService>(),
            )..add(AuthCheckRequested()),
          ),
        ],
        child: MaterialApp(
          title: 'Flutter Auth Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          initialRoute: hasSeenOnboarding ? '/welcome' : '/onboarding',
          routes: {
            '/onboarding': (context) => const OnboardingScreen(),
            '/welcome': (context) => BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      return const HomeScreen();
                    }
                    return const WelcomeScreen();
                  },
                ),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      return const HomeScreen();
                    }
                    return const WelcomeScreen();
                  },
                ),
            '/profile': (context) => BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      return const ProfileScreen();
                    }
                    return const WelcomeScreen();
                  },
                ),
          },
        ),
      ),
    );
  }
}
