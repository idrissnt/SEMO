import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/domain/entities/welcom_entity.dart';
import 'package:semo/features/auth/domain/exceptions/welcom/welcome_exceptions.dart';
import 'package:semo/features/auth/domain/repositories/welcom_repository.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_event.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_state.dart';

/// BLoC for managing welcome assets state
class WelcomeAssetsBloc extends Bloc<WelcomeAssetsEvent, WelcomeAssetsState> {
  final WelcomeRepository _welcomeRepository;
  final AppLogger _logger;

  WelcomeAssetsBloc({
    required WelcomeRepository welcomeRepository,
    AppLogger? logger,
  })  : _welcomeRepository = welcomeRepository,
        _logger = logger ?? AppLogger(),
        super(const WelcomeAssetsInitial()) {
    on<LoadCompanyAssetEvent>(_onLoadCompanyAsset);
    on<LoadStoreAssetEvent>(_onLoadStoreAsset);
    on<LoadTaskAssetEvent>(_onLoadTaskAsset);
    on<LoadAllAssetsEvent>(_onLoadAllAssets);
  }

  /// Handles the LoadCompanyAssetEvent to load only company asset
  Future<void> _onLoadCompanyAsset(
    LoadCompanyAssetEvent event,
    Emitter<WelcomeAssetsState> emit,
  ) async {
    _logger.info('Loading company asset');
    emit(const CompanyAssetLoading());

    final result = await _welcomeRepository.getCompanyAsset();

    result.fold(
      (companyAsset) {
        _logger.info('Company asset loaded successfully');
        emit(CompanyAssetLoaded(companyAsset));
      },
      (error) {
        _logger.error('Failed to load company asset', error: error);
        _mapErrorToState(emit, error, 'company asset');
      },
    );
  }

  /// Handles the LoadStoreAssetEvent to load only store asset
  Future<void> _onLoadStoreAsset(
    LoadStoreAssetEvent event,
    Emitter<WelcomeAssetsState> emit,
  ) async {
    _logger.info('Loading store asset');
    emit(const StoreAssetLoading());

    final result = await _welcomeRepository.getStoreAsset();

    result.fold(
      (storeAsset) {
        _logger.info('Store asset loaded successfully');
        emit(StoreAssetLoaded(storeAsset));
      },
      (error) {
        _logger.error('Failed to load store asset', error: error);
        _mapErrorToState(emit, error, 'store asset');
      },
    );
  }

  /// Handles the LoadTaskAssetEvent to load only task asset
  Future<void> _onLoadTaskAsset(
    LoadTaskAssetEvent event,
    Emitter<WelcomeAssetsState> emit,
  ) async {
    _logger.info('Loading task asset');
    emit(const TaskAssetLoading());

    final result = await _welcomeRepository.getTaskAsset();

    _logger.info('Task asset result: $result');

    result.fold(
      (taskAsset) {
        _logger.info('Task asset loaded successfully');
        _logger.info('Task asset: ${taskAsset.firstImage}');
        emit(TaskAssetLoaded(taskAsset));
      },
      (error) {
        _logger.error('Failed to load task asset', error: error);
        _mapErrorToState(emit, error, 'task asset');
      },
    );
  }

  /// Maps domain exceptions to specific UI states
  /// This centralizes error handling logic for all asset types
  void _mapErrorToState(
    Emitter<WelcomeAssetsState> emit,
    WelcomeException error,
    String assetType,
  ) {
    if (error is WelcomeAssetsNotFoundException) {
      emit(WelcomeAssetsNotFoundFailure(
        'The requested $assetType could not be found',
      ));
    } else if (error is WelcomeAssetsValidationException) {
      emit(WelcomeAssetsValidationFailure(
        'Invalid $assetType data: ${error.message}',
      ));
    } else {
      // For all other errors, use a generic error state
      emit(WelcomeAssetsError(
        error: error,
        message: 'Failed to load $assetType: ${error.message}',
      ));
    }
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
      final taskResult = await _welcomeRepository.getTaskAsset();

      // Handle company asset result
      CompanyAsset? companyAsset;
      WelcomeException? firstError;

      companyResult.fold(
        (asset) => companyAsset = asset,
        (error) {
          firstError = error;
          _logger.error('Failed to load company asset', error: error);
        },
      );

      // If there was an error with company asset, report it
      if (firstError != null) {
        _mapErrorToState(emit, firstError!, 'all assets');
        return;
      }

      // Handle store asset result
      StoreAsset? storeAsset;
      storeResult.fold(
        (asset) => storeAsset = asset,
        (error) {
          firstError = error;
          _logger.error('Failed to load store asset', error: error);
        },
      );

      // If there was an error with store asset, report it
      if (firstError != null) {
        _mapErrorToState(emit, firstError!, 'all assets');
        return;
      }

      // Handle task asset result
      TaskAsset? taskAsset;
      taskResult.fold(
        (asset) => taskAsset = asset,
        (error) {
          firstError = error;
          _logger.error('Failed to load task asset', error: error);
        },
      );

      // If there was an error with task asset, report it
      if (firstError != null) {
        _mapErrorToState(emit, firstError!, 'all assets');
        return;
      }

      // All results were successful
      _logger.info('All assets loaded successfully');
      emit(AllAssetsLoaded(
        companyAsset: companyAsset!,
        storeAsset: storeAsset!,
        taskAsset: taskAsset!,
      ));
    } catch (e) {
      _logger.error('Unexpected error loading all assets', error: e);
      emit(WelcomeAssetsError(
        error: e,
        message: 'An unexpected error occurred while loading assets',
      ));
    }
  }
}
