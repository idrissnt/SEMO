import 'package:go_router/go_router.dart';

/// Models for typed route parameters
/// 
/// These classes provide type safety for route parameters, making it easier
/// to pass data between screens and ensuring that required parameters are provided.

/// Parameters for product detail routes
class ProductDetailParams {
  final String productId;
  final String? initialTab;
  
  const ProductDetailParams({
    required this.productId,
    this.initialTab,
  });
  
  /// Convert to query parameters for GoRouter
  Map<String, String> toQueryParams() {
    final params = <String, String>{
      'productId': productId,
    };
    
    if (initialTab != null) {
      params['tab'] = initialTab!;
    }
    
    return params;
  }
  
  /// Create from GoRouterState
  factory ProductDetailParams.fromState(GoRouterState state) {
    return ProductDetailParams(
      productId: state.pathParameters['productId'] ?? '',
      initialTab: state.uri.queryParameters['tab'],
    );
  }
}

/// Parameters for user profile routes
class ProfileParams {
  final String userId;
  final bool isEditable;
  
  const ProfileParams({
    required this.userId,
    this.isEditable = false,
  });
  
  /// Convert to query parameters for GoRouter
  Map<String, String> toQueryParams() {
    return {
      'userId': userId,
      'editable': isEditable.toString(),
    };
  }
  
  /// Create from GoRouterState
  factory ProfileParams.fromState(GoRouterState state) {
    return ProfileParams(
      userId: state.pathParameters['userId'] ?? '',
      isEditable: state.uri.queryParameters['editable'] == 'true',
    );
  }
}
