// ignore_for_file: unused_catch_clause

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/logger.dart';
import '../../../domain/usecases/get_stores_usecase.dart';
import 'store_event.dart';
import 'store_state.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final GetStoresUseCase getStoresUseCase;
  final AppLogger _logger = AppLogger();

  // Stores data fetched once and used across methods
  Map<String, dynamic>? _storesData;
  bool _isLoading = false;

  StoreBloc({required this.getStoresUseCase}) : super(StoreInitial()) {
    on<LoadAllStoresEvent>(_onLoadAllStores);
  }

  Future<Map<String, dynamic>> _fetchStoresData() async {
    // Prevent multiple simultaneous API calls
    if (_isLoading) {
      // Wait for the ongoing fetch to complete
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _storesData!;
    }

    // If data is already loaded, return it
    if (_storesData != null) {
      return _storesData!;
    }

    try {
      _isLoading = true;
      _logger.debug('Fetching stores data');
      
      final storesData = await getStoresUseCase.getStoresData();
      
      _storesData = storesData;
      _logger.debug('Initialized stores data: '
          'big=${storesData['bigStores']?.length}, '
          'small=${storesData['smallStores']?.length}, '
          'byName=${storesData['storesByName']?.length}');
      
      return storesData;
    } catch (e, stackTrace) {
      _logger.error('Error fetching stores data',
          error: e, stackTrace: stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _onLoadAllStores(
      LoadAllStoresEvent event, Emitter<StoreState> emit) async {
    _logger.debug('Loading all stores');
    emit(StoreLoading());

    try {
      final storesData = await _fetchStoresData();
      
      emit(AllStoresLoaded(
        bigStores: storesData['bigStores'] ?? [],
        smallStores: storesData['smallStores'] ?? [],
        storesByName: storesData['storesByName'] ?? [],
      ));

      _logger.debug('Successfully loaded all stores');
    } catch (e, stackTrace) {
      _logger.error('Error loading stores',
          error: e, stackTrace: stackTrace);
      emit(StoreError('Failed to load stores: ${e.toString()}'));
    }
  }
}
