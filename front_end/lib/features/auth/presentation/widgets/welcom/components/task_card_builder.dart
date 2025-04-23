import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_event.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_state.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';
import 'package:semo/features/auth/presentation/widgets/welcom/components/task_content_builder.dart';
import 'package:semo/features/auth/presentation/widgets/welcom/product_showcase_grid.dart';

/// Logger instance for the task card builder
final AppLogger logger = AppLogger();

/// Card states for the task card
enum TaskCardState {
  loaded,
  empty,
  loading,
  error
}

/// A builder for task cards that handles state management
class TaskCardBuilder {
  /// Builds a product showcase card using the staggered grid layout
  static Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(33.0)),
      child: SizedBox(
        width: context.responsiveItemSize(300),
        child: BlocBuilder<WelcomeAssetsBloc, WelcomeAssetsState>(
          builder: (context, state) {
            // Determine the card state based on the bloc state
            final TaskCardState cardState = _getCardState(state);
            
            // Handle different card states
            switch (cardState) {
              case TaskCardState.loaded:
                return TaskContentBuilder.build(context, (state as TaskAssetLoaded).taskAssets);
                
              case TaskCardState.empty:
                logger.info('Task assets failed to load');
                return const Center(
                  child: Text('task assets coming soon...',
                      style: TextStyle(color: Colors.black)),
                );
                
              case TaskCardState.loading:
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
                
              case TaskCardState.error:
                // Show a debug message and retry loading in the background
                logger.info('Unknown state: ${state.runtimeType}');
                _scheduleRetryLoad(context);
                
                // Create a placeholder grid
                return ProductShowcaseGrid(
                  imageUrls: List.generate(5, (_) => ''),
                  titleText: 'Loading content...',
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  padding: const EdgeInsets.all(16.0),
                );
            }
          },
        ),
      ),
    );
  }

  /// Determines the card state based on the bloc state
  static TaskCardState _getCardState(WelcomeAssetsState state) {
    if (state is TaskAssetLoaded) {
      return state.taskAssets.isNotEmpty ? TaskCardState.loaded : TaskCardState.empty;
    } else if (state is TaskAssetLoading || state is AllAssetsLoading) {
      return TaskCardState.loading;
    } else {
      return TaskCardState.error;
    }
  }

  /// Schedules a retry for loading task assets
  static void _scheduleRetryLoad(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        context.read<WelcomeAssetsBloc>().add(const LoadTaskAssetEvent());
      }
    });
  }
}
