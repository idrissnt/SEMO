import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/home/domain/usecases/store_usecases.dart';
import 'package:semo/features/home/presentation/bloc/home_store/home_store_event.dart';
import 'package:semo/features/home/presentation/bloc/home_store/home_store_state.dart';

class HomeStoreBloc extends Bloc<HomeStoreEvent, HomeStoreState> {
  final HomeStoreUseCases _homeStoreUseCases;
  final AppLogger _logger = AppLogger();

  HomeStoreBloc({
    required HomeStoreUseCases homeStoreUseCases,
  })  : _homeStoreUseCases = homeStoreUseCases,
        super(const HomeStoreInitial()) {
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
    emit(const HomeStoreLoading());

    try {
      final storeBrands = await _homeStoreUseCases.getAllStoreBrands();
      emit(StoreBrandsLoaded(storeBrands));
      _logger.debug('Successfully loaded ${storeBrands.length} store brands');
    } catch (e, stackTrace) {
      _logger.error('Error loading store brands',
          error: e, stackTrace: stackTrace);
      emit(HomeStoreError('Failed to load store brands: ${e.toString()}'));
    }
  }

  Future<void> _onLoadNearbyStores(
    LoadNearbyStoresEvent event,
    Emitter<HomeStoreState> emit,
  ) async {
    _logger.debug('Loading nearby stores for address: ${event.address}');
    emit(const HomeStoreLoading());

    try {
      final nearbyStores = await _homeStoreUseCases.findNearbyStores(
        address: event.address,
      );
      emit(NearbyStoresLoaded(nearbyStores));
      _logger.debug('Successfully loaded ${nearbyStores.length} nearby stores');
    } catch (e, stackTrace) {
      _logger.error('Error loading nearby stores',
          error: e, stackTrace: stackTrace);
      emit(HomeStoreError('Failed to load nearby stores: ${e.toString()}'));
    }
  }

  Future<void> _onLoadProductsByCategory(
    LoadProductsByCategoryEvent event,
    Emitter<HomeStoreState> emit,
  ) async {
    _logger.debug('Loading products by category for store: ${event.storeId}');
    emit(const HomeStoreLoading());

    try {
      final products = await _homeStoreUseCases.getProductsByCategory(
        storeSlug: event.storeSlug,
        storeId: event.storeId,
      );
      emit(ProductsByCategoryLoaded(
        products: products,
        storeId: event.storeId,
      ));
      _logger.debug('Successfully loaded ${products.length} products');
    } catch (e, stackTrace) {
      _logger.error('Error loading products by category',
          error: e, stackTrace: stackTrace);
      emit(HomeStoreError(
          'Failed to load products by category: ${e.toString()}'));
    }
  }

  Future<void> _onSearchQueryChanged(
    HomeStoreSearchQueryChangedEvent event,
    Emitter<HomeStoreState> emit,
  ) async {
    if (event.query.length < 2) return;

    _logger.debug('Getting autocomplete suggestions for query: ${event.query}');
    emit(const HomeStoreLoading());

    try {
      final suggestions =
          await _homeStoreUseCases.getAutocompleteSuggestions(event.query);
      emit(HomeStoreAutocompleteSuggestionsLoaded(suggestions));
      _logger.debug(
          'Successfully loaded ${suggestions.length} autocomplete suggestions');
    } catch (e, stackTrace) {
      _logger.error('Error getting autocomplete suggestions',
          error: e, stackTrace: stackTrace);
      emit(HomeStoreError(
          'Failed to get autocomplete suggestions: ${e.toString()}'));
    }
  }

  Future<void> _onSearchSubmitted(
    HomeStoreSearchSubmittedEvent event,
    Emitter<HomeStoreState> emit,
  ) async {
    _logger.debug('Searching products globally for query: ${event.query}');
    emit(const HomeStoreLoading());

    try {
      final searchResult = await _homeStoreUseCases.searchProducts(
        query: event.query,
        page: event.page,
        pageSize: event.pageSize,
      );
      emit(HomeStoreSearchResultsLoaded(searchResult));
      _logger.debug('Successfully loaded search results');
    } catch (e, stackTrace) {
      _logger.error('Error searching products',
          error: e, stackTrace: stackTrace);
      emit(HomeStoreError('Failed to search products: ${e.toString()}'));
    }
  }
}
