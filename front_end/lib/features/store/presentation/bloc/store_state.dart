import 'package:equatable/equatable.dart';
import 'package:semo/features/store/domain/entities/product.dart';
import 'package:semo/features/store/domain/entities/search_result.dart';

abstract class StoreState extends Equatable {
  const StoreState();

  @override
  List<Object?> get props => [];
}

class StoreInitial extends StoreState {
  const StoreInitial();
}

class StoreLoading extends StoreState {
  const StoreLoading();
}

class StoreError extends StoreState {
  final String message;

  const StoreError(this.message);

  @override
  List<Object?> get props => [message];
}

class StoreProductsLoaded extends StoreState {
  final List<ProductWithDetails> products;
  final String storeId;

  const StoreProductsLoaded({
    required this.products,
    required this.storeId,
  });

  @override
  List<Object?> get props => [products, storeId];
}

class StoreAutocompleteSuggestionsLoaded extends StoreState {
  final List<String> suggestions;
  final String storeId;

  const StoreAutocompleteSuggestionsLoaded({
    required this.suggestions,
    required this.storeId,
  });

  @override
  List<Object?> get props => [suggestions, storeId];
}

class StoreSearchResultsLoaded extends StoreState {
  final SearchResult searchResult;
  final String storeId;

  const StoreSearchResultsLoaded({
    required this.searchResult,
    required this.storeId,
  });

  @override
  List<Object?> get props => [searchResult, storeId];
}
