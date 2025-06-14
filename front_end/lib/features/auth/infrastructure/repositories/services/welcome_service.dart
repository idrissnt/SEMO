import 'package:semo/core/domain/services/api_client.dart';
import 'package:semo/core/infrastructure/api_endpoints/api_enpoints.dart';
import 'package:semo/core/utils/logger.dart';

import 'package:semo/features/auth/domain/entities/welcom_entity.dart';
import 'package:semo/features/auth/domain/exceptions/welcom/exception_mapper_welcom.dart';
import 'package:semo/features/auth/infrastructure/models/welcome_models.dart';

/// Service for handling welcome assets operations
class WelcomeService {
  final ApiClient _apiClient;
  final AppLogger _logger;
  final WelcomeExceptionMapper _exceptionMapper;

  WelcomeService({
    required ApiClient apiClient,
    required AppLogger logger,
    required WelcomeExceptionMapper exceptionMapper,
  })  : _apiClient = apiClient,
        _logger = logger,
        _exceptionMapper = exceptionMapper;

  Future<CompanyAsset> getCompanyAsset() async {
    try {
      _logger.debug('Fetching company asset');

      final response = await _apiClient.get<Map<String, dynamic>>(
        WelcomeApiRoutes.companyAsset,
        options: null, // No special options needed
      );

      final companyAssetModel = CompanyAssetModel.fromJson(response);
      return companyAssetModel.toDomain();
    } catch (e) {
      _logger.error('Failed to fetch company asset: $e');
      _exceptionMapper.mapApiExceptionToDomainException(e);
    }
  }

  Future<StoreAsset> getStoreAsset() async {
    try {
      _logger.debug('Fetching store asset');

      final response = await _apiClient.get<Map<String, dynamic>>(
        WelcomeApiRoutes.storeAssets,
        options: null, // No special options needed
      );

      final storeAssetModel = StoreAssetModel.fromJson(response);
      return storeAssetModel.toDomain();
    } catch (e) {
      _logger.error('Failed to fetch store asset: $e');
      _exceptionMapper.mapApiExceptionToDomainException(e);
    }
  }

  Future<List<TaskAsset>> getAllTaskAsset() async {
    try {
      _logger.debug('Fetching all task assets');

      final response = await _apiClient.get<List<dynamic>>(
        WelcomeApiRoutes.taskAssets,
        options: null, // No special options needed
      );

      final taskAssetModels =
          response.map((item) => TaskAssetModel.fromJson(item)).toList();
      return taskAssetModels.map((model) => model.toDomain()).toList();
    } catch (e) {
      _logger.error('Failed to fetch task assets: $e');
      _exceptionMapper.mapApiExceptionToDomainException(e);
    }
  }
}
