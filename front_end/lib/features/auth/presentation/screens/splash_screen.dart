import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/routes_constants/route_constants.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/auth/domain/entities/welcom_entity.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_bloc.dart';
import 'package:semo/features/auth/presentation/widgets/for_welcome/screen_display_struture/company_showcase.dart';
import 'package:semo/features/auth/presentation/widgets/state_handler/welcom/state_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // The blocs are already initialized in main.dart
    // Just start navigation check after a delay
    _checkAuthAndNavigate();
  }

  // Flag to track if we've already navigated
  bool _hasNavigated = false;

  @override
  void dispose() {
    // Clean up any resources
    _hasNavigated = true;
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for assets to load and minimum splash time
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    // Get the current auth state
    final authState = context.read<AuthBloc>().state;

    // If we already have a definitive state, navigate immediately
    if (authState is AuthAuthenticated) {
      _navigateToHome();
      return;
    } else if (authState is AuthUnauthenticated) {
      _navigateToWelcome();
      return;
    }

    // Otherwise, wait for the auth state to change
    context.read<AuthBloc>().stream.listen((state) {
      // Only navigate if we haven't already and the widget is still mounted
      if (!_hasNavigated) {
        if (state is AuthAuthenticated) {
          _navigateToHome();
        } else if (state is AuthUnauthenticated) {
          _navigateToWelcome();
        }
      }
    });
  }

  void _navigateToHome() {
    if (mounted && !_hasNavigated) {
      _hasNavigated = true;
      context.go(AppRoutes.home);
    }
  }

  void _navigateToWelcome() {
    if (mounted && !_hasNavigated) {
      _hasNavigated = true;
      context.go(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use the WelcomeStateHandler to handle different states
            WelcomeStateHandler.handleWelcomeAssetsState<CompanyAsset>(
              context: context,
              state: context.watch<WelcomeAssetsBloc>().state,
              loadingMessage: 'Chargement...',
              // Extract just the company asset from the loaded state
              dataSelector: (loadedState) => loadedState.companyAsset,
              // When data is loaded, display the company logo
              onSuccess: (companyAsset) {
                return CompanyShowcase(
                  companyLogo: companyAsset.logoUrl,
                  companyName: companyAsset.companyName,
                );
              },
            ),

            SizedBox(height: 30.h),
            const CircularProgressIndicator(color: AppColors.secondary),
            SizedBox(height: 20.h),
            Text(
              'Chargement de l\'app...',
              style: TextStyle(
                color: AppColors.textSecondaryColor,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
