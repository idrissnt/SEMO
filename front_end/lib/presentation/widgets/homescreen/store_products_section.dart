// // ignore_for_file: avoid_print

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../../domain/entities/product.dart';
// import '../../../domain/entities/store.dart';
// import '../../blocs/store/store_bloc.dart';
// import '../../blocs/store/store_event.dart';
// import '../../blocs/store/store_state.dart';

// class StoreProductsSection extends StatelessWidget {
//   final String storeName;

//   const StoreProductsSection({
//     Key? key,
//     required this.storeName,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<StoreBloc, StoreState>(
//       buildWhen: (previous, current) =>
//           current is StoreProductsByNameLoaded ||
//           current is StoreLoading ||
//           current is StoreError,
//       builder: (context, state) {
//         if (state is StoreLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (state is StoreError) {
//           return Center(child: Text(state.message));
//         }

//         if (state is StoreProductsByNameLoaded) {
//           return _buildCategorizedProducts(state);
//         }

//         // Load store products when widget is first built
//         context.read<StoreBloc>().add(const LoadStoreProductsByNameEvent());
//         return const Center(child: CircularProgressIndicator());
//       },
//     );
//   }

//   Widget _buildCategorizedProducts(StoreProductsByNameLoaded state) {
//     // Log store name and category count
//     print('🏪 [store_products_section.dart] Store Name: ${state.store.name}');

//     // Group products by their main category and subcategories
//     final Map<String, List<Map<String, List<Product>>>> categorizedProducts =
//         {};

//     // First, organize products by their categories
//     if (state.store.categories != null) {
//       for (var cat in state.store.categories!) {
//         final mainCategoryName = cat['name'] as String;
//         final subcategories = cat['subcategories'] as List<dynamic>?;

//         print(
//             '🏪 [store_products_section.dart] Main Category: $mainCategoryName');

//         // Initialize main category entry
//         categorizedProducts[mainCategoryName] = [];

//         // If no subcategories, skip
//         if (subcategories == null || subcategories.isEmpty) continue;

//         // Process each subcategory
//         for (var sub in subcategories) {
//           final subcategoryName = sub['name'] as String;

//           print(
//               '🏪 [store_products_section.dart] Subcategory: $subcategoryName');

//           // Find products for this subcategory
//           final subcategoryProducts = state.productsByCategory.entries
//               .where((entry) => entry.key == subcategoryName)
//               .map((entry) => entry.value)
//               .expand((products) => products)
//               .toList();

//           print(
//               '🏪 [store_products_section.dart] Subcategory Products: ${subcategoryProducts.length}');

//           // If subcategory has products, add to the list
//           if (subcategoryProducts.isNotEmpty) {
//             categorizedProducts[mainCategoryName]!
//                 .add({subcategoryName: subcategoryProducts});
//           }
//         }
//       }
//     }

//     print(
//         '🏪 [store_products_section.dart] Total Categorized Products: ${categorizedProducts.length}');

//     if (categorizedProducts.isEmpty) {
//       return const Center(
//         child: Text('No products available'),
//       );
//     }

//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Store Header
//           _buildStoreHeader(state.store),

//           // Categories List
//           ...categorizedProducts.entries.map((mainCategoryEntry) {
//             final mainCategoryName = mainCategoryEntry.key;
//             final subcategories = mainCategoryEntry.value;

//             // Skip empty categories
//             if (subcategories.isEmpty) return const SizedBox.shrink();

//             // Format category name for display
//             final displayName = mainCategoryName
//                 .replaceAll('_', ' ')
//                 .split(' ')
//                 .map((word) =>
//                     word.substring(0, 1).toUpperCase() + word.substring(1))
//                 .join(' ');

//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Main Category Header
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
//                   child: Text(
//                     displayName,
//                     style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),

//                 // Subcategories Horizontal Scroll
//                 SizedBox(
//                   height: 280, // Fixed height for horizontal scroll
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     itemCount: subcategories.length,
//                     itemBuilder: (context, index) {
//                       final subcategoryMap = subcategories[index];
//                       final subcategoryName = subcategoryMap.keys.first;
//                       final products = subcategoryMap[subcategoryName];

//                       print(
//                           '🏪 [store_products_section.dart] Rendering Subcategory: $subcategoryName');

//                       // Format subcategory name
//                       final subDisplayName = subcategoryName
//                           .replaceAll('_', ' ')
//                           .split(' ')
//                           .map((word) =>
//                               word.substring(0, 1).toUpperCase() +
//                               word.substring(1))
//                           .join(' ');

//                       return Padding(
//                         padding: const EdgeInsets.only(right: 16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(bottom: 8),
//                               child: Text(
//                                 subDisplayName,
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               width: 250, // Fixed width for horizontal scroll
//                               height: 220,
//                               child: ListView.builder(
//                                 scrollDirection: Axis.horizontal,
//                                 itemCount: products?.length,
//                                 itemBuilder: (context, productIndex) {
//                                   return Padding(
//                                     padding: const EdgeInsets.only(right: 16),
//                                     child: _buildProductCard(
//                                         products![productIndex]),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 16), // Space between categories
//               ],
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildStoreHeader(Store store) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//       child: Row(
//         children: [
//           if (store.logoUrl != null && store.logoUrl!.isNotEmpty)
//             CircleAvatar(
//               radius: 30,
//               backgroundImage: NetworkImage(store.logoUrl!),
//               backgroundColor: Colors.transparent,
//               onBackgroundImageError: (exception, stackTrace) {
//                 print('Error loading store logo: $exception');
//               },
//             )
//           else
//             CircleAvatar(
//               radius: 30,
//               backgroundColor: Colors.grey[200],
//               child: Icon(
//                 Icons.store,
//                 size: 30,
//                 color: Colors.grey[600],
//               ),
//             ),
//           const SizedBox(width: 16),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 store.name,
//                 style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               Text(
//                 store.description ?? '',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProductCard(Product product) {
//     return Container(
//       width: 180, // Reduced width
//       margin: const EdgeInsets.only(right: 12),
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Product Image
//             ClipRRect(
//               borderRadius:
//                   const BorderRadius.vertical(top: Radius.circular(12)),
//               child: AspectRatio(
//                 aspectRatio: 1,
//                 child: Image.network(
//                   product.imageUrl,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       color: Colors.grey[200],
//                       child: const Center(
//                         child: Icon(
//                           Icons.image_not_supported,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),

//             // Product Details
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       product.name,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           '${product.priceRange?.first} €/${product.unit ?? 'unit'}',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.green[700],
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const Icon(
//                           Icons.add_shopping_cart,
//                           size: 20,
//                           color: Colors.blue,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
