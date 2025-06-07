import 'package:flutter/material.dart';

// Core imports
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_icons.dart';
import 'package:semo/core/utils/logger.dart';

// Feature imports
import 'package:semo/features/profile/presentation/tabs/account_tab.dart';
import 'package:semo/features/profile/presentation/tabs/grocery_tab.dart';
import 'package:semo/features/profile/presentation/tabs/settings_tab.dart';
import 'package:semo/features/profile/presentation/widgets/utils/edit_pic.dart';

/// A screen that displays user profile settings with multiple tabs for different sections.
///
/// This screen provides navigation to various profile-related settings through a tab interface.

final AppLogger logger = AppLogger();

class MainProfileScreen extends StatefulWidget {
  /// Creates a profile settings screen.
  const MainProfileScreen({Key? key}) : super(key: key);

  @override
  State<MainProfileScreen> createState() => _MainProfileScreenState();
}

class _MainProfileScreenState extends State<MainProfileScreen>
    with SingleTickerProviderStateMixin {
  /// Controller for managing tab navigation
  late TabController _tabController;

  /// Tab configuration data
  static final List<_TabItem> _tabItems = [
    _TabItem(
      title: 'Mon compte',
      iconBuilder: (color) => AppIcons.person(size: 24, color: color),
      originalColor: AppColors.primary,
    ),
    _TabItem(
      title: 'Commandes',
      iconBuilder: (color) => AppIcons.shoppingBagFill(size: 24, color: color),
      originalColor: Colors.orange,
    ),
    _TabItem(
      title: 'Paramètres',
      iconBuilder: (color) => AppIcons.settings(size: 24, color: color),
      originalColor: Colors.green,
    ),
  ];

  // Keep track of the current tab index and animation value
  int _currentIndex = 0;
  double _animationValue = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabItems.length, vsync: this);

    // Listen for tab changes and animation updates
    _tabController.animation!.addListener(() {
      setState(() {
        // Get the current animation value
        _animationValue = _tabController.animation!.value;
        // The integer part of the animation value is the current index
        _currentIndex = _tabController.animation!.value.floor();
      });
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeaderSection(),
            _buildTabContent(),
          ],
        ),
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
          Stack(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: _buildProfileHeader(context),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child:
                    _buildUserName(context, 'User Name kdahsijhbviuyjhaervzuv'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildTabBar(),
        ],
      ),
    );
  }

  /// Builds the profile header with avatar and edit button
  Widget _buildProfileHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Profile image
        InkWell(
          onTap: () {
            showImageSourceDialog(context, _hasExistingProfilePicture());
          },
          child: CircleAvatar(
            radius: 36,
            backgroundColor: Colors.grey[200],
            backgroundImage: const NetworkImage(''),
            onBackgroundImageError: (exception, stackTrace) {},
            child: const Icon(
              Icons.person,
              size: 36,
              color: Colors.grey,
            ),
          ),
        ),
        // Edit button
        InkWell(
          onTap: () {
            showImageSourceDialog(context, _hasExistingProfilePicture());
          },
          child: Container(
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
                Icons.camera_alt,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  //  build user name
  Widget _buildUserName(BuildContext context, String userName) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: SizedBox(
        width: 140,
        child: Text(
          userName,
          textAlign: TextAlign.start,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
          GroceryTab(),
          SettingsTab(),
        ],
      ),
    );
  }

  /// Builds custom tabs with consistent styling
  List<Widget> _buildCustomTabs() {
    return List.generate(
        _tabItems.length, (index) => _buildTabItem(_tabItems[index], index));
  }

  /// Builds a single tab item with consistent styling
  Widget _buildTabItem(_TabItem item, int index) {
    // Calculate color based on animation progress
    Color color;

    // Calculate the fraction part of the animation value
    final fraction = _animationValue - _animationValue.floor();

    if (index == _currentIndex) {
      // Current tab - blend from original color to white as animation progresses
      color = _blendColors(item.originalColor, Colors.white, 1.0 - fraction);
    } else if (index == _currentIndex + 1 && fraction > 0) {
      // Next tab - blend from original color to white as animation progresses
      color = _blendColors(item.originalColor, Colors.white, fraction);
    } else {
      // Other tabs - use original color
      color = item.originalColor;
    }

    return SizedBox(
      height: 50,
      child: Tab(
        text: item.title,
        icon: item.iconBuilder(color),
        iconMargin: const EdgeInsets.only(bottom: 2),
      ),
    );
  }

  /// Helper method to blend between two colors
  Color _blendColors(Color color1, Color color2, double ratio) {
    // Use Color.lerp which handles the properties correctly
    return Color.lerp(color1, color2, ratio) ?? color1;
  }
}

/// Data class to hold tab item configuration
class _TabItem {
  final String title;
  final Widget Function(Color) iconBuilder;
  final Color originalColor;

  const _TabItem(
      {required this.title,
      required this.iconBuilder,
      required this.originalColor});
}

bool _hasExistingProfilePicture() {
  // Check if user has a profile picture
  // This would typically check the user model
  return true; // Placeholder
}
