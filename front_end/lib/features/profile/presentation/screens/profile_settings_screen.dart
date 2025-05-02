import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Core imports
import 'package:semo/core/presentation/theme/app_colors.dart';

// Feature imports
import 'package:semo/features/profile/presentation/tabs/account_tab.dart';
import 'package:semo/features/profile/presentation/tabs/tasks_tab.dart';
import 'package:semo/features/profile/presentation/tabs/grocery_tab.dart';
import 'package:semo/features/profile/presentation/tabs/settings_tab.dart';

/// A screen that displays user profile settings with multiple tabs for different sections.
///
/// This screen provides navigation to various profile-related settings through a tab interface.
class ProfileSettingsScreen extends StatefulWidget {
  /// Creates a profile settings screen.
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen>
    with SingleTickerProviderStateMixin {
  /// Controller for managing tab navigation
  late TabController _tabController;

  /// Tab configuration data
  static const List<_TabItem> _tabItems = [
    _TabItem(title: 'Account', icon: Icons.person_outline),
    _TabItem(title: 'Tasks', icon: Icons.assignment_outlined),
    _TabItem(title: 'Grocery', icon: Icons.shopping_basket_outlined),
    _TabItem(title: 'Settings', icon: Icons.settings_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabItems.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildHeaderSection(),
          _buildTabContent(),
        ],
      ),
    );
  }

  /// Builds the app bar with back button and title
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimaryColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.canPop(context)) {
                context.pop();
              } else {
                // Navigate to the home screen if we can't pop
                context.go('/');
              }
            },
          ),
          const Text(
            'User Name',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the header section containing profile image and tabs
  Widget _buildHeaderSection() {
    return Material(
      color: Colors.white,
      elevation: 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProfileHeader(context),
          const SizedBox(height: 4),
          _buildTabBar(),
        ],
      ),
    );
  }

  /// Builds the tab bar with custom styling
  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        tabs: _buildCustomTabs(),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black87,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// Builds the tab content area
  Widget _buildTabContent() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: const [
          AccountTab(),
          TasksTab(),
          GroceryTab(),
          SettingsTab(),
        ],
      ),
    );
  }

  /// Builds custom tabs with consistent styling
  List<Widget> _buildCustomTabs() {
    return _tabItems.map((item) => _buildTabItem(item)).toList();
  }

  /// Builds a single tab item with consistent styling
  Widget _buildTabItem(_TabItem item) {
    return SizedBox(
      height: 50,
      child: Tab(
        text: item.title,
        icon: Icon(item.icon, size: 24),
        iconMargin: const EdgeInsets.only(bottom: 2),
      ),
    );
  }

  /// Builds the profile header with avatar and edit button
  Widget _buildProfileHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Profile image
        CircleAvatar(
          radius: 36,
          backgroundColor: Colors.grey[200],
          backgroundImage:
              const AssetImage('assets/images/default_profile.png'),
          onBackgroundImageError: (exception, stackTrace) {},
          child: const Icon(
            Icons.person,
            size: 36,
            color: Colors.grey,
          ),
        ),
        // Edit button
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(3.0),
            child: Icon(
              Icons.edit,
              size: 12,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/// Data class to hold tab item configuration
class _TabItem {
  final String title;
  final IconData icon;

  const _TabItem({required this.title, required this.icon});
}
