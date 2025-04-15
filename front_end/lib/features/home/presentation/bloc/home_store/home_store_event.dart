import 'package:equatable/equatable.dart';

abstract class HomeStoreEvent extends Equatable {
  const HomeStoreEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllStoreBrandsEvent extends HomeStoreEvent {
  const LoadAllStoreBrandsEvent();
}

class LoadNearbyStoresEvent extends HomeStoreEvent {
  final String address;

  const LoadNearbyStoresEvent({required this.address});

  @override
  List<Object?> get props => [address];
}

class LoadProductsByCategoryEvent extends HomeStoreEvent {
  final String storeId;

  const LoadProductsByCategoryEvent({required this.storeId});

  @override
  List<Object?> get props => [storeId];
}

class HomeStoreSearchQueryChangedEvent extends HomeStoreEvent {
  final String query;

  const HomeStoreSearchQueryChangedEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

class HomeStoreSearchSubmittedEvent extends HomeStoreEvent {
  final String query;
  final int? page;
  final int? pageSize;

  const HomeStoreSearchSubmittedEvent({
    required this.query,
    this.page,
    this.pageSize,
  });

  @override
  List<Object?> get props => [query, page, pageSize];
}
