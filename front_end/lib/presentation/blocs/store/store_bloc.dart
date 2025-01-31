// ignore_for_file: unused_catch_clause, avoid_print

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/usecases/get_stores_usecase.dart';
import 'store_event.dart';
import 'store_state.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final GetStoresUseCase getStoresUseCase;
  final AppLogger _logger = AppLogger();

  StoreBloc({required this.getStoresUseCase}) : super(StoreInitial()) {
    on<LoadAllStores>(_onLoadAllStores);
  }

  void _onLoadAllStores(LoadAllStores event, Emitter<StoreState> emit) async {
    _logger.debug('Loading all stores');
    emit(StoreLoading());
    try {
      final stores = await getStoresUseCase.getAllStores();

      // Enhanced logging for store details
      _logger.info('Total stores loaded: ${stores.length}');
      for (var store in stores) {
        // _logger.debug('Store Details: '
        //     'Name=${store.name}, '
        //     'Is Big Store=${store.isBigStore}, '
        //     'Logo URL=${store.logoUrl}, '
        //     'Rating=${store.rating}');

        if (store.isBigStore == null) {
          _logger.warning('Store ${store.name} has null isBigStore value');
        }
      }

      emit(StoreLoaded(stores));
    } on NetworkException catch (e, stackTrace) {
      _logger.error('Network error while loading stores',
          error: e, stackTrace: stackTrace);
      emit(StoreError('Failed to load stores: ${e.message}'));
    } catch (e, stackTrace) {
      _logger.error('Unexpected error while loading stores',
          error: e, stackTrace: stackTrace);
      emit(const StoreError('An unexpected error occurred'));
    }
  }
}
