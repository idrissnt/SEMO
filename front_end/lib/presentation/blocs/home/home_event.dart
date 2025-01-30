import 'package:equatable/equatable.dart';
import '../store/store_state.dart';
import '../product/product_state.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {}

class HomeStoreStateChanged extends HomeEvent {
  final StoreState storeState;

  const HomeStoreStateChanged(this.storeState);

  @override
  List<Object?> get props => [storeState];
}

class HomeProductStateChanged extends HomeEvent {
  final ProductState productState;

  const HomeProductStateChanged(this.productState);

  @override
  List<Object?> get props => [productState];
}
