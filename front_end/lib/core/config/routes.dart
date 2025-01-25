import 'package:flutter/material.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/welcome_screen.dart';
import '../../presentation/screens/main/main_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/mission/mission_screen.dart';
import '../../presentation/screens/earn/earn_screen.dart';
import '../../presentation/screens/message/message_screen.dart';
import '../../presentation/screens/semo_ai/semo_ai_screen.dart';

class AppRoutes {
  static const String initial = '/welcome';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String profile = '/profile';
  static const String mission = '/mission';
  static const String earn = '/earn';
  static const String message = '/message';
  static const String semoAi = '/semo-ai';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case mission:
        return MaterialPageRoute(builder: (_) => const MissionScreen());
      case earn:
        return MaterialPageRoute(builder: (_) => const EarnScreen());
      case message:
        return MaterialPageRoute(builder: (_) => const MessageScreen());
      case semoAi:
        return MaterialPageRoute(builder: (_) => const SemoAIScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
  
  static Map<String, WidgetBuilder> get routes => {
    onboarding: (context) => const OnboardingScreen(),
    welcome: (context) => const WelcomeScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    main: (context) => const MainScreen(),
    profile: (context) => const ProfileScreen(),
    mission: (context) => const MissionScreen(),
    earn: (context) => const EarnScreen(),
    message: (context) => const MessageScreen(),
    semoAi: (context) => const SemoAIScreen(),
  };
}
