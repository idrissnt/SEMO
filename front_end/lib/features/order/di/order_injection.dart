import 'package:get_it/get_it.dart';
import 'package:semo/features/order/di/verify_email_code_module.dart';
import 'package:semo/features/order/domain/usecases/store_usecases.dart';
import 'package:semo/features/order/domain/usecases/user_address_usecases.dart';
import 'package:semo/features/order/presentation/bloc/home_store/home_store_bloc.dart';
import 'package:semo/features/order/presentation/bloc/user_address/user_address_bloc.dart';
import 'package:semo/features/store/domain/repositories/store_repository.dart';
import 'package:semo/features/profile/domain/repositories/user_profile/user_address_repository.dart';

final sl = GetIt.instance;

void registerOrderDependencies() {
  // Register dependencies
  VerifyEmailCodeModule.register(sl);

  // Register use cases
  sl.registerFactory(() => HomeStoreUseCases(sl<StoreRepository>()));
  sl.registerFactory(() => OrderUserAddressUseCases(
        userAddressRepository: sl<UserAddressRepository>(),
      ));

  // Register BLoCs
  // Both BLoCs are now registered as factories for consistent lifecycle management
  sl.registerFactory(() => HomeStoreBloc(
        homeStoreUseCases: sl<HomeStoreUseCases>(),
      ));
  sl.registerFactory(() => OrderUserAddressBloc(
        userAddressUseCases: sl<OrderUserAddressUseCases>(),
      ));
}
