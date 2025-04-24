// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:semo/core/presentation/theme/responsive_theme.dart';
// import 'package:semo/core/utils/logger.dart';
// import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_bloc.dart';
// import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_state.dart';

// final AppLogger logger = AppLogger();

// Widget buildStoreCard(BuildContext context) {
//   return Card(
//     color: Colors.white,
//     elevation: 4,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(33)),
//     child: SizedBox(
//       width: context.responsiveItemSize(300),
//       child: BlocBuilder<WelcomeAssetsBloc, WelcomeAssetsState>(
//         builder: (context, state) {
//           // Handle different state types directly
//           if (state is StoreAssetLoaded && state.storeAsset != null) {
//             // Successfully loaded with store assets

//             // data preparation
//             return StoreCardShowcaseGrid(
//               titleText: state.storeAsset.title,
//               mainCards: data['mainCards'],
//               backgroundImages: data['backgroundImages'],
//               backgroundColor: Colors.white,
//               textColor: Colors.black,
//               padding: const EdgeInsets.all(16.0),
//             );
//           } else if (state is StoreAssetLoaded) {
//             // Loaded but empty
//             logger.info('Store assets loaded but empty');
//             return const Center(
//               child: Text('store assets coming soon...',
//                   style: TextStyle(color: Colors.black)),
//             );
//           } else if (state is StoreAssetLoading || state is AllAssetsLoading) {
//             // Loading state
//             logger.info('Store assets loading...');
//             return const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(color: Colors.blue),
//                   SizedBox(height: 16),
//                   Text('Loading assets...',
//                       style: TextStyle(color: Colors.black)),
//                 ],
//               ),
//             );
//           } else {
//             // Error or other states
//             logger.info('Unknown state: ${state.runtimeType}');
//             _scheduleRetryLoad(context);

//             // Create a placeholder grid
//             return const StoreCardShowcaseGrid(
//               titleText: 'Loading content...',
//               backgroundColor: Colors.white,
//               textColor: Colors.black,
//               padding: EdgeInsets.all(16.0),
//               mainCards: [],
//               backgroundImages: [],
//             );
//           }
//         },
//       ),
//     ),
//   );
// }
