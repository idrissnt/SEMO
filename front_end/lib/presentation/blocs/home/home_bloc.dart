// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/exceptions.dart';
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

  HomeBloc({required this.storeBloc, required this.productBloc})
      : super(HomeInitial()) {
    print('HomeBloc initialized with storeBloc and productBloc');

    on<LoadHomeData>(_onLoadHomeData);
    on<HomeStoreStateChanged>(_onStoreStateChanged);
    on<HomeProductStateChanged>(_onProductStateChanged);

    // Listen to store and product bloc states
    _storeSubscription = storeBloc.stream.listen((storeState) {
      print('HomeBloc received store state: $storeState');
      _latestStoreState = storeState;
      add(HomeStoreStateChanged(storeState));
    });

    _productSubscription = productBloc.stream.listen((productState) {
      print('HomeBloc received product state: $productState');
      _latestProductState = productState;
      add(HomeProductStateChanged(productState));
    });

    // Initial state load - only trigger once during initialization
    _loadInitialData();
  }

  void _loadInitialData() {
    print('HomeBloc triggering initial load');
    if (storeBloc.state is StoreInitial) {
      storeBloc.add(LoadAllStores());
    }
    if (productBloc.state is ProductInitial) {
      productBloc.add(LoadProducts());
    }
  }

  void _onLoadHomeData(LoadHomeData event, Emitter<HomeState> emit) async {
    print('HomeBloc handling LoadHomeData event');
    emit(HomeLoading());
    _loadInitialData(); // Reload data if explicitly requested
  }

  void _onStoreStateChanged(
    HomeStoreStateChanged event,
    Emitter<HomeState> emit,
  ) {
    print('HomeBloc handling StoreStateChanged: ${event.storeState}');
    _tryEmitLoadedState(emit);
  }

  void _onProductStateChanged(
    HomeProductStateChanged event,
    Emitter<HomeState> emit,
  ) {
    print('HomeBloc handling ProductStateChanged: ${event.productState}');
    _tryEmitLoadedState(emit);
  }

  void _tryEmitLoadedState(Emitter<HomeState> emit) {
    print('HomeBloc trying to emit loaded state');
    print('Current store state: $_latestStoreState');
    print('Current product state: $_latestProductState');

    final storeState = _latestStoreState;
    final productState = _latestProductState;

    List<Store> bigStores = [];
    List<Store> smallStores = [];
    List<Product> products = [];
    Map<String, List<Product>> productCategories = {};

    // Extract stores based on state type
    if (storeState is StoreLoaded) {
      // Properly categorize stores based on isBigStore flag
      bigStores = storeState.stores.where((store) => store.isBigStore == true).toList();
      smallStores = storeState.stores.where((store) => store.isBigStore == false).toList();
      
      print('Categorized stores - Big: ${bigStores.length}, Small: ${smallStores.length}');
      
      // Ensure stores are properly sorted
      bigStores.sort((a, b) => a.name.compareTo(b.name));
      smallStores.sort((a, b) => a.name.compareTo(b.name));
    }

    // Extract products
    if (productState is ProductsLoaded) {
      products = productState.products;
      productCategories = productState.productCategories;
    }

    print('BigStores count: ${bigStores.length}');
    print('SmallStores count: ${smallStores.length}');
    print('Products count: ${products.length}');
    print('Product categories count: ${productCategories.length}');

    // Only emit if we have valid data
    if ((bigStores.isNotEmpty || smallStores.isNotEmpty) && !_hasInvalidStoreData(bigStores, smallStores)) {
      print('Emitting HomeLoaded state with valid store data');
      emit(HomeLoaded(
        bigStores: bigStores,
        smallStores: smallStores,
        products: products,
        productCategories: productCategories,
      ));
    } else {
      print('Not emitting HomeLoaded state - invalid or no data available');
      print('bigStores count: ${bigStores.length}');
      print('smallStores count: ${smallStores.length}');
      print('products count: ${products.length}');
    }
  }

  // Helper method to validate store data
  bool _hasInvalidStoreData(List<Store> bigStores, List<Store> smallStores) {
    // Check for stores that might be miscategorized
    bool hasInvalidBigStores = bigStores.any((store) => store.isBigStore == false);
    bool hasInvalidSmallStores = smallStores.any((store) => store.isBigStore == true);
    
    if (hasInvalidBigStores || hasInvalidSmallStores) {
      print('Warning: Found miscategorized stores!');
      return true;
    }
    return false;
  }

  @override
  Future<void> close() {
    _storeSubscription.cancel();
    _productSubscription.cancel();
    return super.close();
  }

  String _mapErrorToMessage(dynamic error) {
    if (error is NetworkException) {
      return 'Please check your internet connection';
    } else if (error is UnauthorizedException) {
      return 'Session expired. Please login again';
    } else if (error is ServerException) {
      return 'Server error: ${error.message}';
    } else {
      return 'An unexpected error occurred';
    }
  }
}
