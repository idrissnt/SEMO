import 'package:get_it/get_it.dart';
import 'package:semo/features/auth/domain/services/email_verification_usecase.dart';
import 'package:semo/features/auth/presentation/bloc/email_verification/email_verification_bloc.dart';
import 'package:semo/features/profile/domain/repositories/user_verification/user_verification_repository.dart';

/// Dependency injection module for email verification feature
class EmailVerificationModule {
  //
  /// Register all dependencies for the email verification feature
  static void register(GetIt getIt) {
    //
    // Register use cases
    getIt.registerLazySingleton(
      () => EmailVerificationUseCase(
        verificationRepository: getIt<UserVerificationRepository>(),
      ),
    );

    // Register BLoCs
    getIt.registerFactory(
      () => EmailVerificationBloc(
        emailVerificationUseCase: getIt<EmailVerificationUseCase>(),
      ),
    );
  }
}
