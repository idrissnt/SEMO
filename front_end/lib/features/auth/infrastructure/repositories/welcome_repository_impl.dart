import 'package:semo/core/domain/services/api_client.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/utils/result.dart';
import 'package:semo/features/auth/domain/entities/welcom_entity.dart';
import 'package:semo/features/auth/domain/exceptions/welcom/welcome_exception_mapper.dart';
import 'package:semo/features/auth/domain/exceptions/welcom/welcome_exceptions.dart';
import 'package:semo/features/auth/domain/repositories/welcom_repository.dart';
import 'package:semo/features/auth/infrastructure/repositories/services/welcome_service.dart';

/// Implementation of the WelcomeRepository interface that delegates to specialized services
class WelcomeRepositoryImpl implements WelcomeRepository {
  final WelcomeService _welcomeService;
  final AppLogger _logger;

  WelcomeRepositoryImpl({
    required ApiClient apiClient,
    required AppLogger logger,
    required WelcomeExceptionMapper exceptionMapper,
  })  : _welcomeService = WelcomeService(
          apiClient: apiClient,
          logger: logger,
          exceptionMapper: exceptionMapper,
        ),
        _logger = logger;

  @override
  Future<Result<CompanyAsset, WelcomeException>> getCompanyAsset() async {
    try {
      final companyAsset = await _welcomeService.getCompanyAsset();
      return Result.success(companyAsset);
    } catch (e) {
      return _handleWelcomeError(e, 'Company asset');
    }
  }

  @override
  Future<Result<StoreAsset, WelcomeException>> getStoreAsset() async {
    try {
      final storeAsset = await _welcomeService.getStoreAsset();
      return Result.success(storeAsset);
    } catch (e) {
      return _handleWelcomeError(e, 'Store asset');
    }
  }

  @override
  Future<Result<TaskAsset, WelcomeException>> getTaskAsset() async {
    try {
      final taskAsset = await _welcomeService.getTaskAsset();
      return Result.success(taskAsset);
    } catch (e) {
      return _handleWelcomeError(e, 'Task asset');
    }
  }

  /// Handles errors from welcome assets operations and returns appropriate Result objects
  /// @param e The exception that was thrown
  /// @param assetType The type of asset being fetched (Company, Store, Task)
  /// @returns A Result.failure with the appropriate exception
  Result<T, WelcomeException> _handleWelcomeError<T>(
      dynamic e, String assetType) {
    _logger.error('Error fetching $assetType: $e');

    // Handle domain-specific exceptions
    if (e is WelcomeException) {
      // Welcome exceptions can be directly returned
      return Result.failure(e);
    }

    // For all other exceptions, create a generic welcome exception
    return Result.failure(
      WelcomeAssetsFetchException('Failed to fetch $assetType: $e'),
    );
  }
}
