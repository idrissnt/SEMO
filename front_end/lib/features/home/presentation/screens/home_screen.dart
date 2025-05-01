import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/presentation/theme/theme_services/app_colors.dart';
import 'package:semo/core/presentation/theme/theme_services/app_dimensions.dart';
import 'package:semo/core/utils/logger.dart';

import 'package:semo/features/home/presentation/bloc/home_store/home_store_bloc.dart';
import 'package:semo/features/home/presentation/bloc/home_store/home_store_event.dart';
import 'package:semo/features/home/presentation/bloc/home_store/home_store_state.dart';

import 'package:semo/features/home/presentation/bloc/user_address/user_address_bloc.dart';
import 'package:semo/features/home/presentation/bloc/user_address/user_address_event.dart';
import 'package:semo/features/home/presentation/bloc/user_address/user_address_state.dart';

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
  // Threshold for when to collapse the app bar
  final double _scrollThreshold = 40.0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _setupScrollListener();
  }

  void _loadInitialData() {
    try {
      logger.debug('HomeScreen: Loading data');
      context.read<HomeStoreBloc>().add(const LoadAllStoreBrandsEvent());
      context.read<HomeUserAddressBloc>().add(const HomeGetUserAddressEvent());
    } catch (e) {
      logger.error('Error in HomeScreen._loadInitialData', error: e);
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // Check if we've scrolled past the threshold
      if (_scrollController.offset > _scrollThreshold && !_isScrolled) {
        setState(() {
          _isScrolled = true;
        });
      } else if (_scrollController.offset <= _scrollThreshold && _isScrolled) {
        setState(() {
          _isScrolled = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Animated app bar that collapses on scroll
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _isScrolled ? 60 : 120,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: _isScrolled
                    ? [
                        const BoxShadow(
                          color: AppColors.appBarShadowColor,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: _buildAppBar(),
              ),
            ),
            // Space between app bar and content
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main content will go here
                    _buildMainContent(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      // padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Location row with animated opacity
          AnimatedOpacity(
            opacity: _isScrolled ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            // Start fading out earlier than other animations
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isScrolled ? 0 : 50,
              padding:
                  EdgeInsets.symmetric(horizontal: AppDimensionsWidth.medium),
              child: _isScrolled
                  ? const SizedBox.shrink()
                  : Row(
                      children: [
                        // Location section
                        _buildLocationSection(),
                        const Spacer(),
                        // Action icons
                        _buildActionIcons(),
                      ],
                    ),
            ),
          ),
          // Add spacing only when showing the location row
          if (!_isScrolled) const SizedBox(height: 8),
          // Search bar row - with cart icon when scrolled
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: AppDimensionsWidth.medium),
            child: Row(
              children: [
                // Search bar takes most of the space
                Expanded(
                  child: _buildSearchBar(),
                ),
                // Animated cart icon with fade in/out
                AnimatedOpacity(
                  opacity: _isScrolled ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _isScrolled ? null : 0,
                    padding: EdgeInsets.only(left: _isScrolled ? 4 : 0),
                    child: _isScrolled
                        ? _buildCartProfileIcon()
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return BlocBuilder<HomeUserAddressBloc, HomeUserAddressState>(
      builder: (context, state) {
        // Default address text from screenshot
        String addressText = '1226 UniverS ofui uibr iubert uib';

        // Update with actual address if available
        if (state is HomeUserAddressLoaded) {
          final address = state.address;
          // Format the address - assuming these fields are non-nullable
          addressText = '${address.streetNumber} ${address.streetName}';
        }

        return Row(
          // Set mainAxisSize to min to prevent unbounded width error
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_outlined, color: Colors.grey[800]),
            const SizedBox(width: 2),
            // Use a fixed width container instead of Flexible
            SizedBox(
              width: 100, // Fixed width instead of flexible
              child: Text(
                addressText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey[800]),
          ],
        );
      },
    );
  }

  Widget _buildActionIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Use SizedBox with negative width to reduce spacing
        Padding(
          padding: const EdgeInsets.only(right: 0),
          child: IconButton(
            icon: Icon(Icons.shopping_cart_outlined,
                color: Colors.grey[800], size: 26),
            onPressed: () {
              // Handle cart tap
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            iconSize: 26,
            visualDensity: const VisualDensity(horizontal: -2, vertical: 0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 0),
          child: IconButton(
            icon: Icon(Icons.notifications_none_outlined,
                color: Colors.grey[800], size: 26),
            onPressed: () {
              // Handle notifications tap
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            iconSize: 26,
            visualDensity: const VisualDensity(horizontal: -2, vertical: 0),
          ),
        ),
        IconButton(
          icon: Icon(Icons.person_outline, color: Colors.grey[800], size: 26),
          onPressed: () {
            // Handle profile tap
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          iconSize: 26,
          visualDensity: const VisualDensity(horizontal: -2, vertical: 0),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      // Animate width changes
      width: _isScrolled ? double.infinity : double.infinity,
      // No margin to avoid overflow
      child: Row(
        children: [
          // Animated icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.zero,
            child: Icon(Icons.search, color: Colors.grey[600]),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              style: const TextStyle(fontSize: 16),
              onChanged: (query) {
                if (query.length >= 2) {
                  // Handle search query
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartProfileIcon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, size: 26),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                // Handle cart tap
              },
            ),
            // Cart badge
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Text(
                '1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 0),
        IconButton(
          icon: Icon(Icons.person_outline, color: Colors.grey[800], size: 26),
          onPressed: () {
            // Handle profile tap
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        )
      ],
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
                        return Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(child: Text('Category ${index + 1}')),
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
                      return Container(
                        height: 100,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(child: Text('Item ${index + 1}')),
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
