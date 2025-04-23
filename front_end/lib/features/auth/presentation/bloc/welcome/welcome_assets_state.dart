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
  const WelcomeAssetsLoading();
}

/// State when company asset is being loaded
class CompanyAssetLoading extends WelcomeAssetsLoading {
  const CompanyAssetLoading();
}

/// State when store asset is being loaded
class StoreAssetLoading extends WelcomeAssetsLoading {
  const StoreAssetLoading();
}

/// State when task asset is being loaded
class TaskAssetLoading extends WelcomeAssetsLoading {
  const TaskAssetLoading();
}

/// State when all assets are being loaded
class AllAssetsLoading extends WelcomeAssetsLoading {
  const AllAssetsLoading();
}

/// State when only company asset has been loaded
class CompanyAssetLoaded extends WelcomeAssetsState {
  final CompanyAsset companyAsset;

  const CompanyAssetLoaded(this.companyAsset);

  @override
  List<Object?> get props => [companyAsset];
}

/// State when only store asset has been loaded
class StoreAssetLoaded extends WelcomeAssetsState {
  final StoreAsset storeAsset;

  const StoreAssetLoaded(this.storeAsset);

  @override
  List<Object?> get props => [storeAsset];
}

/// State when task assets have been loaded
class TaskAssetLoaded extends WelcomeAssetsState {
  final List<TaskAsset> taskAssets;

  const TaskAssetLoaded(this.taskAssets);

  @override
  List<Object?> get props => [taskAssets];
}

/// State when an error occurs while loading welcome assets
class WelcomeAssetsError extends WelcomeAssetsState {
  final Object error;
  final String message;

  const WelcomeAssetsError({
    required this.error,
    required this.message,
  });

  @override
  List<Object?> get props => [error, message];
}

/// State when welcome assets are not found
class WelcomeAssetsNotFoundFailure extends WelcomeAssetsState {
  final String message;

  const WelcomeAssetsNotFoundFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when welcome assets validation fails
class WelcomeAssetsValidationFailure extends WelcomeAssetsState {
  final String message;

  const WelcomeAssetsValidationFailure(this.message);

  @override
  List<Object?> get props => [message];
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
