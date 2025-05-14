/// Constants for store-related routes
class StoreRoutesConst {
  /// Base route for store
  static const String storeBase = '/store';

  /// Route for store detail with parameter
  static const String storeDetail = '/store/:storeId';

  /// Tab routes
  static const String storeShop = 'shop';
  static const String storeAisles = 'aisles';
  static const String storeBuyAgain = 'buyagain';
  
  /// Category and subcategory routes
  static const String storeCategory = 'category/:categoryId';
  static const String storeSubcategory = 'subcategory/:subcategoryId';

  /// Helper method to generate store detail route
  static String getStoreDetailRoute(String storeId) => '/store/$storeId';

  /// Helper methods for tab routes
  static String getStoreShopRoute(String storeId) =>
      '/store/$storeId/$storeShop';
  static String getStoreAislesRoute(String storeId) =>
      '/store/$storeId/$storeAisles';
  static String getStoreBuyAgainRoute(String storeId) =>
      '/store/$storeId/$storeBuyAgain';
      
  /// Helper methods for category routes
  static String getStoreCategoryRoute(String storeId, String categoryId) =>
      '/store/$storeId/category/$categoryId';
      
  /// Helper methods for subcategory routes
  static String getStoreSubcategoryRoute(String storeId, String categoryId, String subcategoryId) =>
      '/store/$storeId/category/$categoryId/subcategory/$subcategoryId';
}
