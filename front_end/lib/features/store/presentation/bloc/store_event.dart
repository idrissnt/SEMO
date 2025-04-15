import 'package:equatable/equatable.dart';

abstract class StoreEvent extends Equatable {
  const StoreEvent();

  @override
  List<Object?> get props => [];
}

class InitializeStoreEvent extends StoreEvent {
  final String storeId;

  const InitializeStoreEvent({required this.storeId});

  @override
  List<Object?> get props => [storeId];
}

class LoadStoreProductsEvent extends StoreEvent {
  final String storeId;

  const LoadStoreProductsEvent({required this.storeId});

  @override
  List<Object?> get props => [storeId];
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
