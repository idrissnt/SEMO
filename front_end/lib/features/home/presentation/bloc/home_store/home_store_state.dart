import 'package:equatable/equatable.dart';
import 'package:semo/features/store/domain/entities/product.dart';
import 'package:semo/features/store/domain/entities/search_result.dart';
import 'package:semo/features/store/domain/entities/store.dart';

/// Main composite state that holds all sub-states
class HomeStoreState extends Equatable {
  final StoreBrandsState storeBrandsState;
  final NearbyStoresState nearbyStoresState;
  final ProductsByCategoryState productsByCategoryState;
  final AutocompleteSuggestionsState autocompleteSuggestionsState;
  final SearchResultsState searchResultsState;

  const HomeStoreState({
    this.storeBrandsState = const StoreBrandsInitial(),
    this.nearbyStoresState = const NearbyStoresInitial(),
    this.productsByCategoryState = const ProductsByCategoryInitial(),
    this.autocompleteSuggestionsState = const AutocompleteSuggestionsInitial(),
    this.searchResultsState = const SearchResultsInitial(),
  });

  /// Create a copy of the current state with some values replaced
  HomeStoreState copyWith({
    StoreBrandsState? storeBrandsState,
    NearbyStoresState? nearbyStoresState,
    ProductsByCategoryState? productsByCategoryState,
    AutocompleteSuggestionsState? autocompleteSuggestionsState,
    SearchResultsState? searchResultsState,
  }) {
    return HomeStoreState(
      storeBrandsState: storeBrandsState ?? this.storeBrandsState,
      nearbyStoresState: nearbyStoresState ?? this.nearbyStoresState,
      productsByCategoryState: productsByCategoryState ?? this.productsByCategoryState,
      autocompleteSuggestionsState: autocompleteSuggestionsState ?? this.autocompleteSuggestionsState,
      searchResultsState: searchResultsState ?? this.searchResultsState,
    );
  }

  @override
  List<Object?> get props => [
        storeBrandsState,
        nearbyStoresState,
        productsByCategoryState,
        autocompleteSuggestionsState,
        searchResultsState,
      ];
}

//===========================================================================
// Store Brands States
//===========================================================================

abstract class StoreBrandsState extends Equatable {
  const StoreBrandsState();

  @override
  List<Object?> get props => [];
}

class StoreBrandsInitial extends StoreBrandsState {
  const StoreBrandsInitial();
}

class StoreBrandsLoading extends StoreBrandsState {
  const StoreBrandsLoading();
}

class StoreBrandsLoaded extends StoreBrandsState {
  final List<StoreBrand> storeBrands;

  const StoreBrandsLoaded(this.storeBrands);

  @override
  List<Object?> get props => [storeBrands];
}

class StoreBrandsError extends StoreBrandsState {
  final String message;

  const StoreBrandsError(this.message);

  @override
  List<Object?> get props => [message];
}

//===========================================================================
// Nearby Stores States
//===========================================================================

abstract class NearbyStoresState extends Equatable {
  const NearbyStoresState();

  @override
  List<Object?> get props => [];
}

class NearbyStoresInitial extends NearbyStoresState {
  const NearbyStoresInitial();
}

class NearbyStoresLoading extends NearbyStoresState {
  const NearbyStoresLoading();
}

class NearbyStoresLoaded extends NearbyStoresState {
  final List<NearbyStore> nearbyStores;

  const NearbyStoresLoaded(this.nearbyStores);

  @override
  List<Object?> get props => [nearbyStores];
}

class NearbyStoresError extends NearbyStoresState {
  final String message;

  const NearbyStoresError(this.message);

  @override
  List<Object?> get props => [message];
}

//===========================================================================
// Products By Category States
//===========================================================================

abstract class ProductsByCategoryState extends Equatable {
  const ProductsByCategoryState();

  @override
  List<Object?> get props => [];
}

class ProductsByCategoryInitial extends ProductsByCategoryState {
  const ProductsByCategoryInitial();
}

class ProductsByCategoryLoading extends ProductsByCategoryState {
  const ProductsByCategoryLoading();
}

class ProductsByCategoryLoaded extends ProductsByCategoryState {
  final List<ProductWithDetails> products;
  final String storeId;

  const ProductsByCategoryLoaded({
    required this.products,
    required this.storeId,
  });

  @override
  List<Object?> get props => [products, storeId];
}

class ProductsByCategoryError extends ProductsByCategoryState {
  final String message;

  const ProductsByCategoryError(this.message);

  @override
  List<Object?> get props => [message];
}

//===========================================================================
// Autocomplete Suggestions States
//===========================================================================

abstract class AutocompleteSuggestionsState extends Equatable {
  const AutocompleteSuggestionsState();

  @override
  List<Object?> get props => [];
}

class AutocompleteSuggestionsInitial extends AutocompleteSuggestionsState {
  const AutocompleteSuggestionsInitial();
}

class AutocompleteSuggestionsLoading extends AutocompleteSuggestionsState {
  const AutocompleteSuggestionsLoading();
}

class AutocompleteSuggestionsLoaded extends AutocompleteSuggestionsState {
  final List<String> suggestions;

  const AutocompleteSuggestionsLoaded(this.suggestions);

  @override
  List<Object?> get props => [suggestions];
}

class AutocompleteSuggestionsError extends AutocompleteSuggestionsState {
  final String message;

  const AutocompleteSuggestionsError(this.message);

  @override
  List<Object?> get props => [message];
}

//===========================================================================
// Search Results States
//===========================================================================

abstract class SearchResultsState extends Equatable {
  const SearchResultsState();

  @override
  List<Object?> get props => [];
}

class SearchResultsInitial extends SearchResultsState {
  const SearchResultsInitial();
}

class SearchResultsLoading extends SearchResultsState {
  const SearchResultsLoading();
}

class SearchResultsLoaded extends SearchResultsState {
  final SearchResult searchResult;

  const SearchResultsLoaded(this.searchResult);

  @override
  List<Object?> get props => [searchResult];
}

class SearchResultsError extends SearchResultsState {
  final String message;

  const SearchResultsError(this.message);

  @override
  List<Object?> get props => [message];
}
