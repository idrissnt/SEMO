import 'package:get_it/get_it.dart';
import 'package:semo/core/presentation/navigation/main_app_nav/app_routes/app_router.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/coordinators/auth_flow_coordinator.dart';

/// Module for registering coordinators in the dependency injection container
class CoordinatorModule {
  /// Register all coordinators
  static void register(GetIt getIt) {
    // Register AuthFlowCoordinator as a singleton
    // This ensures it's created only once and lives for the entire app lifecycle
    getIt.registerLazySingleton<AuthFlowCoordinator>(
      () => AuthFlowCoordinator(
        authBloc: getIt<AuthBloc>(),
        router: AppRouter.router,
        logger: getIt<AppLogger>(),
      ),
    );
  }
}
