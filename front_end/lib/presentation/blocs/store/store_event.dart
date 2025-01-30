import 'package:equatable/equatable.dart';

abstract class StoreEvent extends Equatable {
  const StoreEvent();

  @override
  List<Object> get props => [];
}

class LoadBigStores extends StoreEvent {}

class LoadSmallStores extends StoreEvent {}

class LoadAllStores extends StoreEvent {}
