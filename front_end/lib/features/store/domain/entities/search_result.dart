import 'product.dart';
import 'store.dart';

/// Represents search results, which may be global (across stores) or store-specific
class SearchResult {
  final Map<String, StoreSearchResult>? storeResults; // For global search
  final List<ProductWithDetails>? products; // For store-specific search
  final SearchMetadata metadata;

  const SearchResult({
    this.storeResults,
    this.products,
    required this.metadata,
  });

  /// Whether this is a global search result (across multiple stores)
  bool get isGlobalSearch => storeResults != null;
}

/// Search results for a specific store
class StoreSearchResult {
  final StoreBrand store;
  final String categoryPath;
  final List<ProductWithDetails> products;

  const StoreSearchResult({
    required this.store,
    required this.categoryPath,
    required this.products,
  });
}

/// Metadata for search results
class SearchMetadata {
  // For store-specific search
  final int? totalProducts;

  // For global search
  final Map<String, int>? storeCounts;

  const SearchMetadata({
    this.totalProducts,
    this.storeCounts,
  });

  /// Whether this metadata is for a store-specific search
  bool get isStoreSpecific => totalProducts != null;
}
