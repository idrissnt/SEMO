import 'package:get_it/get_it.dart';
import 'package:semo/features/store/domain/repositories/store_repository.dart';
import 'package:semo/features/store/domain/usecases/store_usecases.dart';
import 'package:semo/features/store/presentation/bloc/store_bloc.dart';

final sl = GetIt.instance;

void registerStoreDependencies() {
  // // Register repositories if not already registered
  // if (!sl.isRegistered<StoreRepository>()) {
  //   sl.registerLazySingleton<StoreRepository>(
  //     () => StoreRepositoryImpl(apiClient: sl()),
  //   );
  // }

  // Register use cases
  // Use factory pattern for use cases to ensure fresh instances
  sl.registerFactory(() => StoreUseCases(sl<StoreRepository>()));

  // Register BLoCs
  // Use factory pattern for BLoCs to ensure fresh instances for each screen
  sl.registerFactory(() => StoreBloc(
        storeUseCases: sl<StoreUseCases>(),
      ));
}
