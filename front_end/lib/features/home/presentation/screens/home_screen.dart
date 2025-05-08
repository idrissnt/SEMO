import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_constant.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/core/presentation/widgets/buttons/button_factory.dart';
import 'package:semo/core/presentation/widgets/common_widgets/section_separator.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/home/presentation/bottom_sheets/address_app_bar/address_bottom_sheet.dart';

import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:semo/features/home/presentation/bottom_sheets/after_register/verify_email_screen.dart';
import 'package:semo/features/home/presentation/test_date/cart.dart';
import 'package:semo/features/home/presentation/test_date/recipe.dart';
import 'package:semo/features/home/presentation/test_date/store.dart';
import 'package:semo/features/home/presentation/widgets/sections/delivery_section.dart';
import 'package:semo/features/home/presentation/widgets/sections/store_section.dart';
import 'package:semo/features/home/presentation/widgets/sections/weekly_recipes_section.dart';

// Import extracted widgets
import 'package:semo/features/home/presentation/helpers/scroll_animation_helper.dart';
import 'package:semo/features/home/presentation/widgets/app_bar/home_app_bar.dart';

final AppLogger logger = AppLogger();

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _checkedEmailVerification = false;

  @override
  void initState() {
    super.initState();
    _initScrollAnimation();
    logger.debug('HomeScreen: Initialized');

    // Check email verification status after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkEmailVerificationStatus();
    });
  }

  /// Initialize scroll animation helper
  void _initScrollAnimation() {
    // Create the animation helper directly without storing it as a field
    // since we only need its initialization logic
    ScrollAnimationHelper(
      scrollController: _scrollController,
      onScrollStateChanged: (isScrolled) {
        setState(() {
          _isScrolled = isScrolled;
        });
      },
    );
  }

  /// Check if the user needs email verification and show the bottom sheet if needed
  void _checkEmailVerificationStatus() {
    if (_checkedEmailVerification) return;

    final authState = context.read<AuthBloc>().state;
    logger.debug('HomeScreen: Checking email verification status');

    // Check if we have an explicit email verification request state
    if (authState is AuthEmailVerificationRequested) {
      logger.info(
          'HomeScreen: Email verification requested, showing bottom sheet');
      showVerifyEmailBottomSheet(context);
      _checkedEmailVerification = true;
    }
    // Check if the user needs email verification based on the flag
    else if (authState is AuthAuthenticated &&
        authState.user.needsEmailVerification) {
      logger.info(
          'HomeScreen: User needs email verification, showing bottom sheet');
      showVerifyEmailBottomSheet(context);
      _checkedEmailVerification = true;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthEmailVerificationRequested &&
            !_checkedEmailVerification) {
          logger.info(
              'HomeScreen: Email verification state detected, showing bottom sheet');
          showVerifyEmailBottomSheet(context);
          _checkedEmailVerification = true;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // App bar with animated elevation based on scroll
              HomeAppBar(
                isScrolled: _isScrolled,
                scrollController: _scrollController,
                onLocationTap: () => showAddressBottomSheet(context),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main content
                      _buildMainContent(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    // Add dummy content to make the screen scrollable for testing
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //
        // Store section
        StoreSection(
          title: 'Passez vos commandes',
          stores: stores,
        ),
        const SectionSeparator(),

        // Delivery section
        const SizedBox(height: 16),
        DeliverySection(
          title: 'Vous allez au magasin ? Prenez le panier de votre voisin',
          productsImagesList: productsImagesList,
          sectionSize: 180,
        ),
        const SectionSeparator(),

        // Weekly recipes section
        const SizedBox(height: 16),
        WeeklyRecipesSection(
          title: 'Nos recettes de la semaine',
          recipes: getSampleRecipes(),
        ),

        //
        ButtonFactory.createAnimatedButton(
          context: context,
          onPressed: () {
            showVerifyEmailBottomSheet(context);
          },
          text: 'Valider',
          backgroundColor: AppColors.primary,
          textColor: AppColors.secondary,
          splashColor: AppColors.primary,
          highlightColor: AppColors.primary,
          boxShadowColor: AppColors.primary,
          minWidth: AppButtonDimensions.minWidth,
          minHeight: AppButtonDimensions.minHeight,
          verticalPadding: AppDimensionsWidth.xSmall,
          horizontalPadding: AppDimensionsHeight.small,
          borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
          animationDuration:
              Duration(milliseconds: AppConstant.buttonAnimationDurationMs),
          enableHapticFeedback: true,
          textStyle: TextStyle(
            fontSize: AppFontSize.large,
            fontWeight: FontWeight.w800,
            color: AppColors.secondary,
          ),
        )
      ],
    );
  }
}
