import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/store/domain/usecases/store_usecases.dart';
import 'package:semo/features/store/presentation/bloc/store_event.dart';
import 'package:semo/features/store/presentation/bloc/store_state.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final StoreUseCases _storeUseCases;
  final AppLogger _logger = AppLogger();

  StoreBloc({
    required StoreUseCases storeUseCases,
  })  : _storeUseCases = storeUseCases,
        super(const StoreInitial()) {
    on<InitializeStoreEvent>(_onInitializeStore);
    on<LoadStoreProductsEvent>(_onLoadStoreProducts);
    on<StoreSearchQueryChangedEvent>(_onSearchQueryChanged);
    on<StoreSearchSubmittedEvent>(_onSearchSubmitted);
  }

  Future<void> _onInitializeStore(
    InitializeStoreEvent event,
    Emitter<StoreState> emit,
  ) async {
    _logger.debug('Initializing store screen for store ID: ${event.storeId}');
    add(LoadStoreProductsEvent(storeId: event.storeId));
  }

  Future<void> _onLoadStoreProducts(
    LoadStoreProductsEvent event,
    Emitter<StoreState> emit,
  ) async {
    _logger.debug('Loading products for store: ${event.storeId}');
    emit(const StoreLoading());

    try {
      final products = await _storeUseCases.getProductsByStoreId(event.storeId);
      emit(StoreProductsLoaded(
        products: products,
        storeId: event.storeId,
      ));
      _logger.debug(
          'Successfully loaded ${products.length} products for store ${event.storeId}');
    } catch (e, stackTrace) {
      _logger.error('Error loading store products',
          error: e, stackTrace: stackTrace);
      emit(StoreError('Failed to load store products: ${e.toString()}'));
    }
  }

  Future<void> _onSearchQueryChanged(
    StoreSearchQueryChangedEvent event,
    Emitter<StoreState> emit,
  ) async {
    if (event.query.length < 2) return;

    _logger.debug(
        'Getting store-specific autocomplete suggestions for query: ${event.query} in store: ${event.storeId}');
    emit(const StoreLoading());

    try {
      final suggestions = await _storeUseCases.getAutocompleteSuggestions(
        event.query,
        event.storeId,
      );
      emit(StoreAutocompleteSuggestionsLoaded(
        suggestions: suggestions,
        storeId: event.storeId,
      ));
      _logger.debug(
          'Successfully loaded ${suggestions.length} store-specific autocomplete suggestions');
    } catch (e, stackTrace) {
      _logger.error('Error getting store-specific autocomplete suggestions',
          error: e, stackTrace: stackTrace);
      emit(StoreError(
          'Failed to get store-specific autocomplete suggestions: ${e.toString()}'));
    }
  }

  Future<void> _onSearchSubmitted(
    StoreSearchSubmittedEvent event,
    Emitter<StoreState> emit,
  ) async {
    _logger.debug(
        'Searching products in store ${event.storeId} for query: ${event.query}');
    emit(const StoreLoading());

    try {
      final searchResult = await _storeUseCases.searchProducts(
        query: event.query,
        storeId: event.storeId,
        page: event.page,
        pageSize: event.pageSize,
      );
      emit(StoreSearchResultsLoaded(
        searchResult: searchResult,
        storeId: event.storeId,
      ));
      _logger.debug('Successfully loaded store-specific search results');
    } catch (e, stackTrace) {
      _logger.error('Error searching products in store',
          error: e, stackTrace: stackTrace);
      emit(StoreError('Failed to search products in store: ${e.toString()}'));
    }
  }
}
