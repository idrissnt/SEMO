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
    _logger
        .debug('Initializing store screen for store slug: ${event.storeSlug}');
    add(LoadStoreProductsEvent(
        storeId: event.storeId, storeSlug: event.storeSlug));
  }

  Future<void> _onLoadStoreProducts(
    LoadStoreProductsEvent event,
    Emitter<StoreState> emit,
  ) async {
    _logger.debug('Loading products for store slug: ${event.storeSlug}', {
      'component': 'StoreBloc',
      'action': 'load_products',
      'store_slug': event.storeSlug
    });
    emit(const StoreLoading());

    final result = await _storeUseCases.getProductsByStore(
        event.storeId, event.storeSlug);
        
    result.fold(
      (products) {
        emit(StoreProductsLoaded(
          products: products,
          storeId: event.storeId,
        ));
        _logger.debug(
            'Successfully loaded ${products.length} products for store ${event.storeSlug}',
            {
              'component': 'StoreBloc',
              'action': 'load_products',
              'status': 'success',
              'product_count': '${products.length}',
              'store_slug': event.storeSlug
            });
      },
      (error) {
        _logger.error('Error loading store products', error: error);
        emit(StoreError('Failed to load store products: ${error.message}'));
      },
    );
  }

  Future<void> _onSearchQueryChanged(
    StoreSearchQueryChangedEvent event,
    Emitter<StoreState> emit,
  ) async {
    if (event.query.length < 2) return;

    _logger.debug(
        'Getting store-specific autocomplete suggestions for query: ${event.query} in store: ${event.storeId}');
    emit(const StoreLoading());

    final result = await _storeUseCases.getAutocompleteSuggestions(
      event.query,
      event.storeId,
    );
    
    result.fold(
      (suggestions) {
        emit(StoreAutocompleteSuggestionsLoaded(
          suggestions: suggestions,
          storeId: event.storeId,
        ));
        _logger.debug(
            'Successfully loaded ${suggestions.length} store-specific autocomplete suggestions',
            {
              'component': 'StoreBloc',
              'action': 'get_autocomplete_suggestions',
              'status': 'success',
              'suggestion_count': '${suggestions.length}',
              'store_id': event.storeId
            });
      },
      (error) {
        _logger.error('Error getting store-specific autocomplete suggestions', error: error);
        emit(StoreError(
            'Failed to get store-specific autocomplete suggestions: ${error.message}'));
      },
    );
  }

  Future<void> _onSearchSubmitted(
    StoreSearchSubmittedEvent event,
    Emitter<StoreState> emit,
  ) async {
    _logger.debug('Loading store details for store ID: ${event.storeId}', {
      'component': 'StoreBloc',
      'action': 'load_store_details',
      'store_id': event.storeId
    });
    _logger.debug(
        'Searching products in store ${event.storeId} for query: ${event.query}',
        {
          'component': 'StoreBloc',
          'action': 'search_products',
          'query': event.query,
          'store_id': event.storeId
        });
    emit(const StoreLoading());

    final result = await _storeUseCases.searchProducts(
      query: event.query,
      storeId: event.storeId,
      page: event.page,
      pageSize: event.pageSize,
    );
    
    result.fold(
      (searchResult) {
        emit(StoreSearchResultsLoaded(
          searchResult: searchResult,
          storeId: event.storeId,
        ));
        _logger.debug('Successfully loaded store-specific search results', {
          'component': 'StoreBloc',
          'action': 'search_products',
          'status': 'success',
          'query': event.query,
          'store_id': event.storeId
        });
      },
      (error) {
        _logger.error('Error searching products in store', error: error);
        emit(StoreError('Failed to search products in store: ${error.message}'));
      },
    );
  }
}
