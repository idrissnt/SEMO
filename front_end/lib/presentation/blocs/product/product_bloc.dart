// ignore_for_file: avoid_print

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/usecases/get_products_usecase.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;

  ProductBloc({required this.getProductsUseCase}) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadProductsByCategory>(_onLoadProductsByCategory);
  }

  void _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    print('ProductBloc: Loading all products');
    emit(ProductLoading());
    try {
      final products = await getProductsUseCase.getAllProducts();
      print('ProductBloc: Loaded ${products.length} products');
      emit(ProductsLoaded(products));
    } catch (e) {
      print('ProductBloc: Error loading products - $e');
      emit(ProductError(e.toString()));
    }
  }

  void _onLoadProductsByCategory(
      LoadProductsByCategory event, Emitter<ProductState> emit) async {
    print('ProductBloc: Loading products for category ${event.category}');
    emit(ProductLoading());
    try {
      final products =
          await getProductsUseCase.getProductsByCategory(event.category);
      print(
          'ProductBloc: Loaded ${products.length} products for category ${event.category}');
      emit(ProductsByCategoryLoaded(event.category, products));
    } catch (e) {
      print('ProductBloc: Error loading products by category - $e');
      emit(ProductError(e.toString()));
    }
  }
}
