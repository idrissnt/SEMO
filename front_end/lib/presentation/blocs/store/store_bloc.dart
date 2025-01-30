// ignore_for_file: unused_catch_clause, avoid_print

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/exceptions.dart';
import '../../../domain/usecases/get_stores_usecase.dart';
import 'store_event.dart';
import 'store_state.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final GetStoresUseCase getStoresUseCase;

  StoreBloc({required this.getStoresUseCase}) : super(StoreInitial()) {
    on<LoadAllStores>(_onLoadAllStores);
  }

  void _onLoadAllStores(LoadAllStores event, Emitter<StoreState> emit) async {
    emit(StoreLoading());
    try {
      final stores = await getStoresUseCase.getAllStores();

      // Ensure all stores have proper isBigStore value
      for (var store in stores) {
        if (store.isBigStore == null) {
          print('Warning: Store ${store.name} has null isBigStore value');
        }
      }

      emit(StoreLoaded(stores));
    } on NetworkException {
      emit(const StoreError('Please check your internet connection'));
    } on UnauthorizedException {
      emit(const StoreError('Session expired. Please login again'));
    } on ServerException catch (e) {
      emit(StoreError('Server error: ${e.message}'));
    } catch (e) {
      emit(StoreError('Failed to load stores: ${e.toString()}'));
    }
  }
}
