import 'package:get_it/get_it.dart';
import 'package:semo/features/home/domain/usecases/store_usecases.dart';
import 'package:semo/features/home/domain/usecases/user_address_usecases.dart';
import 'package:semo/features/home/presentation/bloc/home_store/home_store_bloc.dart';
import 'package:semo/features/home/presentation/bloc/user_address/user_address_bloc.dart';
import 'package:semo/features/store/domain/repositories/store_repository.dart';
import 'package:semo/features/profile/domain/repositories/services/user_address_repository.dart';

final sl = GetIt.instance;

void registerHomeScreenDependencies() {
  // Register use cases
  sl.registerFactory(() => HomeStoreUseCases(sl<StoreRepository>()));
  sl.registerFactory(() => HomeUserAddressUseCases(
        userAddressRepository: sl<UserAddressRepository>(),
      ));

  // Register BLoCs
  // see difference between registerLazySingleton and registerFactory
  sl.registerLazySingleton(() => HomeStoreBloc(
        homeStoreUseCases: sl<HomeStoreUseCases>(),
      ));
  sl.registerFactory(() => HomeUserAddressBloc(
        userAddressUseCases: sl<HomeUserAddressUseCases>(),
      ));
}
