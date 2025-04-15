import 'package:get_it/get_it.dart';
import 'package:semo/features/profile/domain/repositories/services/user_address_repository.dart';
import 'package:semo/features/profile/domain/repositories/services/basic_profile_repository.dart';
import 'package:semo/features/profile/domain/usecases/address_usecases.dart';
import 'package:semo/features/profile/domain/usecases/basic_profile_usecases.dart';
import 'package:semo/features/profile/presentation/bloc/user_address/address_bloc.dart';
import 'package:semo/features/profile/presentation/bloc/basic_profile/basic_profile_bloc.dart';

final sl = GetIt.instance;

void registerProfileDependencies() {
  // Register use cases
  sl.registerFactory(() => UserAddressUseCases(
        userAddressRepository: sl<UserAddressRepository>(),
      ));
      
  sl.registerFactory(() => BasicProfileUseCases(
        profileRepository: sl<BasicProfileRepository>(),
      ));

  // Register BLoCs
  sl.registerFactory(() => UserAddressBloc(
        userAddressUseCases: sl<UserAddressUseCases>(),
      ));
      
  sl.registerFactory(() => BasicProfileBloc(
        profileUseCases: sl<BasicProfileUseCases>(),
      ));
}
