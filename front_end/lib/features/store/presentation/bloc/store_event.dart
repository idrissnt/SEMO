import 'package:equatable/equatable.dart';

abstract class StoreEvent extends Equatable {
  const StoreEvent();

  @override
  List<Object?> get props => [];
}

class InitializeStoreEvent extends StoreEvent {
  final String storeId;
  final String storeSlug;

  const InitializeStoreEvent({
    required this.storeId,
    required this.storeSlug,
  });

  @override
  List<Object?> get props => [storeId, storeSlug];
}

class LoadStoreProductsEvent extends StoreEvent {
  final String storeId;
  final String storeSlug;

  const LoadStoreProductsEvent({
    required this.storeId,
    required this.storeSlug,
  });

  @override
  List<Object?> get props => [storeId, storeSlug];
}

class StoreSearchQueryChangedEvent extends StoreEvent {
  final String query;
  final String storeId;

  const StoreSearchQueryChangedEvent({
    required this.query,
    required this.storeId,
  });

  @override
  List<Object?> get props => [query, storeId];
}

class StoreSearchSubmittedEvent extends StoreEvent {
  final String query;
  final String storeId;
  final int? page;
  final int? pageSize;

  const StoreSearchSubmittedEvent({
    required this.query,
    required this.storeId,
    this.page,
    this.pageSize,
  });

  @override
  List<Object?> get props => [query, storeId, page, pageSize];
}
