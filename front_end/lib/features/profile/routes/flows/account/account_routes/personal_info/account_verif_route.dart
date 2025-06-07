import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/main_app_nav/app_routes/app_router.dart';
import 'package:semo/core/presentation/navigation/config/route_builder.dart'
    as app_routes;
import 'package:semo/features/profile/presentation/screens/account_screens/personal_informations/account_verification.dart';
import 'package:semo/features/profile/presentation/screens/account_screens/personal_informations/verification_screens/verification_screens.dart';
import 'package:semo/features/profile/routes/constant/account_route_const.dart';

/// Routes for account verification flow
class AccountVerifRoutes {
  /// Get all routes for the account verification flow
  static List<RouteBase> getRoutes() {
    return [
      // Account verification main route
      GoRoute(
        path: AccountRoutesConstants.accountVerification,
        name: AccountRouteNames.accountVerificationName,
        parentNavigatorKey: AppRouter.rootNavigatorKey,
        pageBuilder: _buildAccountVerifScreen,
        routes: [
          // Name verification route
          GoRoute(
            path: AccountRoutesConstants.nameVerification,
            name: AccountRouteNames.nameVerificationName,
            parentNavigatorKey: AppRouter.rootNavigatorKey,
            pageBuilder: _buildNameVerificationScreen,
          ),
          // Email verification route
          GoRoute(
            path: AccountRoutesConstants.emailVerification,
            name: AccountRouteNames.emailVerificationName,
            parentNavigatorKey: AppRouter.rootNavigatorKey,
            pageBuilder: _buildEmailVerificationScreen,
          ),
          // Phone verification route
          GoRoute(
            path: AccountRoutesConstants.phoneVerification,
            name: AccountRouteNames.phoneVerificationName,
            parentNavigatorKey: AppRouter.rootNavigatorKey,
            pageBuilder: _buildPhoneVerificationScreen,
          ),
          // ID card verification route
          GoRoute(
            path: AccountRoutesConstants.idCardVerification,
            name: AccountRouteNames.idCardVerificationName,
            parentNavigatorKey: AppRouter.rootNavigatorKey,
            pageBuilder: _buildIdCardVerificationScreen,
          ),
        ],
      ),
    ];
  }

  /// Build the account verification screen
  static Page<dynamic> _buildAccountVerifScreen(
    BuildContext context,
    GoRouterState state,
  ) {
    return app_routes.RouteBuilder.buildPage(
      context: context,
      state: state,
      child: const AccountVerificationScreen(),
      name: 'AccountVerificationScreen',
    );
  }

  /// Build the name verification screen
  static Page<dynamic> _buildNameVerificationScreen(
    BuildContext context,
    GoRouterState state,
  ) {
    return app_routes.RouteBuilder.buildPage(
      context: context,
      state: state,
      child: const NameVerificationScreen(),
      name: 'NameVerificationScreen',
    );
  }

  /// Build the email verification screen
  static Page<dynamic> _buildEmailVerificationScreen(
    BuildContext context,
    GoRouterState state,
  ) {
    return app_routes.RouteBuilder.buildPage(
      context: context,
      state: state,
      child: const EmailVerificationScreen(),
      name: 'EmailVerificationScreen',
    );
  }

  /// Build the phone verification screen
  static Page<dynamic> _buildPhoneVerificationScreen(
    BuildContext context,
    GoRouterState state,
  ) {
    return app_routes.RouteBuilder.buildPage(
      context: context,
      state: state,
      child: const PhoneVerificationScreen(),
      name: 'PhoneVerificationScreen',
    );
  }

  /// Build the ID card verification screen
  static Page<dynamic> _buildIdCardVerificationScreen(
    BuildContext context,
    GoRouterState state,
  ) {
    return app_routes.RouteBuilder.buildPage(
      context: context,
      state: state,
      child: const IdCardVerificationScreen(),
      name: 'IdCardVerificationScreen',
    );
  }
}
