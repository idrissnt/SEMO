// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../../../core/utils/logger.dart';
// import '../../../store/infrastructure/models/store_model.dart';
// import '../../../store/bloc/store_bloc.dart';
// import '../../../store/bloc/store_event.dart';
// import '../../../store/bloc/store_state.dart';
// import 'product_category_section.dart';

// class StoreProductCategorySection extends StatefulWidget {
//   final String storeName;
//   final List<StoreModel> initialStores;
//   final int maxSections;

//   const StoreProductCategorySection({
//     Key? key,
//     required this.storeName,
//     required this.initialStores,
//     this.maxSections = 3,
//   }) : super(key: key);

//   @override
//   State<StoreProductCategorySection> createState() =>
//       _StoreProductCategorySectionState();
// }

// class _StoreProductCategorySectionState
//     extends State<StoreProductCategorySection> {
//   final AppLogger _logger = AppLogger();
//   StoreModel? _storeFromList;
//   bool _detailsRequested = false;

//   @override
//   void initState() {
//     super.initState();
//     _findMatchingStore();
//   }

//   void _findMatchingStore() {
//     try {
//       _storeFromList = widget.initialStores.firstWhere(
//         (s) =>
//             s.name.toLowerCase().contains(widget.storeName.toLowerCase()) ||
//             widget.storeName.toLowerCase().contains(s.name.toLowerCase()),
//       );
//       _logger.debug(
//           'Found ${widget.storeName} store: ${_storeFromList!.name} (ID: ${_storeFromList!.id})');
//     } catch (e) {
//       _logger
//           .debug('No ${widget.storeName} store found in provided store list');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<StoreBloc, StoreState>(
//       builder: (context, state) {
//         // If we found a matching store and haven't requested details yet
//         if (_storeFromList != null &&
//             _storeFromList!.id.isNotEmpty &&
//             !_detailsRequested &&
//             state is! StoreLoaded) {
//           _detailsRequested = true;
//           _logger.debug(
//               'Requesting full details for ${widget.storeName}: ${_storeFromList!.id}');
//           context.read<StoreBloc>().add(
//                 LoadStoreByIdEvent(_storeFromList!.id),
//               );

//           return const Center(
//             child: Padding(
//               padding: EdgeInsets.symmetric(vertical: 16.0),
//               child: CircularProgressIndicator(),
//             ),
//           );
//         }

//         // If we have the full store details
//         if (state is StoreLoaded) {
//           _logger.debug(
//               'Using full store details for ${widget.storeName} ProductCategorySection');
//           final store = state.store as StoreModel;

//           final sections = ProductCategorySection.forStoreMultiple(
//             stores: [store],
//             storeName: widget.storeName,
//             context: context,
//             maxSections: widget.maxSections,
//           );

//           _logger.debug(
//               'Generated ${sections.length} ${widget.storeName} sections from full details');

//           if (sections.isNotEmpty) {
//             return Column(children: sections);
//           }
//         }

//         // If we don't have detailed data yet, use lightweight data as fallback
//         if (_storeFromList != null || widget.initialStores.isNotEmpty) {
//           _logger.debug(
//               'Using lightweight data for ${widget.storeName} as fallback');

//           final sections = ProductCategorySection.forStoreMultiple(
//             stores: widget.initialStores,
//             storeName: widget.storeName,
//             context: context,
//             maxSections: widget.maxSections,
//           );

//           _logger.debug(
//               'Generated ${sections.length} ${widget.storeName} sections from lightweight data');

//           if (sections.isNotEmpty) {
//             return Column(children: sections);
//           }
//         }

//         // If no sections could be generated
//         return Center(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 16.0),
//             child: Text('No products available from ${widget.storeName}'),
//           ),
//         );
//       },
//     );
//   }
// }
