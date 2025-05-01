import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/profile/presentation/tabs/account_tab.dart';
import 'package:semo/features/profile/presentation/tabs/tasks_tab.dart';
import 'package:semo/features/profile/presentation/tabs/grocery_tab.dart';
import 'package:semo/features/profile/presentation/tabs/settings_tab.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> _tabs = const [
    Tab(text: 'Account', icon: Icon(Icons.person_outline)),
    Tab(text: 'Tasks', icon: Icon(Icons.assignment_outlined)),
    Tab(text: 'Grocery', icon: Icon(Icons.shopping_bag_outlined)),
    Tab(text: 'Settings', icon: Icon(Icons.settings_outlined)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: const Text('Profile'),
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimaryColor,
            elevation: 0,
            floating: true,
            pinned: true,
            snap: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(150),
              child: Column(
                children: [
                  // Profile Header
                  _buildProfileHeader(context),
                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    tabs: _tabs,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    unselectedLabelStyle:
                        const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: const [
            // Account Tab
            AccountTab(),
            // Tasks Tab
            TasksTab(),
            // Grocery Tab
            GroceryTab(),
            // Settings Tab
            SettingsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Profile Picture
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/images/default_profile.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // User Name
          const Text(
            'John Doe',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          // User Email
          Text(
            'john.doe@example.com',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          // User Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem('4.8', 'Rating'),
              _buildDivider(),
              _buildStatItem('24', 'Tasks'),
              _buildDivider(),
              _buildStatItem('18', 'Deliveries'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey[300],
    );
  }

  // Logout button moved to AccountTab
}
