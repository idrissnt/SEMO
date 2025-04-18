import 'package:go_router/go_router.dart';

import '../../../../features/auth/presentation/screens/login_screen.dart';
import '../../../../features/auth/presentation/screens/register_screen.dart';
import '../../../../features/auth/presentation/screens/welcome_screen.dart';
import '../../../../features/onboarding/onboarding_screen.dart';
import 'route_constants.dart';

List<RouteBase> getAuthRoutes() {
  return [
    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.main,
      redirect: (context, state) => '/',
    ),
  ];
}
