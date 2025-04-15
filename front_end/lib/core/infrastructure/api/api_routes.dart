/// API route constants for the application
/// Organized by feature for better maintainability and discoverability
class ApiRoutes {
  static const String base = '/api'; // Base API path
  static const String baseMedia = '/media'; // Base media path
}

/// Authentication related routes
class AuthApiRoutes {
  static const String base = '${ApiRoutes.base}/auth';
  static const String login = '$base/login/';
  static const String logout = '$base/logout/';
  static const String register = '$base/register/';
  static const String changePassword = '$base/change-password/';
}

/// Token related routes
class TokenApiRoutes {
  static const String base = '${ApiRoutes.base}/token';
  static const String refresh = '$base/refresh/';
  static const String verify = '$base/verify/';
}

/// User profile related routes
class ProfileApiRoutes {
  static const String base = '${ApiRoutes.base}/profiles';
  static const String update = '/update-profile/';
  static const String delete = '/delete-account/';
}

/// Address related routes
class AddressApiRoutes {
  static const String base = '${ApiRoutes.base}/addresses/';
  static const String update = '/update-address/';
  static const String delete = '/delete-address/';
}

/// Store related routes
class StoreApiRoutes {
  static const String base = '${ApiRoutes.base}/stores';
  static const String storeBrands = '$base/store-brands/';
  static const String nearbyStores = '$storeBrands/nearby-stores/';
  static const String storeProducts = '$base/store-products/';
  static const String allProducts = '$storeProducts/all-products/';
  static const String productsByCategory = '$storeProducts/by-category/';
}

/// Search related routes within store
class StoreSearchApiRoutes {
  static const String base = '${StoreApiRoutes.base}/search';
  static const String autocomplete = '$base/autocomplete/';
  static const String products = '$base/products/';
}
