import 'package:get_it/get_it.dart';
import 'package:semo/core/domain/services/api_client.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/profile/domain/exceptions/user_verifications/verif_exception_mapper.dart';
import 'package:semo/features/profile/domain/repositories/user_verification/user_verification_repository.dart';
import 'package:semo/features/profile/infrastructure/exceptions/verif_exception_mapper_imp.dart';
import 'package:semo/features/profile/infrastructure/repositories/user_verification/user_verification_repository_impl.dart';
import 'package:semo/features/profile/presentation/bloc/user_verification/user_verification_bloc.dart';

/// Dependency injection module for user verification feature
class UserVerifModule {
  /// Register all dependencies for the user verification feature
  static void register(GetIt getIt) {
    // Exception mappers
    getIt.registerLazySingleton<UserVerificationExceptionMapper>(
      () => UserVerificationExceptionMapperImpl(
        logger: getIt<AppLogger>(),
      ),
    );

    // Repositories
    getIt.registerLazySingleton<UserVerificationRepository>(
      () => UserVerificationRepositoryImpl(
        apiClient: getIt<ApiClient>(),
        logger: getIt<AppLogger>(),
        userVerificationExceptionMapper:
            getIt<UserVerificationExceptionMapper>(),
      ),
    );

    // BLoCs
    getIt.registerLazySingleton(
      () => UserVerificationBloc(
        verificationRepository: getIt<UserVerificationRepository>(),
      ),
    );
  }
}
