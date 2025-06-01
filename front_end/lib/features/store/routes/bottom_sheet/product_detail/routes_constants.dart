/// Constants for product detail routes in the bottom sheet
class BottomSheetProductDetailRoutesConstants {
  /// Root route for the initial product
  static const String root = '/';

  /// Route for related products with product ID parameter
  static const String relatedProduct = '/product/:productId';

  /// Route for image viewer with image URL and hero tag parameters
  static const String imageViewer = '/image-viewer';
  static const String heroTag = 'BottomSheetProductImage';
  static const String name = 'ImageViewer';

  // Private constructor to prevent instantiation
  BottomSheetProductDetailRoutesConstants._();
}
