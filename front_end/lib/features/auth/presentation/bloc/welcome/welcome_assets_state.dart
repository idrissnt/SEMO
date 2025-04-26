import 'package:equatable/equatable.dart';
import 'package:semo/features/auth/domain/entities/welcom_entity.dart';

/// Base class for all welcome assets states
abstract class WelcomeAssetsState extends Equatable {
  const WelcomeAssetsState();

  @override
  List<Object?> get props => [];
}

/// Initial state when no assets have been loaded yet
class WelcomeAssetsInitial extends WelcomeAssetsState {
  const WelcomeAssetsInitial();
}

/// Base state when assets are being loaded
class WelcomeAssetsLoading extends WelcomeAssetsState {
  final String? assetType;

  const WelcomeAssetsLoading({this.assetType});

  @override
  List<Object?> get props => [assetType];
}

/// State when all assets are being loaded
class AllAssetsLoading extends WelcomeAssetsLoading {
  const AllAssetsLoading() : super(assetType: 'all');
}

/// State when all assets have been loaded successfully
class AllAssetsLoaded extends WelcomeAssetsState {
  final CompanyAsset companyAsset;
  final StoreAsset storeAsset;
  final List<TaskAsset> taskAssets;

  const AllAssetsLoaded({
    required this.companyAsset,
    required this.storeAsset,
    required this.taskAssets,
  });

  @override
  List<Object?> get props => [companyAsset, storeAsset, taskAssets];
}

/// Base class for all welcome assets failure states
abstract class WelcomeAssetsFailureState extends WelcomeAssetsState {
  final String message;
  final bool canRetry;

  const WelcomeAssetsFailureState(
    this.message, {
    this.canRetry = true,
  });

  @override
  List<Object?> get props => [message, canRetry];
}

/// Generic welcome assets fetch failure
class WelcomeAssetsFetchFailure extends WelcomeAssetsFailureState {
  const WelcomeAssetsFetchFailure(
    String message, {
    bool canRetry = true,
  }) : super(message, canRetry: canRetry);
}

/// Welcome assets not found failure
class WelcomeAssetsNotFoundFailure extends WelcomeAssetsFailureState {
  const WelcomeAssetsNotFoundFailure(
    String message, {
    bool canRetry = true,
  }) : super(message, canRetry: canRetry);
}

/// Network failure (no internet connection)
class WelcomeAssetsNetworkFailure extends WelcomeAssetsFailureState {
  const WelcomeAssetsNetworkFailure(
    String message, {
    bool canRetry = true,
  }) : super(message, canRetry: canRetry);
}

/// Server failure (backend issue)
class WelcomeAssetsServerFailure extends WelcomeAssetsFailureState {
  const WelcomeAssetsServerFailure(
    String message, {
    bool canRetry = false,
  }) : super(message, canRetry: canRetry);
}

/// Generic welcome assets error
class WelcomeAssetsGenericFailure extends WelcomeAssetsFailureState {
  const WelcomeAssetsGenericFailure(
    String message, {
    bool canRetry = false,
  }) : super(message, canRetry: canRetry);
}
