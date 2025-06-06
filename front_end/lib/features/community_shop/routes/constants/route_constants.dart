/// Constants for all community shop routes
class RouteConstants {
  // Main routes
  static const String communityShop = '/community-shop';
  static const String communityShopName = 'community-shop-name';

  // 1 - Order details flow
  static const String orderDetails = 'order-details/:orderId';
  static const String orderDetailsName = 'order-details-name';

  // 2 - Group orders
  static const String shopperDelivery = 'shopper-delivery';
  static const String shopperDeliveryName = 'shopper-delivery-name';

  // 3 - Order started flow
  //
  static const String orderStart = 'order-start/:orderId';
  static const String orderStartName = 'order-start-name';

  // 3-1 Item details flow
  static const String orderItemDetails = 'item/:itemId';
  static const String orderItemDetailsName = 'order-item-details';

  // 3-1-1 Image viewer
  static const String imageViewer = 'image-viewer';
  static const String imageViewerName = 'image-viewer';

  // 3-1-2 Item found
  static const String orderItemDetailsFound = 'found';
  static const String orderItemDetailsFoundName =
      'order-item-details-found-name';

  // 3-1-3 Item not found
  static const String orderItemDetailsNotFound = 'not-found';
  static const String orderItemDetailsNotFoundName =
      'order-item-details-not-found-name';

  // 3-1-4 Add new item
  static const String orderAddItem = 'add-item';
  static const String orderAddItemName = 'order-add-item-name';

  // 4 - Checkout flow
  static const String orderCheckout = 'checkout';
  static const String orderCheckoutName = 'orderCheckoutName';

  // 5 - Delivery information
  static const String deliveryOrderInformation = 'delivery-order-information';
  static const String deliveryOrderInformationName =
      'delivery-order-information-name';

  // Helper methods for path parameters
  static String getOrderDetailsPath(String orderId) => 'order-details/$orderId';
  static String getOrderStartPath(String orderId) => 'order-start/$orderId';
  static String getOrderItemDetailsPath(String itemId) => 'item/$itemId';

  // Helper method for constructing the full item details path with both parameters
  static String getFullOrderItemDetailsPath(String orderId, String itemId) =>
      '${getOrderStartPath(orderId)}/${getOrderItemDetailsPath(itemId)}';

  // Helper method for constructing the add item path
  static String getOrderAddItemPath(String orderId) =>
      '${getOrderStartPath(orderId)}/$orderAddItem';
}
