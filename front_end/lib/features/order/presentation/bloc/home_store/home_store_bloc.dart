import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/order/domain/usecases/store_usecases.dart';
import 'package:semo/features/order/presentation/bloc/home_store/home_store_event.dart';
import 'package:semo/features/order/presentation/bloc/home_store/home_store_state.dart';

class HomeStoreBloc extends Bloc<HomeStoreEvent, HomeStoreState> {
  final HomeStoreUseCases _homeStoreUseCases;
  final AppLogger _logger = AppLogger();

  HomeStoreBloc({
    required HomeStoreUseCases homeStoreUseCases,
  })  : _homeStoreUseCases = homeStoreUseCases,
        super(const HomeStoreState()) {
    on<LoadAllStoreBrandsEvent>(_onLoadAllStoreBrands);
    on<LoadNearbyStoresEvent>(_onLoadNearbyStores);
    on<LoadProductsByCategoryEvent>(_onLoadProductsByCategory);
    on<HomeStoreSearchQueryChangedEvent>(_onSearchQueryChanged);
    on<HomeStoreSearchSubmittedEvent>(_onSearchSubmitted);
  }

  Future<void> _onLoadAllStoreBrands(
    LoadAllStoreBrandsEvent event,
    Emitter<HomeStoreState> emit,
  ) async {
    _logger.debug('Loading all store brands');
    emit(state.copyWith(storeBrandsState: const StoreBrandsLoading()));

    final result = await _homeStoreUseCases.getAllStoreBrands();

    result.fold(
      (storeBrands) {
        emit(state.copyWith(storeBrandsState: StoreBrandsLoaded(storeBrands)));
        _logger.debug('Successfully loaded ${storeBrands.length} store brands');
      },
      (error) {
        _logger.error('Error loading store brands', error: error);
        emit(state.copyWith(
            storeBrandsState: StoreBrandsError(
                'Failed to load store brands: ${error.message}')));
      },
    );
  }

  Future<void> _onLoadNearbyStores(
    LoadNearbyStoresEvent event,
    Emitter<HomeStoreState> emit,
  ) async {
    _logger.debug('Loading nearby stores for address: ${event.address}');
    emit(state.copyWith(nearbyStoresState: const NearbyStoresLoading()));

    final result = await _homeStoreUseCases.findNearbyStores(
      address: event.address,
    );

    result.fold(
      (nearbyStores) {
        emit(state.copyWith(
            nearbyStoresState: NearbyStoresLoaded(nearbyStores)));
        _logger
            .debug('Successfully loaded ${nearbyStores.length} nearby stores');
      },
      (error) {
        _logger.error('Error loading nearby stores', error: error);
        emit(state.copyWith(
            nearbyStoresState: NearbyStoresError(
                'Failed to load nearby stores: ${error.message}')));
      },
    );
  }

  Future<void> _onLoadProductsByCategory(
    LoadProductsByCategoryEvent event,
    Emitter<HomeStoreState> emit,
  ) async {
    _logger.debug('Loading products by category for store: ${event.storeId}');
    emit(state.copyWith(
        productsByCategoryState: const ProductsByCategoryLoading()));

    final result = await _homeStoreUseCases.getProductsByCategory(
      storeSlug: event.storeSlug,
      storeId: event.storeId,
    );

    result.fold(
      (products) {
        emit(state.copyWith(
            productsByCategoryState: ProductsByCategoryLoaded(
          products: products,
          storeId: event.storeId,
        )));
        _logger.debug('Successfully loaded ${products.length} products');
      },
      (error) {
        _logger.error('Error loading products by category', error: error);
        emit(state.copyWith(
            productsByCategoryState: ProductsByCategoryError(
                'Failed to load products by category: ${error.message}')));
      },
    );
  }

  Future<void> _onSearchQueryChanged(
    HomeStoreSearchQueryChangedEvent event,
    Emitter<HomeStoreState> emit,
  ) async {
    if (event.query.length < 2) return;

    _logger.debug('Getting autocomplete suggestions for query: ${event.query}');
    emit(state.copyWith(
        autocompleteSuggestionsState: const AutocompleteSuggestionsLoading()));

    final result =
        await _homeStoreUseCases.getAutocompleteSuggestions(event.query);

    result.fold(
      (suggestions) {
        emit(state.copyWith(
            autocompleteSuggestionsState:
                AutocompleteSuggestionsLoaded(suggestions)));
        _logger.debug(
            'Successfully loaded ${suggestions.length} autocomplete suggestions');
      },
      (error) {
        _logger.error('Error getting autocomplete suggestions', error: error);
        emit(state.copyWith(
            autocompleteSuggestionsState: AutocompleteSuggestionsError(
                'Failed to get autocomplete suggestions: ${error.message}')));
      },
    );
  }

  Future<void> _onSearchSubmitted(
    HomeStoreSearchSubmittedEvent event,
    Emitter<HomeStoreState> emit,
  ) async {
    _logger.debug('Searching products globally for query: ${event.query}');
    emit(state.copyWith(searchResultsState: const SearchResultsLoading()));

    final result = await _homeStoreUseCases.searchProducts(
      query: event.query,
      page: event.page,
      pageSize: event.pageSize,
    );

    result.fold(
      (searchResult) {
        emit(state.copyWith(
            searchResultsState: SearchResultsLoaded(searchResult)));
        _logger.debug('Successfully loaded search results');
      },
      (error) {
        _logger.error('Error searching products', error: error);
        emit(state.copyWith(
            searchResultsState: SearchResultsError(
                'Failed to search products: ${error.message}')));
      },
    );
  }
}
