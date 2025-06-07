import 'package:go_router/go_router.dart';
import 'package:semo/features/profile/routes/flows/account/account_routes/personal_info/account_verif_route.dart';
import 'package:semo/features/profile/routes/flows/account/account_routes/personal_info/addresses_route.dart';
import 'package:semo/features/profile/routes/flows/account/account_routes/personal_info/password.dart';
import 'package:semo/features/profile/routes/flows/account/account_routes/personal_info/payment_methods_route.dart';
import 'package:semo/features/profile/routes/flows/account/account_routes/to_shop_more/delivery_preferences_route.dart';

/// Class that consolidates all account-related routes
class AccountRoutes {
  /// Returns all account-related routes
  static List<RouteBase> getRoutes() {
    return [
      ...AccountVerifRoutes.getRoutes(),
      ...AddressesRoutes.getRoutes(),
      ...PasswordRoutes.getRoutes(),
      ...PaymentMethodsRoutes.getRoutes(),
      ...DeliveryPreferencesRoutes.getRoutes(),
    ];
  }
}
