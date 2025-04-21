/// Store-specific error code constants
/// These codes are specific to the store feature and should not be in the core module
class StoreErrorCodes {
  // Store error codes
  static const String invalidUuid = 'invalid_uuid';
  static const String storeIdRequired = 'store_id_required';
  static const String addressRequired = 'address_required';
  static const String querySearchRequired = 'query_search_required';

  // Generic error code
  static const String genericError = 'generic_store_error';

  // Private constructor to prevent instantiation
  StoreErrorCodes._();
}
