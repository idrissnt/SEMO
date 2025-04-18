import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_constants.dart';
import 'route_params.dart';

/// Extension methods to simplify navigation with type safety
extension GoRouterExtension on BuildContext {
  // Basic navigation methods
  void pushRoute(String location) => go(location);
  void replaceRoute(String location) => replace(location);
  
  // Typed navigation methods for product details
  void goToProductDetail(ProductDetailParams params) {
    final productId = params.productId;
    final queryParams = params.toQueryParams();
    
    // Remove productId from query params as it's in the path
    queryParams.remove('productId');
    
    // Create URI with path and query parameters
    final uri = Uri(path: '/product/$productId', queryParameters: queryParams.isEmpty ? null : queryParams);
    go(uri.toString());
  }
  
  // Typed navigation methods for user profile
  void goToUserProfile(ProfileParams params) {
    final userId = params.userId;
    final queryParams = params.toQueryParams();
    
    // Remove userId from query params as it's in the path
    queryParams.remove('userId');
    
    // Create URI with path and query parameters
    final uri = Uri(path: '/profile/$userId', queryParameters: queryParams.isEmpty ? null : queryParams);
    go(uri.toString());
  }
  
  // Auth navigation shortcuts
  void goToLogin() => go(AppRoutes.login);
  void goToRegister() => go(AppRoutes.register);
  void goToHome() => go(AppRoutes.home);
}
