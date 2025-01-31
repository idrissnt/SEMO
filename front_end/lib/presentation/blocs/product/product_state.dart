import 'package:equatable/equatable.dart';
import '../../../../domain/entities/product.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductsLoaded extends ProductState {
  final List<Product> products;
  final Map<String, List<Product>> productCategories;

  ProductsLoaded(this.products)
      : productCategories = _categorizeProducts(products);

  @override
  List<Object> get props => [products, productCategories];

  static Map<String, List<Product>> _categorizeProducts(
      List<Product> products) {
    final Map<String, List<Product>> categorizedProducts = {};

    for (var product in products) {
      final category = product.categoryName;
      if (!categorizedProducts.containsKey(category)) {
        categorizedProducts[category] = [];
      }
      categorizedProducts[category]!.add(product);
    }

    return categorizedProducts;
  }
}

class ProductsByCategoryLoaded extends ProductState {
  final String category;
  final List<Product> products;

  const ProductsByCategoryLoaded(this.category, this.products);

  @override
  List<Object> get props => [category, products];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}
