import 'package:get_it/get_it.dart';
import 'package:semo/core/domain/services/api_client.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/domain/exceptions/welcom/exception_mapper_welcom.dart';
import 'package:semo/features/auth/domain/repositories/welcom_repository.dart';
import 'package:semo/features/auth/infrastructure/exceptions/welcome_exception_mapper_impl.dart';
import 'package:semo/features/auth/infrastructure/repositories/welcome_repository_impl.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_bloc.dart';

/// Dependency injection module for welcome assets feature
class WelcomeAssetsModule {
  /// Register all dependencies for the welcome assets feature
  static void register(GetIt getIt) {
    // Exception mappers
    getIt.registerLazySingleton<WelcomeExceptionMapper>(
      () => WelcomeExceptionMapperImpl(
        logger: getIt<AppLogger>(),
      ),
    );

    // Repositories
    getIt.registerLazySingleton<WelcomeRepository>(
      () => WelcomeRepositoryImpl(
        apiClient: getIt<ApiClient>(),
        logger: getIt<AppLogger>(),
        exceptionMapper: getIt<WelcomeExceptionMapper>(),
      ),
    );

    // BLoCs
    getIt.registerLazySingleton(
      () => WelcomeAssetsBloc(
        welcomeRepository: getIt<WelcomeRepository>(),
      ),
    );
  }
}
