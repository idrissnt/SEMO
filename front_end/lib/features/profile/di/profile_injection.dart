import 'package:get_it/get_it.dart';
import 'package:semo/features/profile/di/user_verif_injection.dart';
import 'package:semo/features/profile/domain/repositories/user_profile/basic_profile_repository.dart';
import 'package:semo/features/profile/domain/repositories/user_profile/user_address_repository.dart';
import 'package:semo/features/profile/infrastructure/repositories/user_profile/basic_profile_repository_impl.dart';
import 'package:semo/features/profile/infrastructure/repositories/user_profile/user_address_repository_impl.dart';
import 'package:semo/features/profile/presentation/bloc/basic_profile/basic_profile_bloc.dart';
import 'package:semo/features/profile/presentation/bloc/user_address/address_bloc.dart';

/// Dependency injection module for profile feature

final sl = GetIt.instance;

void registerProfileDependencies() {
  // Register user verification dependencies
  UserVerifModule.register(sl);

  // Register user address repositories
  sl.registerLazySingleton<UserAddressRepository>(
    () => UserAddressRepositoryImpl(
      apiClient: sl(),
      logger: sl(),
    ),
  );

  // Register basic profile repositories
  sl.registerLazySingleton<BasicProfileRepository>(
    () => BasicProfileRepositoryImpl(
      apiClient: sl(),
      logger: sl(),
    ),
  );

  // Register user address BLoCs
  sl.registerFactory(() => UserAddressBloc(
        userAddressRepository: sl<UserAddressRepository>(),
      ));

  // Register basic profile BLoCs
  sl.registerFactory(() => BasicProfileBloc(
        basicProfileRepository: sl<BasicProfileRepository>(),
      ));
}
