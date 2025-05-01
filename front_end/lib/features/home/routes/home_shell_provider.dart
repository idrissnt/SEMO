import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/di/injection_container.dart';
import 'package:semo/core/presentation/navigation/bottom_navigation/bloc_provider/shell_provider.dart';
import 'package:semo/features/home/presentation/bloc/home_store/home_store_bloc.dart';
import 'package:semo/features/home/presentation/bloc/user_address/user_address_bloc.dart';

/// Provider for home feature BLoCs in the shell route
class HomeShellProvider implements ShellBlocProvider {
  @override
  List<BlocProvider> getBlocProviders() {
    return [
      BlocProvider<HomeStoreBloc>(
        create: (context) => sl<HomeStoreBloc>(),
      ),
      BlocProvider<HomeUserAddressBloc>(
        create: (context) => sl<HomeUserAddressBloc>(),
      ),
    ];
  }
}
