import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Still needed for BlocProvider in initState
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/utils/logger.dart';

import 'package:semo/features/home/presentation/bloc/home_store/home_store_bloc.dart';
import 'package:semo/features/home/presentation/bloc/home_store/home_store_event.dart';
import 'package:semo/features/home/presentation/bloc/home_store/home_store_state.dart';

import 'package:semo/features/home/presentation/bloc/user_address/user_address_bloc.dart';
import 'package:semo/features/home/presentation/bloc/user_address/user_address_event.dart';

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

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _initScrollAnimation();
  }

  /// Initialize data loading
  void _loadInitialData() {
    try {
      logger.debug('HomeScreen: Loading data');
      context.read<HomeStoreBloc>().add(const LoadAllStoreBrandsEvent());
      context.read<HomeUserAddressBloc>().add(const HomeGetUserAddressEvent());
    } catch (e) {
      logger.error('Error in HomeScreen._loadInitialData', error: e);
    }
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
            // Use the extracted HomeAppBar widget
            HomeAppBar(
              isScrolled: _isScrolled,
              scrollController: _scrollController,
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
                    // Main content
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
