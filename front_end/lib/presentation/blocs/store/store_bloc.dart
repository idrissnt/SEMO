// ignore_for_file: unused_catch_clause

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/logger.dart';
import '../../../domain/repositories/store_repository.dart';
import '../../../domain/usecases/get_stores_usecase.dart';
import 'store_event.dart';
import 'store_state.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final GetStoresUseCase getStoresUseCase;
  final StoreRepository storeRepository;
  final AppLogger _logger = AppLogger();

  StoreBloc({
    required this.getStoresUseCase,
    required this.storeRepository,
  }) : super(StoreInitial()) {
    on<LoadAllStoresEvent>(_onLoadAllStores);
    on<LoadStoreByIdEvent>(_onLoadStoreById);
  }

  Future<void> _onLoadAllStores(
      LoadAllStoresEvent event, Emitter<StoreState> emit) async {
    _logger.debug('Loading all stores (lightweight)');
    emit(StoreLoading());

    try {
      // Get lightweight store data for home screen
      final storesData = await getStoresUseCase.getStoresData();

      emit(AllStoresLoaded(
        bigStores: storesData['bigStores'] ?? [],
        smallStores: storesData['smallStores'] ?? [],
        storesByName: storesData['storesByName'] ?? [],
      ));

      _logger.debug('Successfully loaded all stores (lightweight)');
    } catch (e, stackTrace) {
      _logger.error('Error loading stores', error: e, stackTrace: stackTrace);
      emit(StoreError('Failed to load stores: ${e.toString()}'));
    }
  }

  Future<void> _onLoadStoreById(
      LoadStoreByIdEvent event, Emitter<StoreState> emit) async {
    _logger.debug('Loading store by ID (full details): ${event.storeId}');
    emit(StoreLoading());

    try {
      // Get full store details directly from repository
      final store = await storeRepository.getStoreById(event.storeId);

      if (store != null) {
        emit(StoreLoaded(store));
        _logger.debug(
            'Successfully loaded store details: ${store.name} (ID: ${store.id})');
      } else {
        throw Exception('Store not found with ID: ${event.storeId}');
      }
    } catch (e, stackTrace) {
      _logger.error('Error loading store by ID',
          error: e, stackTrace: stackTrace);
      emit(StoreError('Failed to load store: ${e.toString()}'));
    }
  }
}
