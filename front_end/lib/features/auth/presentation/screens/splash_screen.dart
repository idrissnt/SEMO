import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:semo/core/presentation/theme/app_colors.dart';

import 'package:semo/features/auth/domain/entities/welcom_entity.dart';

import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_bloc.dart';
import 'package:semo/features/auth/presentation/constants/auth_constants.dart';
import 'package:semo/features/auth/presentation/coordinators/auth_flow_coordinator.dart';

import 'package:semo/features/auth/presentation/utils/init_elements.dart';
import 'package:semo/features/auth/presentation/widgets/shared/background.dart';
import 'package:semo/features/auth/presentation/state_handler/welcom/state_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Get the AuthFlowCoordinator instance
    final authCoordinator = context.read<AuthFlowCoordinator>();

    // // Ensure minimum splash display time
    // await Future.delayed(
    //     const Duration(milliseconds: AuthConstants.splashDuration));

    if (!mounted) return;

    // Let the AuthFlowCoordinator handle navigation
    // This centralizes all auth-based navigation logic
    authCoordinator.handleSplashNavigation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          CustomPaint(
            painter: AuthBackgroundPainter(),
            size: Size.infinite,
          ),
          // Use the WelcomeStateHandler to handle different states
          SafeArea(
            child: WelcomeStateHandler.handleWelcomeAssetsState<CompanyAsset>(
              context: context,
              state: context.watch<WelcomeAssetsBloc>().state,
              loadingMessage: AuthConstants.splashLoadingMessageBeforeData,
              // Extract just the company asset from the loaded state
              dataSelector: (loadedState) => loadedState.companyAsset,
              // When data is loaded, display the company logo
              onSuccess: (companyAsset) {
                return InitialScreenElement(
                  companyLogo: companyAsset.logoUrl,
                  companyName: companyAsset.companyName,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
