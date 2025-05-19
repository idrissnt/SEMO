// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:semo/features/store/domain/entities/store.dart';
// import 'package:semo/features/store/presentation/animations/store_entry.dart/store_entry_animation.dart';
// import 'package:semo/features/store/routes/store_routes_const.dart';

// /// Service for displaying store animations
// class StoreAnimationService {
//   /// Shows the store entry animation and navigates to the store detail page when complete
//   static void showStoreEntryAnimation(BuildContext context, StoreBrand store) {
//     // Show a full-screen dialog with the animation
//     showGeneralDialog(
//       context: context,
//       barrierDismissible: false, // User must wait for animation
//       // barrierColor: Colors.black,
//       transitionDuration: const Duration(milliseconds: 100),
//       pageBuilder: (context, _, __) {
//         return Material(
//           type: MaterialType.transparency,
//           child: StoreEntryAnimation(
//             store: store,
//             onComplete: () {
//               // FIRST initiate navigation to the store detail page
//               // This queues up the navigation but doesn't execute it immediately
//               context.go(StoreRoutesConst.getStoreDetailRoute(store.id));

//               // THEN close the animation dialog
//               // This will allow the navigation to proceed with the transition
//               Navigator.of(context).pop();
//             },
//           ),
//         );
//       },
//     );
//   }
// }
