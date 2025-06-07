import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/profile/routes/constant/account_route_const.dart';

/// Service class that handles interactions with community orders
class PersonalInfoInteractionsService {
  final AppLogger _logger = AppLogger();

  void handlePaymentMethodsTap(BuildContext context) {
    _logger.info('Payment methods tapped');
    context.goNamed(AccountRouteNames.paymentMethodsName);
  }

  void handleAddressTap(BuildContext context) {
    _logger.info('Address tapped');
    context.goNamed(AccountRouteNames.addressesName);
  }

  void handlePasswordTap(BuildContext context) {
    _logger.info('Password tapped');
    context.goNamed(AccountRouteNames.passwordName);
  }
}
