import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/widgets/common_widgets/section_separator.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/order/presentation/bottom_sheets/address_app_bar/address_bottom_sheet.dart';

import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:semo/features/order/presentation/bottom_sheets/after_register/verify_email_screen.dart';
import 'package:semo/features/order/presentation/test_date/recipe.dart';
import 'package:semo/features/order/presentation/test_date/store.dart';
import 'package:semo/features/order/presentation/test_date/popular_products.dart';

// Import extracted widgets
import 'package:semo/features/order/presentation/widgets/helpers/scroll_animation_helper.dart';
import 'package:semo/features/order/presentation/widgets/app_bar/order_app_bar.dart';
import 'package:semo/features/order/presentation/widgets/sections/store_section.dart';
import 'package:semo/features/order/presentation/widgets/promotions/first_order_banner.dart';
import 'package:semo/features/order/presentation/widgets/products/popular_products_section.dart';
import 'package:semo/features/order/presentation/widgets/sections/weekly_recipes_section.dart';

final AppLogger logger = AppLogger();

class OrderScreen extends StatefulWidget {
  const OrderScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _checkedEmailVerification = false;

  // Sample data for popular products
  late List<StoreWithCategoryProducts> _storesWithPopularProducts;

  @override
  void initState() {
    super.initState();
    _initScrollAnimation();
    logger.debug('OrderScreen: Initialized');

    // Initialize sample data
    _storesWithPopularProducts = getSampleStoresWithCategoryProducts();

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
    logger.debug('OrderScreen: Checking email verification status');

    // Check if we have an explicit email verification request state
    if (authState is AuthEmailVerificationRequested) {
      logger.info(
          'OrderScreen: Email verification requested, showing bottom sheet');
      showVerifyEmailBottomSheet(context);
      _checkedEmailVerification = true;
    }
    // Check if the user needs email verification based on the flag
    else if (authState is AuthAuthenticated &&
        authState.user.needsEmailVerification) {
      logger.info(
          'OrderScreen: User needs email verification, showing bottom sheet');
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
              'OrderScreen: Email verification state detected, showing bottom sheet');
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
              OrderAppBar(
                isScrolled: _isScrolled,
                onLocationTap: () => showAddressBottomSheet(context),
              ),
              const SizedBox(height: 8),

              // Main content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
    // In a real implementation, we would check the user's order count
    // Here we're using a flag for demonstration purposes

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First-time user promotion banner
        if (_isFirstTimeUser)
          const FirstOrderBanner(
            promotionText: 'Livraison gratuite pour vos 3 premières commandes!',
          ),

        // Store section
        StoreSection(
          title: 'Choisissez un magasin',
          // title: 'Passez vos commandes',
          stores: stores,
        ),
        const SectionSeparator(),

        // Popular products sections for each store
        ..._buildPopularProductsSections(),
        const SectionSeparator(),
        WeeklyRecipesSection(
          title: 'Nos recettes de la semaine',
          recipes: getSampleRecipes(),
        ),
        const SectionSeparator(),
      ],
    );
  }

  /// Build popular products sections for all stores
  List<Widget> _buildPopularProductsSections() {
    List<Widget> sections = [];

    for (var storeWithProducts in _storesWithPopularProducts) {
      // Convert PopularProduct objects to maps
      final productMaps =
          storeWithProducts.products.map((product) => product.toMap()).toList();

      sections.add(
        PopularProductsSection(
          sectionTitle: storeWithProducts.category,
          storeName: storeWithProducts.name,
          storeLogo: storeWithProducts.logo,
          products: productMaps,
          onProductTap: (product) => _handleProductTap(product),
          onAddToCart: (product) => _handleAddToCart(product),
          onSeeAllTap: () => _navigateToStore(storeWithProducts.id),
        ),
      );

      sections.add(const SectionSeparator());
    }

    return sections;
  }

  /// Handle product tap
  void _handleProductTap(Map<String, dynamic> product) {
    logger.info('Product tapped: ${product['name']}');
    // Navigate to product detail page
    // This would typically use your router
  }

  /// Handle add to cart
  void _handleAddToCart(Map<String, dynamic> product) {
    logger.info('Add to cart: ${product['name']}');
    // Add product to cart
    // This would typically dispatch an event to a cart bloc

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['name']} ajouté au panier'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Navigate to store page
  void _navigateToStore(String storeId) {
    logger.info('Navigating to store: $storeId');
    // Navigate to store page
    // This would typically use your router
  }

  // For testing the first-time user banner
  bool get _isFirstTimeUser => true;
}
