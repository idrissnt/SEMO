import 'package:get_it/get_it.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/domain/exceptions/auth/auth_exception_mapper.dart';
import 'package:semo/features/auth/infrastructure/exceptions/auth_exception_mapper_impl.dart';

// Auth feature imports
import 'package:semo/features/auth/domain/repositories/auth_repository.dart';
import 'package:semo/features/auth/domain/services/auth_check_usecase.dart';
import 'package:semo/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';

/// Dependency injection module for auth feature
class AuthModule {
  /// Register all dependencies for the auth feature
  static void registerAuthDependencies(GetIt getIt) {
    // Register exception mappers
    getIt.registerFactory<AuthExceptionMapper>(
      () => AuthExceptionMapperImpl(logger: getIt()),
    );

    // Register repositories
    // Use Lazy Singleton pattern for repositories to ensure they're only created when needed
    if (!getIt.isRegistered<UserAuthRepository>()) {
      getIt.registerLazySingleton<UserAuthRepository>(
        () => UserAuthRepositoryImpl(
          apiClient: getIt(),
          tokenService: getIt(),
          logger: getIt(),
          exceptionMapper: getIt(),
        ),
      );
    }

    // Register use cases
    // Use factory pattern for use cases to ensure fresh instances
    getIt.registerFactory(() => UserProfileUseCase(
          basicProfileRepository: getIt(),
          tokenService: getIt(),
        ));

    // Register BLoCs
    // Use factory pattern for BLoCs to ensure fresh instances for each screen
    getIt.registerFactory(() => AuthBloc(
          authRepository: getIt<UserAuthRepository>(),
          userProfileUseCase: getIt<UserProfileUseCase>(),
          logger: getIt<AppLogger>(),
        ));
  }
}
