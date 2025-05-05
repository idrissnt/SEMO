import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_constant.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/core/presentation/widgets/buttons/button_factory.dart';
import 'package:semo/core/utils/logger.dart';

import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:semo/features/home/presentation/bloc/home_store/home_store_bloc.dart';
import 'package:semo/features/home/presentation/bloc/home_store/home_store_state.dart';
import 'package:semo/features/home/presentation/full_screen_bottom_sheet/verify_email_bottom_sheet.dart';
import 'package:semo/features/home/routes/home_routes_constants.dart';

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
      _showVerifyEmailBottomSheet(context);
      _checkedEmailVerification = true;
    }
    // Check if the user needs email verification based on the flag
    else if (authState is AuthAuthenticated &&
        authState.user.needsEmailVerification) {
      logger.info(
          'HomeScreen: User needs email verification, showing bottom sheet');
      _showVerifyEmailBottomSheet(context);
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
          _showVerifyEmailBottomSheet(context);
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

  void _showVerifyEmailBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true, // Enable dragging to dismiss
      isDismissible: true, // Allow dismissing by tapping outside
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.98, // Start at 95% of screen height
        minChildSize: 0.5, // Allow dragging down to 50%
        maxChildSize: 0.98, // Maximum 95% of screen height
        expand: false,
        builder: (context, scrollController) =>
            VerifyEmailBottomSheet(scrollController: scrollController),
      ),
    );
  }

  Widget _buildMainContent() {
    // Add dummy content to make the screen scrollable for testing
    return BlocBuilder<HomeStoreBloc, HomeStoreState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Promotional banner
            Container(
              margin: const EdgeInsets.all(16),
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('Promotional Banner')),
            ),

            ButtonFactory.createAnimatedButton(
              context: context,
              onPressed: () {
                _showVerifyEmailBottomSheet(context);
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
            ),

            // Categories section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        final categoryId = 'cat_${index + 1}';
                        return GestureDetector(
                          onTap: () {
                            // Navigate to category details
                            logger.debug('Navigating to category: $categoryId');
                            context.go(
                                HomeRoutesConstants.getCategoryDetailsRoute(
                                    categoryId));
                          },
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.category,
                                  color: AppColors.primary,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Category ${index + 1}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Popular items section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Popular Items',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      final productId = 'popular_product_${index + 1}';
                      return GestureDetector(
                        onTap: () {
                          // Navigate to product details
                          logger.debug('Navigating to product: $productId');
                          context.go(HomeRoutesConstants.getProductDetailsRoute(
                              productId));
                        },
                        child: Container(
                          height: 100,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 100,
                                color: Colors.grey[300],
                                child: Center(
                                  child: Icon(
                                    Icons.shopping_bag,
                                    color: AppColors.primary,
                                    size: 32,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Product ${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Tap to view details',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey[400],
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
