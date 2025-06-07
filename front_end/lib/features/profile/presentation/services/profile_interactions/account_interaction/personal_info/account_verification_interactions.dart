import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/profile/routes/constant/account_route_const.dart';

/// Service class that handles interactions with account verification screens
class AccountVerificationInteractionsService {
  final AppLogger _logger = AppLogger();

  /// Navigate to account verification screen
  void handleAccountVerificationTap(BuildContext context) {
    _logger.info('account verification tapped');
    context.pushNamed(AccountRouteNames.accountVerificationName);
  }

  // sub services
  /// Navigate to name verification screen
  Future<bool?> handleNameVerificationTap(BuildContext context) {
    _logger.info('Name verification tapped');
    return context.pushNamed(AccountRouteNames.nameVerificationName);
  }

  /// Navigate to email verification screen
  Future<bool?> handleEmailVerificationTap(BuildContext context) {
    _logger.info('Email verification tapped');
    return context.pushNamed<bool>(AccountRouteNames.emailVerificationName);
  }

  /// Navigate to phone verification screen
  Future<bool?> handlePhoneVerificationTap(BuildContext context) {
    _logger.info('Phone verification tapped');
    return context.pushNamed<bool>(AccountRouteNames.phoneVerificationName);
  }

  /// Navigate to ID card verification screen
  Future<bool?> handleIdCardVerificationTap(BuildContext context) {
    _logger.info('ID card verification tapped');
    return context.pushNamed<bool>(AccountRouteNames.idCardVerificationName);
  }
}
