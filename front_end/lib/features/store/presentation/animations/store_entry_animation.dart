import 'package:flutter/material.dart' hide LinearGradient;
import 'package:flutter/material.dart' as material show LinearGradient;
import 'package:logging/logging.dart';
import 'package:rive/rive.dart';
import 'package:semo/features/store/domain/entities/store.dart';

final Logger _logger = Logger('StoreEntryAnimation');

/// A widget that displays a store entry animation using Rive
/// Shows a character walking toward a store with the store's logo
class StoreEntryAnimation extends StatefulWidget {
  /// The store to display in the animation
  final StoreBrand store;

  /// Callback when animation completes
  final VoidCallback onComplete;

  /// Duration of the animation in milliseconds
  final int durationMs;

  const StoreEntryAnimation({
    Key? key,
    required this.store,
    required this.onComplete,
    this.durationMs = 3000,
  }) : super(key: key);

  @override
  State<StoreEntryAnimation> createState() => _StoreEntryAnimationState();
}

class _StoreEntryAnimationState extends State<StoreEntryAnimation>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _walkController;
  late AnimationController _fadeController;
  late AnimationController _storeController;

  // Animations
  late Animation<double> _walkingPosition;
  late Animation<double> _fadeAnimation;

  // Path to your walking animation
  final String _walkingAnimationPath = 'assets/animations/walking_person.riv';

  @override
  void initState() {
    super.initState();

    // Initialize walking animation controller
    // Set duration to match the walking cycle (2.22 seconds per cycle)
    const cycleTimeMs = 2220; // 2.22 seconds in milliseconds

    // Calculate how many cycles we need based on the total animation duration
    // We'll use this to determine the walking speed
    final cycles = widget.durationMs / cycleTimeMs;

    // Adjust the duration to be a multiple of the cycle time for smoother animation
    final adjustedDuration = (cycles.ceil() * cycleTimeMs).toInt();

    // Initialize controllers
    _walkController = AnimationController(
      duration: Duration(milliseconds: adjustedDuration),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _storeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Define animations
    // Walking animation - character moves across screen
    _walkingPosition = Tween<double>(
      begin: -0.2, // Start slightly off-screen left
      end: 0.65, // End before right edge of screen
    ).animate(CurvedAnimation(
      parent: _walkController,
      curve: Curves.easeInOut,
    ));

    // Fade-in animation for the entire scene
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Start animation sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() {
    if (!mounted) return;

    // Start with a fade-in effect
    _fadeController.forward().then((_) {
      if (!mounted) return;

      // After fade-in, start walking
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        _walkController.forward();

        // When character reaches middle of screen, show store
        if (!mounted) return;
        _storeController.forward();
      });
    });

    // When walking completes, call the completion callback
    _walkController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            widget.onComplete();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _walkController.dispose();
    _fadeController.dispose();
    _storeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    _logger.fine('StoreEntryAnimation: ${widget.store.imageBanner}');

    return AnimatedBuilder(
      animation: Listenable.merge(
          [_walkController, _fadeController, _storeController]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            // fit: StackFit.expand,
            children: [
              // Gradient background instead of flat color
              Container(
                decoration: const BoxDecoration(
                  gradient: material.LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 155, 208, 235),
                      Colors.grey,
                    ],
                  ),
                ),
              ),

              // Stylized 2.5D store building using the banner image
              Positioned(
                top: 0,
                right: 0,
                width: size.width,
                height: size.height,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/store_baners/baner.webp'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // Walking character using Rive
              Positioned(
                left: size.width * _walkingPosition.value,
                bottom: size.height * 0.1, // Position in center vertically
                width: 300,
                height: 300,
                child: RiveAnimation.asset(
                  _walkingAnimationPath,
                  fit: BoxFit.contain,
                  alignment: const Alignment(10, 0),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
