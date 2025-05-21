import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/widgets/common_widgets/section_separator.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/order/domain/models/order_status.dart';
import 'package:semo/features/order/presentation/bottom_sheets/address_app_bar/address_bottom_sheet.dart';

import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:semo/features/order/presentation/bottom_sheets/after_register/verify_email_screen.dart';
import 'package:semo/features/order/presentation/test_date/popular_products_copy.dart';
import 'package:semo/features/order/presentation/test_date/store.dart';

// Import extracted widgets
import 'package:semo/features/order/presentation/widgets/app_bar/order_app_bar.dart';
import 'package:semo/features/order/presentation/widgets/sections/store_section.dart';
import 'package:semo/features/order/presentation/widgets/promotions/first_order_banner.dart';
import 'package:semo/features/order/presentation/widgets/products/popular_products_section.dart';
import 'package:semo/features/order/presentation/widgets/order_tracking_card.dart';
import 'package:semo/features/order/presentation/widgets/order_view_toggle.dart';
import 'package:semo/features/store/domain/entities/store.dart';

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

  // Page controller for switching between promo and order tracking
  late PageController _pageController;

  // Sample order status for demonstration
  late OrderStatus _sampleOrderStatus;

  // Sample data for popular products
  late List<StoreBrand> _storesWithPopularProducts;
  // Scroll progress value from 0.0 (not scrolled) to 1.0 (fully scrolled)
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize page controller
    _pageController = PageController(initialPage: 0);

    // add listener to scroll controller
    _scrollController.addListener(_onScroll);
    // Initialize sample data
    _storesWithPopularProducts = StoreWithCategoryProducts.getMockStoreBrands();

    // Initialize sample order status
    _sampleOrderStatus = OrderStatus(
      orderId: 'ORD-12345',
      currentStage: OrderStage.confirmed,
      estimatedDeliveryTime: DateTime.now().add(const Duration(minutes: 30)),
      storeName: 'E.Leclerc',
      storeLogo: stores.first.imageLogo,
    );

    // Check email verification status after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkEmailVerificationStatus();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Instead of a binary state, calculate a progress value between 0 and 1
    // based on scroll position between 0 and 100
    final scrollProgress = (_scrollController.offset / 100).clamp(0.0, 1.0);

    // Update the state regardless of threshold to get smooth animation
    setState(() {
      // For binary state changes (when needed)
      _isScrolled = scrollProgress > 0.5;

      // Store the scroll progress for smooth animations
      _scrollProgress = scrollProgress;
    });
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

  // For testing the first-time user banner
  bool get _isFirstTimeUser => false;
  bool get _isOrderTracking => true;

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
                scrollProgress: _scrollProgress,
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

  /// Builds the main content of the order screen
  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order and promo section
        if (_buildDynamicPages().isNotEmpty) _buildPromotionAndOrderSection(),

        // Store section
        StoreSection(
          title: 'Choisissez un magasin',
          stores: stores,
        ),
        const SectionSeparator(),

        // Popular products sections for each store
        ..._buildPopularProductsSections(),
        const SectionSeparator(),
      ],
    );
  }

  /// Builds the promotion and order tracking section with PageView
  Widget _buildPromotionAndOrderSection() {
    final List<Widget> pages = _buildDynamicPages();

    return Column(
      children: [
        // PageView for switching between promo and order tracking
        SizedBox(
          height: 170, // Adjust height as needed
          child: PageView(
            controller: _pageController,
            children: pages,
          ),
        ),

        // Only show pagination indicators if there's more than one page
        if (pages.length > 1)
          Center(
            child: buildPaginationIndicators(
              context,
              _pageController,
              pages.length,
            ),
          ),
      ],
    );
  }

  /// Builds the list of pages for the PageView dynamically based on conditions
  List<Widget> _buildDynamicPages() {
    final List<Widget> pages = [];

    // Add promotional banner if user is eligible
    if (_isFirstTimeUser) {
      pages.add(_buildPromotionalBanner());
    }

    // Add order tracking if there's an active order
    if (_isOrderTracking) {
      pages.add(_buildOrderTrackingCard());
    }

    return pages;
  }

  /// Builds the promotional banner widget
  Widget _buildPromotionalBanner() {
    return const FirstOrderBanner(
      promotionText: 'Livraison gratuite pour vos 3 premières commandes!',
    );
  }

  /// Builds the order tracking card widget
  Widget _buildOrderTrackingCard() {
    return OrderTrackingCard(
      orderStatus: _sampleOrderStatus,
      onExpandDetails: _showOrderDetails,
    );
  }

  /// Build popular products sections for all stores
  List<Widget> _buildPopularProductsSections() {
    List<Widget> sections = [];

    for (var storeWithProducts in _storesWithPopularProducts) {
      sections.add(PopularProductsSection(
        storeWithProducts: storeWithProducts,
      ));

      sections.add(const SectionSeparator());
    }

    return sections;
  }

  // Show order details - this would be expanded in a real implementation
  void _showOrderDetails() {
    // This could show a bottom sheet with more details or navigate to a detailed order screen
    logger.debug('Showing order details');

    // For demonstration purposes, we'll just update the order stage
    // In a real app, this would be connected to backend data
    setState(() {
      // Cycle through order stages for demonstration
      final currentIndex = _sampleOrderStatus.currentStage.index;
      final nextIndex = (currentIndex + 1) % OrderStage.values.length;
      final store = stores.first;

      _sampleOrderStatus = OrderStatus(
        orderId: _sampleOrderStatus.orderId,
        currentStage: OrderStage.values[nextIndex],
        estimatedDeliveryTime: _sampleOrderStatus.estimatedDeliveryTime,
        storeName: _sampleOrderStatus.storeName,
        storeLogo: store.imageLogo,
      );
    });
  }
}
