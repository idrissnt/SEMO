import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/di/injection_container.dart';
import 'package:semo/core/presentation/navigation/main_app_nav/bottom_navigation/bloc_provider/shell_provider.dart';
import 'package:semo/core/utils/logger.dart';

import 'package:semo/features/order/presentation/bloc/email_verification/verify_email_code_bloc.dart';
import 'package:semo/features/order/presentation/bloc/home_store/home_store_bloc.dart';
import 'package:semo/features/order/presentation/bloc/home_store/home_store_event.dart';
import 'package:semo/features/order/presentation/bloc/user_address/user_address_bloc.dart';
import 'package:semo/features/order/presentation/bloc/user_address/user_address_event.dart';

/// Provider for home feature BLoCs in the shell route
/// Responsible for providing and initializing all BLoCs related to the home feature
class OrderShellProvider implements ShellBlocProvider {
  final AppLogger _logger = sl<AppLogger>();

  @override
  List<BlocProvider> getBlocProviders() {
    _logger.debug('OrderShellProvider: Creating and initializing BLoCs');

    return [
      BlocProvider<HomeStoreBloc>(
        create: (context) {
          final bloc = sl<HomeStoreBloc>();
          // Initialize with required events
          bloc.add(const LoadAllStoreBrandsEvent());
          return bloc;
        },
      ),
      BlocProvider<OrderUserAddressBloc>(
        create: (context) {
          final bloc = sl<OrderUserAddressBloc>();
          // Initialize with required events
          bloc.add(const OrderGetUserAddressEvent());
          return bloc;
        },
      ),
      BlocProvider<VerifyEmailCodeBloc>(
        create: (context) {
          final bloc = sl<VerifyEmailCodeBloc>();
          return bloc;
        },
      ),
    ];
  }
}
