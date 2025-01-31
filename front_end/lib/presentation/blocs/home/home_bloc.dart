import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/store.dart';
import '../product/product_event.dart';
import '../store/store_bloc.dart';
import '../product/product_bloc.dart';
import '../store/store_event.dart';
import '../store/store_state.dart';
import '../product/product_state.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final StoreBloc storeBloc;
  final ProductBloc productBloc;
  late final StreamSubscription _storeSubscription;
  late final StreamSubscription _productSubscription;

  // Track the latest states
  StoreState? _latestStoreState;
  ProductState? _latestProductState;

  // Create a logger instance
  final AppLogger _logger = AppLogger();

  HomeBloc({required this.storeBloc, required this.productBloc})
      : super(HomeInitial()) {
    _logger.debug('HomeBloc initialized with storeBloc and productBloc');

    on<LoadHomeData>(_onLoadHomeData);
    on<HomeStoreStateChanged>(_onStoreStateChanged);
    on<HomeProductStateChanged>(_onProductStateChanged);

    // Listen to store and product bloc states
    _storeSubscription = storeBloc.stream.listen((storeState) {
      _logger.debug('HomeBloc received store state: $storeState');
      _latestStoreState = storeState;
      add(HomeStoreStateChanged(storeState));
    });

    _productSubscription = productBloc.stream.listen((productState) {
      _logger.debug('HomeBloc received product state: $productState');
      _latestProductState = productState;
      add(HomeProductStateChanged(productState));
    });

    // Initial state load - only trigger once during initialization
    _loadInitialData();
  }

  void _loadInitialData() {
    _logger.info('HomeBloc triggering initial load');
    if (storeBloc.state is StoreInitial) {
      storeBloc.add(LoadAllStores());
    }
    if (productBloc.state is ProductInitial) {
      productBloc.add(LoadProducts());
    }
  }

  void _onLoadHomeData(LoadHomeData event, Emitter<HomeState> emit) async {
    _logger.debug('HomeBloc handling LoadHomeData event');
    emit(HomeLoading());
    _loadInitialData(); // Reload data if explicitly requested
  }

  void _onStoreStateChanged(
    HomeStoreStateChanged event,
    Emitter<HomeState> emit,
  ) {
    _logger.debug('HomeBloc handling StoreStateChanged: ${event.storeState}');
    _tryEmitLoadedState(emit);
  }

  void _onProductStateChanged(
    HomeProductStateChanged event,
    Emitter<HomeState> emit,
  ) {
    _logger.debug('HomeBloc handling ProductStateChanged: ${event.productState}');
    _tryEmitLoadedState(emit);
  }

  void _tryEmitLoadedState(Emitter<HomeState> emit) {
    _logger.debug('HomeBloc trying to emit loaded state');
    _logger.debug('Current store state: $_latestStoreState');
    _logger.debug('Current product state: $_latestProductState');

    final storeState = _latestStoreState;
    final productState = _latestProductState;

    List<Store> bigStores = [];
    List<Store> smallStores = [];
    List<Product> products = [];
    Map<String, List<Product>> productCategories = {};

    // Extract stores based on state type
    if (storeState is StoreLoaded) {
      // Only include stores that have a valid isBigStore value
      var validStores =
          storeState.stores.where((store) => store.isBigStore != null).toList();

      // Properly categorize stores based on isBigStore flag
      bigStores =
          validStores.where((store) => store.isBigStore == true).toList();
      smallStores =
          validStores.where((store) => store.isBigStore == false).toList();

      _logger.debug(
        'Store categorization details',
        error: {
          'Total valid stores': validStores.length,
          'Big stores': bigStores.length,
          'Small stores': smallStores.length,
        },
      );

      // Log any stores with null isBigStore value
      var invalidStores =
          storeState.stores.where((store) => store.isBigStore == null).toList();
      if (invalidStores.isNotEmpty) {
        _logger.warning(
          'Warning: Found stores with null isBigStore value',
          error: {
            'Invalid stores count': invalidStores.length,
            'Invalid store names':
                invalidStores.map((store) => store.name).toList(),
          },
        );
      }

      // Sort stores by name
      bigStores.sort((a, b) => a.name.compareTo(b.name));
      smallStores.sort((a, b) => a.name.compareTo(b.name));
    }

    // Extract products
    if (productState is ProductsLoaded) {
      products = productState.products;
      productCategories = productState.productCategories;
    }

    // Only emit if we have valid data
    if (storeState is StoreLoaded &&
        !_hasInvalidStoreData(bigStores, smallStores)) {
      _logger.debug(
        'Emitting HomeLoaded state',
        error: {
          'Big stores count': bigStores.length,
          'Small stores count': smallStores.length,
          'Products count': products.length,
          'Product categories count': productCategories.length,
        },
      );

      emit(HomeLoaded(
        bigStores: bigStores,
        smallStores: smallStores,
        products: products,
        productCategories: productCategories,
      ));
    } else if (storeState is StoreError) {
      emit(HomeError(storeState.message));
    }
  }

  // Helper method to validate store data
  bool _hasInvalidStoreData(List<Store> bigStores, List<Store> smallStores) {
    // Check for stores that might be miscategorized
    bool hasInvalidBigStores =
        bigStores.any((store) => store.isBigStore != true);
    bool hasInvalidSmallStores =
        smallStores.any((store) => store.isBigStore != false);

    if (hasInvalidBigStores || hasInvalidSmallStores) {
      _logger.warning('Warning: Found miscategorized stores!');
      if (hasInvalidBigStores) {
        _logger.warning(
          'Found stores in bigStores with isBigStore != true',
        );
      }
      if (hasInvalidSmallStores) {
        _logger.warning(
          'Found stores in smallStores with isBigStore != false',
        );
      }
      return true;
    }
    return false;
  }

  @override
  Future<void> close() {
    _logger.info('Closing HomeBloc');
    _storeSubscription.cancel();
    _productSubscription.cancel();
    return super.close();
  }
}
