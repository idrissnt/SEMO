// import 'package:flutter/material.dart' hide LinearGradient;
// import 'package:flutter/material.dart' as material show LinearGradient;
// import 'package:rive/rive.dart';
// import 'package:semo/features/store/domain/entities/store.dart';

// /// A widget that displays a store entry animation using Rive
// /// Shows a character walking toward a store with the store's logo

// class StoreEntryAnimation extends StatefulWidget {
//   /// The store to display in the animation
//   final StoreBrand store;

//   /// Callback when animation completes
//   final VoidCallback onComplete;

//   /// Duration of the animation in milliseconds
//   final int durationMs;

//   const StoreEntryAnimation({
//     Key? key,
//     required this.store,
//     required this.onComplete,
//     this.durationMs = 2000,
//   }) : super(key: key);

//   @override
//   State<StoreEntryAnimation> createState() => _StoreEntryAnimationState();
// }

// class _StoreEntryAnimationState extends State<StoreEntryAnimation>
//     with TickerProviderStateMixin {
//   // Animation controllers
//   late AnimationController _walkController;
//   late AnimationController _fadeController;
//   late AnimationController _storeController; // For store banner animation
//   late AnimationController _exitController; // For exit animation

//   // Animations
//   late Animation<double> _walkingPosition; // Horizontal position
//   late Animation<double> _walkingDepth; // For z-axis movement (depth)
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _storeAnimation; // For store banner appearance
//   late Animation<double> _exitAnimation; // For exit to top of screen

//   // Path to the walking animation
//   final String _walkingAnimationPath = 'assets/animations/walking_person.riv';

//   @override
//   void initState() {
//     super.initState();

//     // Initialize animation controllers
//     _walkController = AnimationController(
//       duration: Duration(milliseconds: widget.durationMs),
//       vsync: this,
//     );

//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 100),
//       vsync: this,
//     );

//     _storeController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );

//     _exitController = AnimationController(
//       duration: const Duration(milliseconds: 100),
//       vsync: this,
//     );

//     // Define animations
//     _walkingPosition = Tween<double>(
//       begin: -0.5, // Start at left side of screen
//       end: 0.1, // End at center of screen
//     ).animate(CurvedAnimation(
//       parent: _walkController,
//       curve: Curves.easeInOut,
//     ));

//     _walkingDepth = Tween<double>(
//       begin: 0.0, // Start at front
//       end: 0.7, // End deeper into the screen
//     ).animate(CurvedAnimation(
//       parent: _walkController,
//       curve: Curves.easeInOut,
//     ));

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeIn,
//     ));

//     // Store banner animation - scales up from bottom
//     _storeAnimation = Tween<double>(
//       begin: 0.0, // Start hidden
//       end: 1.0, // End fully visible
//     ).animate(CurvedAnimation(
//       parent: _storeController,
//       curve: Curves.elasticOut, // Bouncy effect like coming from a button
//     ));

//     // Exit animation - moves everything to the top of the screen
//     _exitAnimation = Tween<double>(
//       begin: 0.0, // Start at current position
//       end: 1.0, // End at top of screen
//     ).animate(CurvedAnimation(
//       parent: _exitController,
//       curve: Curves.easeIn, // Quick exit
//     ));

//     _startAnimationSequence();
//   }

//   void _startAnimationSequence() {
//     if (!mounted) return;

//     // Start with a fade-in effect
//     _fadeController.forward().then((_) {
//       if (!mounted) return;

//       // After fade-in, animate the store banner (simulating button press effect)
//       _storeController.forward().then((_) {
//         if (!mounted) return;

//         // After store appears, start walking
//         Future.delayed(const Duration(milliseconds: 300), () {
//           if (!mounted) return;
//           _walkController.forward();
//         });
//       });
//     });

//     // When walking completes, start exit animation
//     _walkController.addStatusListener((status) {
//       if (status == AnimationStatus.completed && mounted) {
//         // Start exit animation
//         _exitController.forward().then((_) {
//           // After exit animation completes, call the completion callback
//           if (mounted) {
//             widget.onComplete();
//           }
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _walkController.dispose();
//     _fadeController.dispose();
//     _storeController.dispose();
//     _exitController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return AnimatedBuilder(
//       animation: Listenable.merge([
//         _walkController,
//         _fadeController,
//         _storeController,
//         _exitController
//       ]),
//       builder: (context, child) {
//         // Calculate scale based on depth
//         final scale = 1.0 - (_walkingDepth.value * 0.5);

//         return FadeTransition(
//           opacity: _fadeAnimation,
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               // Sky background
//               Container(
//                 decoration: const BoxDecoration(
//                   gradient: material.LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Color(0xFF9BD0EB), // Light blue
//                       Colors.grey,
//                     ],
//                   ),
//                 ),
//               ),

//               // Floor with perspective
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 height: size.height * 0.3,
//                 child: Transform(
//                   transform: Matrix4.identity()
//                     ..setEntry(3, 2, 0.001) // Add perspective
//                     ..rotateX(-0.3), // Rotate to create floor effect
//                   alignment: Alignment.topCenter,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       gradient: material.LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           Colors.grey.shade400,
//                           Colors.grey.shade600,
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               // Store building with animation (coming from button press and exit to top)
//               Positioned(
//                 top: -size.height *
//                     _exitAnimation.value, // Move to top during exit
//                 left: 0,
//                 right: 0,
//                 height: size.height * 0.7,
//                 child: Transform.scale(
//                   // Scale based on both appearance and exit animations
//                   scale: _exitAnimation.value > 0
//                       ? _storeAnimation.value *
//                           (1.0 -
//                               _exitAnimation.value * 0.7) // Shrink during exit
//                       : _storeAnimation.value,
//                   alignment: Alignment.bottomCenter, // Scale from bottom
//                   child: Transform.translate(
//                     offset: Offset(
//                         0,
//                         20 *
//                             (1 -
//                                 _storeAnimation
//                                     .value)), // Slight upward movement
//                     child: Container(
//                       decoration: const BoxDecoration(
//                         image: DecorationImage(
//                           image: NetworkImage(
//                               // TODO: Replace with dynamic store banner
//                               'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/store_baners/baner.webp'),
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               // Walking character with exit animation
//               Positioned(
//                 left: size.width * _walkingPosition.value,
//                 // Move from bottom to top during exit animation
//                 bottom: _exitAnimation.value > 0
//                     ? size.height *
//                         (1.2 * _exitAnimation.value) // Move up and off screen
//                     : size.height *
//                         (0.1 + (_walkingDepth.value * 0.1)), // Normal position
//                 child: Transform.scale(
//                   // Scale based on both depth and exit animations
//                   scale: _exitAnimation.value > 0
//                       ? scale *
//                           (1.0 -
//                               _exitAnimation.value * 0.8) // Shrink during exit
//                       : scale,
//                   child: SizedBox(
//                     width: 300,
//                     height: 300,
//                     child: RiveAnimation.asset(
//                       _walkingAnimationPath,
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
