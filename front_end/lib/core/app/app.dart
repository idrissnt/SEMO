import 'package:flutter/material.dart';
import 'package:semo/core/presentation/navigation/router_services/app_router.dart';
import 'package:semo/core/presentation/theme/theme_services/app_colors.dart';

/// Root widget of the application
/// Configures the app theme and routing
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The router handles all navigation based on authentication state
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
      // this is set as the routing configuration
      // Based on the authentication state from the AuthBloc (take from the context),
      // the router decides which screen to show first
      routerConfig: AppRouter.router,
    );
  }
}
