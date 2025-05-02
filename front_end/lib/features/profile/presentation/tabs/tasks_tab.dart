import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_icons.dart';
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
          SettingsSection(
            title: 'My Published Tasks',
            children: [
              SettingsTile(
                icon: AppIcons.postAdd(size: 24, color: Colors.red),
                title: 'Active Tasks',
                subtitle: 'Tasks currently open for applications',
                routeName: ProfileRouteNames.publishedTasks,
              ),
              SettingsTile(
                icon:
                    AppIcons.assignmentTurnedIn(size: 24, color: Colors.green),
                title: 'Completed Tasks',
                subtitle: 'Tasks that have been completed',
                routeName: ProfileRouteNames.publishedTasks,
              ),
              SettingsTile(
                icon: AppIcons.history(size: 24, color: Colors.grey[700]),
                title: 'Task History',
                subtitle: 'All tasks you\'ve published',
                routeName: ProfileRouteNames.publishedTasks,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Performed Tasks
          SettingsSection(
            title: 'My Performed Tasks',
            children: [
              SettingsTile(
                icon: AppIcons.engineering(size: 24, color: Colors.purple),
                title: 'Current Tasks',
                subtitle: 'Tasks you\'re currently working on',
                routeName: ProfileRouteNames.performedTasks,
              ),
              SettingsTile(
                icon: AppIcons.checkCircle(size: 24, color: Colors.green),
                title: 'Completed Tasks',
                subtitle: 'Tasks you\'ve finished',
                routeName: ProfileRouteNames.performedTasks,
              ),
              SettingsTile(
                icon: AppIcons.history(size: 24, color: Colors.grey[700]),
                title: 'Task History',
                subtitle: 'All tasks you\'ve performed',
                routeName: ProfileRouteNames.performedTasks,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Task Preferences
          SettingsSection(
            title: 'Preferences',
            children: [
              SettingsTile(
                icon: AppIcons.star(size: 24, color: Colors.amber),
                title: 'Skills & Categories',
                subtitle: 'Set your skills and preferred task types',
                routeName: ProfileRouteNames.taskPreferencesSkills,
              ),
              SettingsTile(
                icon: AppIcons.notifications(size: 24, color: Colors.orange),
                title: 'Task Notifications',
                subtitle: 'Configure task alerts and updates',
                routeName: ProfileRouteNames.taskPreferencesNotifications,
              ),
              SettingsTile(
                icon: AppIcons.visibility(size: 24, color: Colors.blue),
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
              _buildStatItem('12', 'Published',
                  AppIcons.postAdd(size: 24, color: Colors.white)),
              _buildStatItem('8', 'Performed',
                  AppIcons.engineering(size: 24, color: Colors.white)),
              _buildStatItem('4.8', 'Rating',
                  AppIcons.star(size: 24, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Widget icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: icon,
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
