import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/logger.dart';
import '../../../../domain/usecases/get_products_usecase.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final AppLogger _logger = AppLogger();

  ProductBloc({required this.getProductsUseCase}) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadProductsByCategory>(_onLoadProductsByCategory);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      _logger.info('Loading all products');
      emit(ProductLoading());
      final products = await getProductsUseCase.getAllProducts();
      
      _logger.debug('Loaded ${products.length} products');
      emit(ProductsLoaded(products));
    } catch (e) {
      _logger.error('Error loading products: $e');
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadProductsByCategory(
    LoadProductsByCategory event,
    Emitter<ProductState> emit,
  ) async {
    try {
      _logger.info('Loading products for category: ${event.category}');
      emit(ProductLoading());
      final products = await getProductsUseCase.getProductsByCategory(event.category);
      
      _logger.debug('Loaded ${products.length} products for category ${event.category}');
      emit(ProductsByCategoryLoaded(event.category, products));
    } catch (e) {
      _logger.error('Error loading products for category ${event.category}: $e');
      emit(ProductError(e.toString()));
    }
  }
}
