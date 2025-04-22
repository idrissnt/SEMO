import 'package:equatable/equatable.dart';

/// Base class for all welcome assets events
abstract class WelcomeAssetsEvent extends Equatable {
  const WelcomeAssetsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load only company asset
class LoadCompanyAssetEvent extends WelcomeAssetsEvent {
  const LoadCompanyAssetEvent();
}

/// Event to load only store asset
class LoadStoreAssetEvent extends WelcomeAssetsEvent {
  const LoadStoreAssetEvent();
}

/// Event to load only task asset
class LoadTaskAssetEvent extends WelcomeAssetsEvent {
  const LoadTaskAssetEvent();
}

/// Event to load all assets at once
class LoadAllAssetsEvent extends WelcomeAssetsEvent {
  const LoadAllAssetsEvent();
}
