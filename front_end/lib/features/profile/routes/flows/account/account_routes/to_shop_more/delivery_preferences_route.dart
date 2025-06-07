import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/main_app_nav/app_routes/app_router.dart';
import 'package:semo/core/presentation/navigation/config/route_builder.dart'
    as app_routes;
import 'package:semo/features/profile/presentation/screens/account_screens/to_shop_more/delivery_preferences_screen.dart';
import 'package:semo/features/profile/presentation/screens/account_screens/to_shop_more/selection_delivery_pref_screens/vehicle_selection_screen.dart';
import 'package:semo/features/profile/presentation/screens/account_screens/to_shop_more/selection_delivery_pref_screens/zone_selection_screen.dart';
import 'package:semo/features/profile/presentation/screens/account_screens/to_shop_more/selection_delivery_pref_screens/store_selection_screen.dart';
import 'package:semo/features/profile/routes/constant/account_route_const.dart';

class DeliveryPreferencesRoutes {
  static List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: AccountRoutesConstants.deliveryPreferences,
        name: AccountRouteNames.deliveryPreferencesName,
        parentNavigatorKey: AppRouter.rootNavigatorKey,
        pageBuilder: _buildDeliveryPreferencesScreen,
        routes: [
          GoRoute(
            path: AccountRoutesConstants.vehicleSelection,
            name: AccountRouteNames.vehicleSelectionName,
            parentNavigatorKey: AppRouter.rootNavigatorKey,
            pageBuilder: _buildVehicleSelectionScreen,
          ),
          GoRoute(
            path: AccountRoutesConstants.zoneSelection,
            name: AccountRouteNames.zoneSelectionName,
            parentNavigatorKey: AppRouter.rootNavigatorKey,
            pageBuilder: _buildZoneSelectionScreen,
          ),
          GoRoute(
            path: AccountRoutesConstants.storeSelection,
            name: AccountRouteNames.storeSelectionName,
            parentNavigatorKey: AppRouter.rootNavigatorKey,
            pageBuilder: _buildStoreSelectionScreen,
          ),
        ],
      ),
    ];
  }

  static Page<dynamic> _buildDeliveryPreferencesScreen(
    BuildContext context,
    GoRouterState state,
  ) {
    return app_routes.RouteBuilder.buildPage(
      context: context,
      state: state,
      child: const DeliveryPreferencesScreen(),
      name: AccountRouteNames.deliveryPreferencesName,
    );
  }

  static Page<dynamic> _buildVehicleSelectionScreen(
    BuildContext context,
    GoRouterState state,
  ) {
    return app_routes.RouteBuilder.buildPage(
      context: context,
      state: state,
      child: const VehicleSelectionScreen(),
      name: AccountRouteNames.vehicleSelectionName,
    );
  }

  static Page<dynamic> _buildZoneSelectionScreen(
    BuildContext context,
    GoRouterState state,
  ) {
    return app_routes.RouteBuilder.buildPage(
      context: context,
      state: state,
      child: const ZoneSelectionScreen(),
      name: AccountRouteNames.zoneSelectionName,
    );
  }

  static Page<dynamic> _buildStoreSelectionScreen(
    BuildContext context,
    GoRouterState state,
  ) {
    return app_routes.RouteBuilder.buildPage(
      context: context,
      state: state,
      child: const StoreSelectionScreen(),
      name: AccountRouteNames.storeSelectionName,
    );
  }
}
