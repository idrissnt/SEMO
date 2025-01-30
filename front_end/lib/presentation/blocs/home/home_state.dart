import 'package:equatable/equatable.dart';
import '../../../domain/entities/store.dart';
import '../../../domain/entities/product.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Store> bigStores;
  final List<Store> smallStores;
  final List<Product> products;
  final Map<String, List<Product>> productCategories;

  const HomeLoaded({
    required this.bigStores,
    required this.smallStores,
    required this.products,
    this.productCategories = const {},
  });

  @override
  List<Object?> get props =>
      [bigStores, smallStores, products, productCategories];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
