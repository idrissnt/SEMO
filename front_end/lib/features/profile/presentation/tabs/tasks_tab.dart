import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/profile/presentation/widgets/settings_section.dart';
import 'package:semo/features/profile/presentation/widgets/settings_tile.dart';
import 'package:semo/features/profile/routes/profile_routes_const.dart';

/// Tab for task-related settings and history
class TasksTab extends StatelessWidget {
  const TasksTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task Statistics
          _buildTaskStatistics(),

          const SizedBox(height: 24),

          // Published Tasks
          const SettingsSection(
            title: 'My Published Tasks',
            children: [
              SettingsTile(
                icon: Icons.post_add_outlined,
                title: 'Active Tasks',
                subtitle: 'Tasks currently open for applications',
                routeName: ProfileRouteNames.publishedTasks,
              ),
              SettingsTile(
                icon: Icons.assignment_turned_in_outlined,
                title: 'Completed Tasks',
                subtitle: 'Tasks that have been completed',
                routeName: ProfileRouteNames.publishedTasks,
              ),
              SettingsTile(
                icon: Icons.history_outlined,
                title: 'Task History',
                subtitle: 'All tasks you\'ve published',
                routeName: ProfileRouteNames.publishedTasks,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Performed Tasks
          const SettingsSection(
            title: 'My Performed Tasks',
            children: [
              SettingsTile(
                icon: Icons.engineering_outlined,
                title: 'Current Tasks',
                subtitle: 'Tasks you\'re currently working on',
                routeName: ProfileRouteNames.performedTasks,
              ),
              SettingsTile(
                icon: Icons.check_circle_outline,
                title: 'Completed Tasks',
                subtitle: 'Tasks you\'ve finished',
                routeName: ProfileRouteNames.performedTasks,
              ),
              SettingsTile(
                icon: Icons.history_outlined,
                title: 'Task History',
                subtitle: 'All tasks you\'ve performed',
                routeName: ProfileRouteNames.performedTasks,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Task Preferences
          const SettingsSection(
            title: 'Preferences',
            children: [
              SettingsTile(
                icon: Icons.star_outline,
                title: 'Skills & Categories',
                subtitle: 'Set your skills and preferred task types',
                routeName: ProfileRouteNames.taskPreferencesSkills,
              ),
              SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Task Notifications',
                subtitle: 'Configure task alerts and updates',
                routeName: ProfileRouteNames.taskPreferencesNotifications,
              ),
              SettingsTile(
                icon: Icons.visibility_outlined,
                title: 'Visibility Settings',
                subtitle: 'Control who can see your task activity',
                routeName: ProfileRouteNames.taskPreferencesVisibility,
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTaskStatistics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Task Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('12', 'Published', Icons.upload_outlined),
              _buildStatItem('8', 'Performed', Icons.engineering_outlined),
              _buildStatItem('4.8', 'Rating', Icons.star_outline),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0x1A008000), // AppColors.primary with 10% opacity
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
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
    );
  }
}
