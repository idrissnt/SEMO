/// Constants for home feature routes
class HomeRoutesConstants {
  /// Path for category details screen (relative to home route)
  /// Usage: /home/category/:categoryId
  static const String categoryDetailsPath = 'category/:categoryId';
  
  /// Full path for category details
  static const String categoryDetails = '/home/category/:categoryId';
  
  /// Path for product details screen (relative to home route)
  /// Usage: /home/product/:productId
  static const String productDetailsPath = 'product/:productId';
  
  /// Full path for product details
  static const String productDetails = '/home/product/:productId';
  
  /// Helper method to get category details route with a specific ID
  static String getCategoryDetailsRoute(String categoryId) {
    return '/home/category/$categoryId';
  }
  
  /// Helper method to get product details route with a specific ID
  static String getProductDetailsRoute(String productId) {
    return '/home/product/$productId';
  }
}
