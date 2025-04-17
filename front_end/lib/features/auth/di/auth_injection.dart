import 'package:get_it/get_it.dart';
import 'package:semo/core/utils/logger.dart';

// Auth feature imports
import 'package:semo/features/auth/domain/repositories/auth_repository.dart';
import 'package:semo/features/auth/domain/usecases/auth_check_usecase.dart';
import 'package:semo/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:semo/features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

void registerAuthDependencies() {
  // Register repositories
  // Use Lazy Singleton pattern for repositories to ensure they're only created when needed
  if (!sl.isRegistered<UserAuthRepository>()) {
    sl.registerLazySingleton<UserAuthRepository>(
      () => UserAuthRepositoryImpl(
        apiClient: sl(),
        tokenService: sl(),
        logger: sl(),
      ),
    );
  }

  // Register use cases
  // Use factory pattern for use cases to ensure fresh instances
  sl.registerFactory(() => UserProfileUseCase(
        basicProfileRepository: sl(),
        tokenService: sl(),
      ));

  // Register BLoCs
  // Use factory pattern for BLoCs to ensure fresh instances for each screen
  sl.registerFactory(() => AuthBloc(
        authRepository: sl<UserAuthRepository>(),
        userProfileUseCase: sl<UserProfileUseCase>(),
        logger: sl<AppLogger>(),
      ));
}
