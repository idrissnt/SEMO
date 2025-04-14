import 'package:equatable/equatable.dart';

abstract class StoreEvent extends Equatable {
  const StoreEvent();

  @override
  List<Object> get props => [];
}

class LoadAllStoresEvent extends StoreEvent {}

class LoadStoreByIdEvent extends StoreEvent {
  final String storeId;

  const LoadStoreByIdEvent(this.storeId);

  @override
  List<Object> get props => [storeId];
}
