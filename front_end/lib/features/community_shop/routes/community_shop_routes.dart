// In features/order/routes/order_routes.dart

import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/config/routing_transitions.dart';
import 'package:semo/core/presentation/navigation/main_app_nav/app_routes/app_router.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/deliveries/order_information.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/item/item_confirm.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/item/order_item_detail.dart';
import 'package:semo/core/presentation/screens/image_viewer_screen.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/payment/checkout.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/payment/first_shopper_message.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/utils/models.dart';
import 'package:semo/features/community_shop/routes/transitions.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/order_started_screen.dart';
import 'package:semo/features/community_shop/presentation/screens/selected_order/community_order_details_screen.dart';
import 'package:semo/features/community_shop/presentation/screens/main_screen/community_shop_screen.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/features/community_shop/routes/const.dart';

class CommunityShopRouter {
  // Get all routes for the Order feature
  static List<RouteBase> getCommunityShopRoutes() {
    return [
      // Define the base route that matches the tab
      //
      //
      //
      GoRoute(
        path: CommunityShopRoutesConstants.communityShop,
        name: CommunityShopRoutesConstants.communityShopName,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const CommunityShopScreen(),
          name: 'CommunityShopScreen',
        ),
        routes: [
          // Order details route
          //
          //
          GoRoute(
            path: CommunityShopRoutesConstants.orderDetails,
            name: CommunityShopRoutesConstants.orderDetailsName,
            parentNavigatorKey: AppRouter.rootNavigatorKey,
            pageBuilder: (context, state) => buildPageWithTransition(
              context: context,
              state: state,
              child: CommunityOrderDetailsScreen(
                order: state.extra as CommunityOrder,
              ),
              name: 'CommunityOrderDetailsScreen',
            ),
          ),
          // Order started route
          //
          //
          GoRoute(
            path: CommunityShopRoutesConstants.orderStart,
            name: CommunityShopRoutesConstants.orderStartName,
            parentNavigatorKey: AppRouter.rootNavigatorKey,
            pageBuilder: (context, state) => buildBottomToTopTransition(
              context: context,
              state: state,
              child: CommunityOrderStartedScreen(
                order: state.extra as CommunityOrder,
              ),
              name: 'CommunityOrderStartedScreen',
            ),
            routes: [
              // Order item details route
              //
              GoRoute(
                path: CommunityShopRoutesConstants.orderItemDetails,
                name: CommunityShopRoutesConstants.orderItemDetailsName,
                parentNavigatorKey: AppRouter.rootNavigatorKey,
                pageBuilder: (context, state) {
                  final Map<String, dynamic> extras =
                      state.extra as Map<String, dynamic>;

                  return buildPageWithTransition(
                    context: context,
                    state: state,
                    child: CommunityOrderItemDetailsScreen(
                      orderItem: extras['orderItem'] as OrderItem,
                      order: extras['order'] as CommunityOrder,
                    ),
                    name: 'CommunityOrderItemDetailsScreen',
                  );
                },
                routes: [
                  // Image viewer route
                  GoRoute(
                    path: CommunityShopRoutesConstants.imageViewer,
                    name: CommunityShopRoutesConstants.imageViewerName,
                    parentNavigatorKey: AppRouter.rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final Map<String, dynamic> extras =
                          state.extra as Map<String, dynamic>;

                      return buildPageWithTransition(
                        context: context,
                        state: state,
                        child: ImageViewerScreen(
                          imageUrl: extras['imageUrl'] as String,
                          heroTag: extras['heroTag'] as String,
                        ),
                        name: 'ImageViewerScreen',
                      );
                    },
                  ),
                  // Order item details confirmation route
                  GoRoute(
                    path: CommunityShopRoutesConstants
                        .orderItemDetailsConfirmation,
                    name: CommunityShopRoutesConstants
                        .orderItemDetailsConfirmationName,
                    parentNavigatorKey: AppRouter.rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final Map<String, dynamic> extras =
                          state.extra as Map<String, dynamic>;

                      return buildPageWithTransition(
                        context: context,
                        state: state,
                        child: CommunityOrderItemDetailsConfirmationScreen(
                          orderItem: extras['orderItem'] as OrderItem,
                          order: extras['order'] as CommunityOrder,
                        ),
                        name: 'CommunityOrderItemDetailsConfirmationScreen',
                      );
                    },
                  ),
                ],
              ),
              // order finished, start start checkout route
              //
              GoRoute(
                path: CommunityShopRoutesConstants.orderCheckout,
                name: CommunityShopRoutesConstants.orderCheckoutName,
                parentNavigatorKey: AppRouter.rootNavigatorKey,
                pageBuilder: (context, state) {
                  final Map<String, dynamic> extras =
                      state.extra as Map<String, dynamic>;

                  return buildPageWithTransition(
                    context: context,
                    state: state,
                    child: CommunityOrderCheckoutScreen(
                      orders: extras['orders'] as List<CommunityOrder>,
                    ),
                    name: 'CommunityOrderCheckoutScreen',
                  );
                },
              ),
              // first order shopper message route
              //
              GoRoute(
                path: CommunityShopRoutesConstants.firstOrderShopperMessage,
                name: CommunityShopRoutesConstants.firstOrderShopperMessageName,
                parentNavigatorKey: AppRouter.rootNavigatorKey,
                pageBuilder: (context, state) {
                  final Map<String, dynamic> extras =
                      state.extra as Map<String, dynamic>;

                  return buildPageWithTransition(
                    context: context,
                    state: state,
                    child: FirstOrderShopperMessageScreen(
                      orders: extras['orders'] as List<CommunityOrder>,
                    ),
                    name: 'FirstOrderShopperMessageScreen',
                  );
                },
              ),
              //  delivery order information route
              //
              GoRoute(
                path: CommunityShopRoutesConstants.deliveryOrderInformation,
                name: CommunityShopRoutesConstants.deliveryOrderInformationName,
                parentNavigatorKey: AppRouter.rootNavigatorKey,
                pageBuilder: (context, state) {
                  final Map<String, dynamic> extras =
                      state.extra as Map<String, dynamic>;

                  return buildPageWithTransition(
                    context: context,
                    state: state,
                    child: DeliveryOrderInformationScreen(
                      orders: extras['orders'] as List<CommunityOrder>,
                    ),
                    name: 'DeliveryOrderInformationScreen',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ];
  }
}
