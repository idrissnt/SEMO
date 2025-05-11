import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:semo/features/order/presentation/widgets/state_handler/home_store/loading_state_widget/shimmer_widgets.dart';

import 'package:semo/features/order/presentation/bloc/home_store/home_store_bloc.dart';
import 'package:semo/features/order/presentation/bloc/home_store/home_store_event.dart';
import 'package:semo/features/order/presentation/bloc/home_store/home_store_state.dart';
import 'package:semo/features/store/domain/entities/product.dart';
import 'package:semo/features/store/domain/entities/search_result.dart';
import 'package:semo/features/store/domain/entities/store.dart';

import 'package:semo/features/order/presentation/widgets/state_handler/home_store/error_state_widget.dart';

/// A utility class that handles state management for widgets
/// Provides consistent UI for loading, error, and success states
class HomeStoreStateHandler {
  // Common retry text
  static const String _retryText = 'Réessayer';

  /// //===========================================================================
  /// Generic state handler for all state types
  /// //===========================================================================
  static Widget _handleGenericState<T, S extends Equatable>({
    required BuildContext context,
    required S state,
    required Widget Function(T data) onSuccess,
    required bool isLoading,
    required bool isSuccess,
    required T? successData,
    required bool isError,
    required String? errorMessage,
    required IconData errorIcon,
    required VoidCallback? onRetry,
    String? loadingMessage,
    bool useShimmerLoading = false,
    ShimmerType shimmerType = ShimmerType.none,
  }) {
    // Handle loading state
    if (isLoading) {
      return LoadingStateWidget(
        message: loadingMessage,
        useShimmer: useShimmerLoading,
        shimmerType: shimmerType,
      );
    }

    // Handle success state
    if (isSuccess && successData != null) {
      return onSuccess(successData);
    }

    // Handle error state
    if (isError && errorMessage != null) {
      return ErrorStateWidget(
        message: errorMessage,
        icon: errorIcon,
        showRetryButton: true,
        retryText: _retryText,
        onRetry: onRetry,
      );
    }

    // Default loading state
    return LoadingStateWidget(
      message: loadingMessage,
      useShimmer: useShimmerLoading,
    );
  }

  /// //===========================================================================
  /// Handles store brands state and returns appropriate widgets
  /// //===========================================================================
  static Widget handleStoreBrandsState({
    required BuildContext context,
    required StoreBrandsState state,
    required Widget Function(List<StoreBrand> data) onSuccess,
    String? loadingMessage,
    bool useShimmerLoading = false,
    VoidCallback? onRetry,
  }) {
    // For initial state, trigger loading
    if (state is StoreBrandsInitial) {
      _retryLoadStoreBrands(context);
    }

    return _handleGenericState<List<StoreBrand>, StoreBrandsState>(
      context: context,
      state: state,
      onSuccess: onSuccess,
      isLoading: state is StoreBrandsLoading,
      isSuccess: state is StoreBrandsLoaded,
      successData: state is StoreBrandsLoaded ? state.storeBrands : null,
      isError: state is StoreBrandsError,
      errorMessage: state is StoreBrandsError ? state.message : null,
      errorIcon: Icons.error_outline,
      onRetry: onRetry ?? () => _retryLoadStoreBrands(context),
      loadingMessage: loadingMessage ?? 'Chargement des marques...',
      useShimmerLoading: useShimmerLoading,
      shimmerType: ShimmerType.storeBrands,
    );
  }

  /// //===========================================================================
  /// Handles nearby stores state and returns appropriate widgets
  /// //===========================================================================
  static Widget handleNearbyStoresState({
    required BuildContext context,
    required NearbyStoresState state,
    required Widget Function(List<NearbyStore> data) onSuccess,
    String? loadingMessage,
    bool useShimmerLoading = false,
    VoidCallback? onRetry,
    String? address,
  }) {
    return _handleGenericState<List<NearbyStore>, NearbyStoresState>(
      context: context,
      state: state,
      onSuccess: onSuccess,
      isLoading: state is NearbyStoresLoading,
      isSuccess: state is NearbyStoresLoaded,
      successData: state is NearbyStoresLoaded ? state.nearbyStores : null,
      isError: state is NearbyStoresError,
      errorMessage: state is NearbyStoresError ? state.message : null,
      errorIcon: Icons.location_off,
      onRetry:
          onRetry ?? () => _retryLoadNearbyStores(context, address: address),
      loadingMessage: loadingMessage ?? 'Recherche de magasins à proximité...',
      useShimmerLoading: useShimmerLoading,
      shimmerType: ShimmerType.nearbyStores,
    );
  }

  /// //===========================================================================
  /// Handles products by category state and returns appropriate widgets
  /// //===========================================================================
  static Widget handleProductsByCategoryState({
    required BuildContext context,
    required ProductsByCategoryState state,
    required Widget Function(List<ProductWithDetails> data, String storeId)
        onSuccess,
    String? loadingMessage,
    bool useShimmerLoading = false,
    VoidCallback? onRetry,
    String? storeId,
    String? storeSlug,
  }) {
    // Special handling for ProductsByCategoryLoaded since it has multiple return values
    if (state is ProductsByCategoryLoaded) {
      return onSuccess(state.products, state.storeId);
    }

    return _handleGenericState<List<ProductWithDetails>,
        ProductsByCategoryState>(
      context: context,
      state: state,
      // This won't be called due to special handling above, but needed for the method signature
      onSuccess: (products) => const SizedBox(),
      isLoading: state is ProductsByCategoryLoading,
      isSuccess: false, // Handled separately above
      successData: null, // Handled separately above
      isError: state is ProductsByCategoryError,
      errorMessage: state is ProductsByCategoryError ? state.message : null,
      errorIcon: Icons.shopping_bag_outlined,
      onRetry: onRetry ??
          () => _retryLoadProductsByCategory(context,
              storeId: storeId ?? '', storeSlug: storeSlug ?? ''),
      loadingMessage: loadingMessage ?? 'Chargement des produits...',
      useShimmerLoading: useShimmerLoading,
      shimmerType: ShimmerType.products,
    );
  }

  /// //===========================================================================
  /// Handles autocomplete suggestions state and returns appropriate widgets
  /// //===========================================================================
  static Widget handleAutocompleteSuggestionsState({
    required BuildContext context,
    required AutocompleteSuggestionsState state,
    required Widget Function(List<String> suggestions) onSuccess,
    String? loadingMessage,
    bool useShimmerLoading = false,
    VoidCallback? onRetry,
    String? query,
  }) {
    return _handleGenericState<List<String>, AutocompleteSuggestionsState>(
      context: context,
      state: state,
      onSuccess: onSuccess,
      isLoading: state is AutocompleteSuggestionsLoading,
      isSuccess: state is AutocompleteSuggestionsLoaded,
      successData:
          state is AutocompleteSuggestionsLoaded ? state.suggestions : null,
      isError: state is AutocompleteSuggestionsError,
      errorMessage:
          state is AutocompleteSuggestionsError ? state.message : null,
      errorIcon: Icons.search_off,
      onRetry: onRetry ??
          () => _retryLoadAutocompleteSuggestions(context, query: query ?? ''),
      loadingMessage: loadingMessage ?? 'Chargement des suggestions...',
      useShimmerLoading: useShimmerLoading,
      shimmerType: ShimmerType.autocompleteSuggestions,
    );
  }

  /// //===========================================================================
  /// Handles search results state and returns appropriate widgets
  /// //===========================================================================
  static Widget handleSearchResultsState({
    required BuildContext context,
    required SearchResultsState state,
    required Widget Function(SearchResult searchResult) onSuccess,
    String? loadingMessage,
    bool useShimmerLoading = false,
    VoidCallback? onRetry,
    String? query,
    int? page,
    int? pageSize,
  }) {
    return _handleGenericState<SearchResult, SearchResultsState>(
      context: context,
      state: state,
      onSuccess: onSuccess,
      isLoading: state is SearchResultsLoading,
      isSuccess: state is SearchResultsLoaded,
      successData: state is SearchResultsLoaded ? state.searchResult : null,
      isError: state is SearchResultsError,
      errorMessage: state is SearchResultsError ? state.message : null,
      errorIcon: Icons.search_off,
      onRetry: onRetry ??
          () => _retrySearchSubmitted(context,
              query: query ?? '', page: page, pageSize: pageSize),
      loadingMessage: loadingMessage ?? 'Recherche en cours...',
      useShimmerLoading: useShimmerLoading,
      shimmerType: ShimmerType.searchResults,
    );
  }

  /// //===========================================================================
  /// Helper methods for retrying operations
  /// //===========================================================================
  static void _retryLoadStoreBrands(BuildContext context) {
    context.read<HomeStoreBloc>().add(const LoadAllStoreBrandsEvent());
  }

  static void _retryLoadNearbyStores(BuildContext context, {String? address}) {
    if (address != null) {
      context
          .read<HomeStoreBloc>()
          .add(LoadNearbyStoresEvent(address: address));
    }
  }

  static void _retryLoadProductsByCategory(BuildContext context,
      {required String storeId, required String storeSlug}) {
    context.read<HomeStoreBloc>().add(
          LoadProductsByCategoryEvent(
            storeId: storeId,
            storeSlug: storeSlug,
          ),
        );
  }

  static void _retryLoadAutocompleteSuggestions(BuildContext context,
      {required String query}) {
    if (query.isNotEmpty) {
      context
          .read<HomeStoreBloc>()
          .add(HomeStoreSearchQueryChangedEvent(query: query));
    }
  }

  static void _retrySearchSubmitted(
    BuildContext context, {
    required String query,
    int? page,
    int? pageSize,
  }) {
    if (query.isNotEmpty) {
      context.read<HomeStoreBloc>().add(HomeStoreSearchSubmittedEvent(
            query: query,
            page: page,
            pageSize: pageSize,
          ));
    }
  }

  /// //===========================================================================
  /// Schedule a retry after a delay (useful for automatic retries)
  /// //===========================================================================
  static void scheduleRetryLoad(BuildContext context,
      {int delayMilliseconds = 3000, VoidCallback? retryAction}) {
    Future.delayed(Duration(milliseconds: delayMilliseconds), () {
      // Only retry if the context is still valid
      if (context.mounted) {
        retryAction?.call();
      }
    });
  }
}
