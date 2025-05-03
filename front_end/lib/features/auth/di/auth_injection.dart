import 'package:get_it/get_it.dart';
import 'package:semo/features/auth/di/auth_services/auth_module.dart';
import 'package:semo/features/auth/di/auth_services/welcome_assets_module.dart';
import 'package:semo/features/auth/di/auth_services/email_verification_module.dart';
import 'package:semo/features/auth/di/auth_services/coordinator_module.dart';

final sl = GetIt.instance;

void registerAuthDependencies() {
  // Register welcome assets dependencies
  WelcomeAssetsModule.register(sl);

  // Register email verification dependencies
  EmailVerificationModule.register(sl);

  // Register auth dependencies
  AuthModule.registerAuthDependencies(sl);

  // Register coordinators
  CoordinatorModule.register(sl);
}
