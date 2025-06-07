import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/profile/routes/constant/account_route_const.dart';

class DeliveryPreferencesInteractionsService {
  final AppLogger _logger = AppLogger();

  /// Navigate to delivery preferences screen
  void handleDeliveryPreferencesTap(BuildContext context) {
    _logger.info('delivery preferences tapped');
    context.pushNamed(AccountRouteNames.deliveryPreferencesName);
  }

  /// Handles navigation to the vehicle selection screen
  Future<bool> handleVehicleSelectionTap(BuildContext context) async {
    _logger.info('Navigating to vehicle selection screen');
    final result = await context.pushNamed<bool>(
      AccountRouteNames.vehicleSelectionName,
    );
    return result ?? false;
  }

  /// Handles navigation to the zone selection screen
  Future<bool> handleZoneSelectionTap(BuildContext context) async {
    _logger.info('Navigating to zone selection screen');
    final result = await context.pushNamed<bool>(
      AccountRouteNames.zoneSelectionName,
    );
    return result ?? false;
  }

  /// Handles navigation to the store selection screen
  Future<bool> handleStoreSelectionTap(BuildContext context) async {
    _logger.info('Navigating to store selection screen');
    final result = await context.pushNamed<bool>(
      AccountRouteNames.storeSelectionName,
    );
    return result ?? false;
  }
}
