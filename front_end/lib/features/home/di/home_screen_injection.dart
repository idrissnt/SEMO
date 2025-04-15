import 'package:get_it/get_it.dart';
import 'package:semo/features/home/domain/usecases/store_usecases.dart';
import 'package:semo/features/home/presentation/bloc/home_store/home_store_bloc.dart';
import 'package:semo/features/store/domain/repositories/store_repository.dart';

final sl = GetIt.instance;

void registerHomeScreenDependencies() {
  // Register use cases
  sl.registerFactory(() => HomeStoreUseCases(sl<StoreRepository>()));

  // Register BLoCs
  sl.registerFactory(() => HomeStoreBloc(
        homeStoreUseCases: sl<HomeStoreUseCases>(),
      ));
}
