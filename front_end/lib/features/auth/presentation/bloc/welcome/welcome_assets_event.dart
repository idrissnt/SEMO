import 'package:equatable/equatable.dart';

/// Base class for all welcome assets events
abstract class WelcomeAssetsEvent extends Equatable {
  const WelcomeAssetsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all assets at once
class LoadAllAssetsEvent extends WelcomeAssetsEvent {
  const LoadAllAssetsEvent();
}
