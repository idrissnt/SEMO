import 'package:equatable/equatable.dart';
import 'package:semo/features/store/domain/entities/product.dart';
import 'package:semo/features/store/domain/entities/search_result.dart';
import 'package:semo/features/store/domain/entities/store.dart';

abstract class HomeStoreState extends Equatable {
  const HomeStoreState();

  @override
  List<Object?> get props => [];
}

class HomeStoreInitial extends HomeStoreState {
  const HomeStoreInitial();
}

class HomeStoreLoading extends HomeStoreState {
  const HomeStoreLoading();
}

class HomeStoreError extends HomeStoreState {
  final String message;

  const HomeStoreError(this.message);

  @override
  List<Object?> get props => [message];
}

class StoreBrandsLoaded extends HomeStoreState {
  final List<StoreBrand> storeBrands;

  const StoreBrandsLoaded(this.storeBrands);

  @override
  List<Object?> get props => [storeBrands];
}

class NearbyStoresLoaded extends HomeStoreState {
  final List<NearbyStore> nearbyStores;

  const NearbyStoresLoaded(this.nearbyStores);

  @override
  List<Object?> get props => [nearbyStores];
}

class ProductsByCategoryLoaded extends HomeStoreState {
  final List<ProductWithDetails> products;
  final String storeId;

  const ProductsByCategoryLoaded({
    required this.products,
    required this.storeId,
  });

  @override
  List<Object?> get props => [products, storeId];
}

class HomeStoreAutocompleteSuggestionsLoaded extends HomeStoreState {
  final List<String> suggestions;

  const HomeStoreAutocompleteSuggestionsLoaded(this.suggestions);

  @override
  List<Object?> get props => [suggestions];
}

class HomeStoreSearchResultsLoaded extends HomeStoreState {
  final SearchResult searchResult;

  const HomeStoreSearchResultsLoaded(this.searchResult);

  @override
  List<Object?> get props => [searchResult];
}
