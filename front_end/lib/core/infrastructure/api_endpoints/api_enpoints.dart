import 'package:semo/core/app/app_config.dart';

/// API route constants for the application
/// Organized by feature for better maintainability and discoverability
class ApiRoutes {
  // API paths (not full URLs)
  static const String apiPath = '/api';
  static const String apiVersion = '/v1';

  // Full API base URL with environment awareness
  static String get base => '${AppConfig.baseUrl}$apiPath$apiVersion';

  // Media URL
  static String get mediaBase => AppConfig.mediaBaseUrl;
}

/// Welcome assets endpoints
class WelcomeApiRoutes {
  static String base = '${ApiRoutes.base}/core/welcome-assets';
  static String companyAsset = '$base/company-asset/';
  static String storeAssets = '$base/store-assets/';
  static String taskAssets = '$base/all-task-assets/';
}

/// Authentication related routes
class AuthApiRoutes {
  static String base = '${ApiRoutes.base}/users/auth';
  static String get login => '$base/login/';
  static String get logout => '$base/logout/';
  static String get register => '$base/register/';
  static String get changePassword => '$base/change-password/';
}

/// Token related routes
class TokenApiRoutes {
  static String get base => '${ApiRoutes.base}/users/token';
  static String get refresh => '$base/refresh/';
  static String get verify => '$base/verify/';
}

/// User profile related routes
class ProfileApiRoutes {
  static String get base => '${ApiRoutes.base}/users/profiles';
  static String get me => '$base/me/';
  static String get updateProfile => '$base/update-profile/';
  static String get deleteAccount => '$base/delete-account/';
}

/// User address related routes
class UserAddressApiRoutes {
  static String get base => '${ApiRoutes.base}/users/addresses';
  static String get getUserAddresses => '$base/';
  static String get createAddress => '$base/';

  static String getAddressById(String addressId) => '$base/$addressId/';
  static String deleteAddressById(String addressId) =>
      '$base/$addressId/delete-address/';
  static String updateAddressById(String addressId) =>
      '$base/$addressId/update-address/';
}

/// Store related routes
class StoreApiRoutes {
  static String get base => '${ApiRoutes.base}/stores';
  static String get storeBrands => '$base/store-brands/';

  static String getStoreBrandsNearby(String address) =>
      '$storeBrands/nearby-stores/$address/';

  static String getProductsByStore(String storeSlug) =>
      '$base/$storeSlug/products/';

  static String getStoreProductsForCategory(String storeSlug) =>
      '$base/$storeSlug/category/products/';
}

/// Search related routes within store
class StoreSearchApiRoutes {
  static String get base => '${StoreApiRoutes.base}/search';
  static String get searchProducts => '$base/products/';
  static String get autocomplete => '$base/autocomplete/';
}
