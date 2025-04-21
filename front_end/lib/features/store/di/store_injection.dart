import 'package:get_it/get_it.dart';

// Store feature imports
import 'package:semo/features/store/domain/exceptions/store_exception_mapper.dart';
import 'package:semo/features/store/domain/repositories/store_repository.dart';
import 'package:semo/features/store/domain/usecases/store_usecases.dart';
import 'package:semo/features/store/infrastructure/repositories/services/helper/store_exception_mapper.dart';
import 'package:semo/features/store/infrastructure/repositories/store_repository_impl.dart';
import 'package:semo/features/store/presentation/bloc/store_bloc.dart';

final sl = GetIt.instance;

void registerStoreDependencies() {
  // Register exception mappers
  sl.registerFactory<StoreExceptionMapper>(
    () => StoreExceptionMapperImpl(logger: sl()),
  );

  // Register repositories
  // Use Lazy Singleton pattern for repositories to ensure they're only created when needed
  if (!sl.isRegistered<StoreRepository>()) {
    sl.registerLazySingleton<StoreRepository>(
      () => StoreRepositoryImpl(
        apiClient: sl(),
        logger: sl(),
        exceptionMapper: sl(),
      ),
    );
  }

  // Register use cases
  // Use factory pattern for use cases to ensure fresh instances
  sl.registerFactory(() => StoreUseCases(sl<StoreRepository>()));

  // Register BLoCs
  // Use registerFactory when we want a new BLoC instance for each screen
  // (current approach - StoreBloc will be recreated each time it's requested)
  //
  // Use registerLazySingleton instead if we want to share the same BLoC
  // instance across multiple screens (like we do with HomeStoreBloc)
  sl.registerFactory(() => StoreBloc(
        storeUseCases: sl<StoreUseCases>(),
      ));
}
