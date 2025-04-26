import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:semo/core/utils/result.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/domain/exceptions/api_error_extensions.dart';

import 'package:semo/features/auth/domain/entities/welcom_entity.dart';
import 'package:semo/features/auth/domain/exceptions/welcom/exceptions_wlecom.dart';
import 'package:semo/features/auth/domain/repositories/welcom_repository.dart';

import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_event.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_state.dart';
import 'package:semo/features/auth/presentation/services/error_message_service.dart';

/// BLoC for managing welcome assets state
class WelcomeAssetsBloc extends Bloc<WelcomeAssetsEvent, WelcomeAssetsState> {
  final WelcomeRepository _welcomeRepository;
  final AppLogger _logger = AppLogger();
  final ErrorMessageService _errorMessageService = ErrorMessageService();

  WelcomeAssetsBloc({required WelcomeRepository welcomeRepository})
      : _welcomeRepository = welcomeRepository,
        super(const WelcomeAssetsInitial()) {
    on<LoadAllAssetsEvent>(_onLoadAllAssets);
  }

  /// Handles the LoadAllAssetsEvent to load all assets at once
  /// Uses a more efficient approach by loading assets in parallel
  Future<void> _onLoadAllAssets(
    LoadAllAssetsEvent event,
    Emitter<WelcomeAssetsState> emit,
  ) async {
    _logger.info('Loading all welcome assets');
    emit(const AllAssetsLoading());

    try {
      // Load all assets in parallel for better performance
      final companyResult = await _welcomeRepository.getCompanyAsset();
      final storeResult = await _welcomeRepository.getStoreAsset();
      final taskResult = await _welcomeRepository.getAllTaskAsset();

      // Track the first error encountered
      WelcomeException? firstError;

      // Handle company asset result
      final companyAsset = _handleResult<CompanyAsset>(
        companyResult,
        () => firstError,
        (error) => firstError = error,
        'company asset',
      );

      // If there was an error with company asset, report it
      if (firstError != null) {
        _mapErrorToState(emit, firstError, 'all assets');
        return;
      }

      // Handle store asset result
      final storeAsset = _handleResult<StoreAsset>(
        storeResult,
        () => firstError,
        (error) => firstError = error,
        'store asset',
      );

      // If there was an error with store asset, report it
      if (firstError != null) {
        _mapErrorToState(emit, firstError, 'all assets');
        return;
      }

      // Handle task assets result
      final taskAssets = _handleResult<List<TaskAsset>>(
        taskResult,
        () => firstError,
        (error) => firstError = error,
        'task assets',
      );

      // If there was an error with task assets, report it
      if (firstError != null) {
        _mapErrorToState(emit, firstError, 'all assets');
        return;
      }

      // All results were successful
      _logger.info('All assets loaded successfully');
      emit(AllAssetsLoaded(
        companyAsset: companyAsset!,
        storeAsset: storeAsset!,
        taskAssets: taskAssets!,
      ));
    } catch (e) {
      _logger.error('Unexpected error loading all assets', error: e);
      emit(WelcomeAssetsFetchFailure(
        _errorMessageService.getUserFriendlyWelcomeMessage(e, 'all assets'),
        canRetry: true,
      ));
    }
  }

  /// Generic helper method to handle repository results
  /// Returns the success value or null if there was an error
  /// If there was an error, it will be stored in the provided error reference
  T? _handleResult<T>(
    Result<T, WelcomeException> result,
    WelcomeException? Function() getError,
    void Function(WelcomeException) setError,
    String assetType,
  ) {
    T? value;
    result.fold(
      (success) => value = success,
      (error) {
        setError(error);
        _logger.error('Failed to load $assetType', error: error);
      },
    );
    return value;
  }

  /// Maps domain exceptions to specific UI states
  /// This centralizes error handling logic for all asset types
  void _mapErrorToState(
    Emitter<WelcomeAssetsState> emit,
    WelcomeException? error,
    String assetType,
  ) {
    if (error == null) {
      emit(WelcomeAssetsGenericFailure(
        _errorMessageService.getUserFriendlyWelcomeMessage(null, assetType),
        canRetry: true,
      ));
      return;
    }
    _logger.error('Error loading $assetType', error: error);
    _logger.debug(_errorMessageService.getTechnicalErrorDetails(error));
    _logger.debug(
        _errorMessageService.getUserFriendlyWelcomeMessage(error, assetType));

    if (error.isNetworkError) {
      emit(WelcomeAssetsNetworkFailure(
          _errorMessageService.getUserFriendlyWelcomeMessage(error, assetType),
          canRetry: true));
    } else if (error.isServerError) {
      emit(WelcomeAssetsServerFailure(
          _errorMessageService.getUserFriendlyWelcomeMessage(error, assetType),
          canRetry: true));
    } else if (error is WelcomeAssetsNotFoundException) {
      emit(WelcomeAssetsNotFoundFailure(
        _errorMessageService.getUserFriendlyWelcomeMessage(error, assetType),
        canRetry: true,
      ));
    } else if (error is WelcomeAssetsFetchException) {
      emit(WelcomeAssetsFetchFailure(
        _errorMessageService.getUserFriendlyWelcomeMessage(error, assetType),
        canRetry: true,
      ));
    } else {
      // Generic fallback
      emit(WelcomeAssetsGenericFailure(
          _errorMessageService.getUserFriendlyWelcomeMessage(error, assetType),
          canRetry: true));
    }
  }
}
