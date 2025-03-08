import 'package:equatable/equatable.dart';
import '../../../data/models/store/store_model.dart';
import '../../../domain/entities/stores/store.dart';

abstract class StoreState extends Equatable {
  const StoreState();

  @override
  List<Object> get props => [];
}

class StoreInitial extends StoreState {}

class StoreLoading extends StoreState {}

class AllStoresLoaded extends StoreState {
  final List<StoreModel> bigStores;
  final List<StoreModel> smallStores;
  final List<StoreModel> storesByName;

  const AllStoresLoaded({
    required this.bigStores,
    required this.smallStores,
    required this.storesByName,
  });

  @override
  List<Object> get props => [bigStores, smallStores, storesByName];
}

class StoreLoaded extends StoreState {
  final Store store;

  const StoreLoaded(this.store);

  @override
  List<Object> get props => [store];
}

class StoreError extends StoreState {
  final String message;

  const StoreError(this.message);

  @override
  List<Object> get props => [message];
}
