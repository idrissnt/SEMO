import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_event.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_state.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';
import 'package:semo/features/auth/presentation/widgets/welcom/components/task_content_builder.dart';
import 'package:semo/features/auth/presentation/widgets/welcom/showcases/task_showcase_grid.dart';

final AppLogger logger = AppLogger();

/// Builds a task showcase card using the staggered grid layout
Widget buildTaskCard(BuildContext context) {
  return Card(
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(33.0)),
    child: SizedBox(
      width: context.responsiveItemSize(300),
      child: BlocBuilder<WelcomeAssetsBloc, WelcomeAssetsState>(
        builder: (context, state) {
          // Handle different state types directly
          if (state is TaskAssetLoaded && state.taskAssets.isNotEmpty) {
            // Successfully loaded with task assets

            // data preparation
            final data = TaskContentBuilder.build(context, state.taskAssets);

            return TaskCardShowcaseGrid(
              titleText: data['titleText'],
              mainCards: data['mainCards'],
              backgroundImages: data['backgroundImages'],
              backgroundColor: Colors.white,
              textColor: Colors.black,
              padding: const EdgeInsets.all(16.0),
            );
          } else if (state is TaskAssetLoaded) {
            // Loaded but empty
            logger.info('Task assets loaded but empty');
            return const Center(
              child: Text('task assets coming soon...',
                  style: TextStyle(color: Colors.black)),
            );
          } else if (state is TaskAssetLoading || state is AllAssetsLoading) {
            // Loading state
            logger.info('Task assets loading...');
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blue),
                  SizedBox(height: 16),
                  Text('Loading assets...',
                      style: TextStyle(color: Colors.black)),
                ],
              ),
            );
          } else {
            // Error or other states
            logger.info('Unknown state: ${state.runtimeType}');
            _scheduleRetryLoad(context);

            // Create a placeholder grid
            return const TaskCardShowcaseGrid(
              titleText: 'Loading content...',
              backgroundColor: Colors.white,
              textColor: Colors.black,
              padding: EdgeInsets.all(16.0),
              mainCards: [],
              backgroundImages: [],
            );
          }
        },
      ),
    ),
  );
}

/// Schedules a retry for loading task assets
void _scheduleRetryLoad(BuildContext context) {
  Future.delayed(const Duration(seconds: 3), () {
    if (context.mounted) {
      context.read<WelcomeAssetsBloc>().add(const LoadTaskAssetEvent());
    }
  });
}
