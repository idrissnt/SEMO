// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:semo/core/utils/logger.dart';
// import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
// import 'package:semo/features/store/presentation/widgets/product_details/product_detail.dart';

// /// Class that provides deep linking routes for product details
// class ProductDetailDeepLinkRouter {
//   /// Get the route for deep linking to product details
//   static RouteBase getProductDetailDeepLinkRoute() {
//     final logger = AppLogger();
    
//     return GoRoute(
//       path: '/store/:storeId/product/:productId',
//       builder: (context, state) {
//         final storeId = state.pathParameters['storeId']!;
//         final productId = state.pathParameters['productId']!;
        
//         logger.debug('Deep linking to product: $productId in store: $storeId');
        
//         // Fetch the product and related products data
//         return FutureBuilder<Map<String, dynamic>>(
//           future: _fetchProductData(storeId, productId),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Scaffold(
//                 body: Center(child: CircularProgressIndicator()),
//               );
//             }
            
//             if (snapshot.hasError || !snapshot.hasData) {
//               return Scaffold(
//                 body: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(Icons.error_outline, size: 48),
//                       const SizedBox(height: 16),
//                       Text('Product not found: ${snapshot.error}'),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: () => context.go('/'),
//                         child: const Text('Return to Home'),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }
            
//             final data = snapshot.data!;
//             final product = data['product'] as CategoryProduct;
//             final relatedProducts = data['relatedProducts'] as List<CategoryProduct>;
            
//             // Show the product detail bottom sheet
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               showProductDetailBottomSheet(
//                 context: context,
//                 product: product,
//                 storeId: storeId,
//                 relatedProducts: relatedProducts,
//               );
//             });
            
//             // Return a placeholder widget while the bottom sheet is loading
//             return const Scaffold(body: Center(child: CircularProgressIndicator()));
//           },
//         );
//       },
//     );
//   }
  
//   /// Fetch product data from the API
//   /// 
//   /// This is a placeholder implementation. In a real app, this would make an API call.
//   static Future<Map<String, dynamic>> _fetchProductData(String storeId, String productId) async {
//     // Simulate network delay
//     await Future.delayed(const Duration(milliseconds: 500));
    
//     // Create a mock product
//     final product = CategoryProduct(
//       id: productId,
//       name: 'Product $productId',
//       imageUrl: 'https://via.placeholder.com/150',
//       price: 9.99,
//       productUnit: '1 kg',
//       pricePerUnit: 9.99,
//       unit: 'kg',
//     );
    
//     // Create mock related products
//     final relatedProducts = List.generate(
//       5,
//       (index) => CategoryProduct(
//         id: 'related-$index',
//         name: 'Related Product $index',
//         imageUrl: 'https://via.placeholder.com/150',
//         price: 4.99 + index,
//         productUnit: '1 kg',
//         pricePerUnit: 4.99 + index,
//         unit: 'kg',
//       ),
//     );
    
//     return {
//       'product': product,
//       'relatedProducts': relatedProducts,
//     };
//   }
// }
