import 'package:semo/core/utils/result.dart';
import 'package:semo/features/auth/domain/entities/welcom_entity.dart';
import 'package:semo/features/auth/domain/exceptions/welcom/welcome_exceptions.dart';

/// WelcomeRepository defines the contract for welcome assets operations
abstract class WelcomeRepository {
  /// Fetches company asset information
  /// Returns a Result containing either a CompanyAsset object on success or a WelcomeException on failure
  Future<Result<CompanyAsset, WelcomeException>> getCompanyAsset();

  /// Fetches store asset information
  /// Returns a Result containing either a StoreAsset object on success or a WelcomeException on failure
  Future<Result<StoreAsset, WelcomeException>> getStoreAsset();

  /// Fetches task asset information
  /// Returns a Result containing either a List of TaskAsset objects on success or a WelcomeException on failure
  Future<Result<List<TaskAsset>, WelcomeException>> getAllTaskAsset();
}
