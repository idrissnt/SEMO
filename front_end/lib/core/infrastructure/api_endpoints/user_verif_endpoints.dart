import 'package:semo/core/infrastructure/api_endpoints/api_enpoints.dart';

/// User verification endpoints
class UserVerifApiRoutes {
  static String base = '${ApiRoutes.base}/users/verifications';
  static String requestEmailVerification = '$base/request-email-verification/';
  static String requestPhoneVerification = '$base/request-phone-verification/';
  static String verifyCode = '$base/verify-code/';
  static String requestPasswordReset = '$base/request-password-reset/';
  static String resetPassword = '$base/reset-password/';
}
