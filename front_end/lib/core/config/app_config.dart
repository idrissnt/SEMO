// This file contains configuration settings for the app api.

class AppConfig {
  static const String apiBaseUrl =
      // 'http://172.20.10.5:8000/api/v1'; // idriss NN For every device
      'http://192.168.187.184:8000/api/v1'; // coco NN For every device

  // Base URL for media files (images)
  // static const String mediaBaseUrl = 'http://172.20.10.5:8000';
  static const String mediaBaseUrl = 'http://192.168.187.184:8000';

  // Authentication Endpoints
  static const String loginEndpoint = '/auth/login/';
  static const String logoutEndpoint = '/auth/logout/';
  static const String registerEndpoint = '/auth/register/';
  static const String changePasswordEndpoint = '/auth/change-password/';

  // Token Endpoints
  static const String refreshTokenEndpoint = '/token/refresh/';
  static const String tokenVerifyEndpoint = '/token/verify/';

  // User Endpoints
  static const String profileEndpoint = '/profiles/';
  static const String updateProfileEndpoint = '/profiles/update-profile/';
  static const String deleteAccountEndpoint = '/profiles/delete-account/';

  // Address Endpoints
  static const String listUserAddressesEndpoint = '/addresses/';
  static const String createUserAddressEndpoint = '/addresses/';
  static const String retrieveAddressEndpoint = '/addresses/';
  static const String updateUserAddressEndpoint = '/update-address/';
  static const String deleteUserAddressEndpoint = '/delete-address/';

  // Store endpoints
  static const String allStores = '/stores/';
  static const String storesFullDetails = '/stores/full_details/';
}
