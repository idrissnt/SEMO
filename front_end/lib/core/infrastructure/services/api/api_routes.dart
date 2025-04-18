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

/// Authentication related routes
class AuthApiRoutes {
  static const String path = '/users/auth';
  static String get base => '${ApiRoutes.base}$path';
  static String get login => '$base/login/';
  static String get logout => '$base/logout/';
  static String get register => '$base/register/';
  static String get changePassword => '$base/change-password/';
}

/// Token related routes
class TokenApiRoutes {
  static const String path = '/users/token';
  static String get base => '${ApiRoutes.base}$path';
  static String get refresh => '$base/refresh/';
  static String get verify => '$base/verify/';
}

/// User profile related routes
class ProfileApiRoutes {
  static const String path = '/users/profiles';
  static String get base => '${ApiRoutes.base}$path';
  static String get me => '$base/me/';
  static String get updateProfile => '$base/update-profile/';
  static String get deleteAccount => '$base/delete-account/';
}

/// User address related routes
class UserAddressApiRoutes {
  static const String path = '/users/addresses';
  static String get base => '${ApiRoutes.base}$path';
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
  static const String path = '/stores';
  static String get base => '${ApiRoutes.base}$path';
  static String get storeBrands => '$base/store-brands/';
  static String get nearbyStores => '$storeBrands/nearby-stores/';

  static String getProductsByStore(String storeSlug) =>
      '$base/$storeSlug/products/';
  static String getStoreProductsForCategory(String storeSlug) =>
      '$base/$storeSlug/category/products/';
}

/// Search related routes within store
class StoreSearchApiRoutes {
  static const String path = '/search';
  static String get base => '${StoreApiRoutes.base}$path';
  static String get searchProducts => '$base/products/';
  static String get autocomplete => '$base/autocomplete/';
}
