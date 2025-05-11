import 'package:get_it/get_it.dart';
import 'package:semo/features/order/domain/usecases/verify_email_code_usecase.dart';
import 'package:semo/features/order/presentation/bloc/email_verification/verify_email_code_bloc.dart';
import 'package:semo/features/profile/domain/repositories/user_verification/user_verification_repository.dart';

/// Dependency injection module for email verification feature
class VerifyEmailCodeModule {
  //
  /// Register all dependencies for the email verification feature
  static void register(GetIt getIt) {
    //
    // Register use cases
    getIt.registerLazySingleton(
      () => VerifyEmailCodeUseCase(
        verificationRepository: getIt<UserVerificationRepository>(),
      ),
    );

    // Register BLoCs
    getIt.registerLazySingleton(
      () => VerifyEmailCodeBloc(
        verifyEmailCodeUseCase: getIt<VerifyEmailCodeUseCase>(),
      ),
    );
  }
}
