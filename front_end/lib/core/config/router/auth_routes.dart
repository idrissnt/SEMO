import 'package:go_router/go_router.dart';

import '../../../presentation/screens/auth/login_screen.dart';
import '../../../presentation/screens/auth/register_screen.dart';
import '../../../presentation/screens/auth/welcome_screen.dart';
import '../../../presentation/screens/onboarding/onboarding_screen.dart';

List<RouteBase> getAuthRoutes() {
  return [
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/main',
      redirect: (context, state) => '/',
    ),
  ];
}
