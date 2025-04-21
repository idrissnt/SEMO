// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:semo/core/presentation/navigation/router_services/route_constants.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';
import 'package:semo/features/home/presentation/bloc/home_store/home_store_bloc.dart';
import 'package:semo/features/home/presentation/bloc/home_store/home_store_state.dart';
import 'package:semo/features/auth/presentation/widgets/welcom_store.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _appNameController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _appNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            painter: AuthBackgroundPainter(),
            size: Size.infinite,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'SEMO',
                    style: context.semoWelcome,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),
                  // Horizontally scrollable widget section
                  SizedBox(
                    height: 500,
                    width: context.responsiveItemSize(300),
                    child: PageView(
                      controller: _pageController,
                      children: [
                        _buildCard(
                          context,
                          'Vos courses livrées\nen 1 heure',
                        ),
                        _buildCard(
                          context,
                          'Vos Courses',
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Pagination indicators
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: 2,
                        effect: const ExpandingDotsEffect(
                          activeDotColor: Colors.blue,
                          dotColor: Colors.grey,
                          dotHeight: 8,
                          dotWidth: 8,
                          expansionFactor: 2,
                          spacing: 4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(33)),
      child: SizedBox(
        width: context.responsiveItemSize(300),
        child: Padding(
          padding: const EdgeInsets.only(
              top: 40.0, bottom: 40.0, left: 15.0, right: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: context.headline1,
                textAlign: TextAlign.center,
              ),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => context.go(AppRoutes.register),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color.fromARGB(255, 14, 77, 129),
                      foregroundColor: Colors.white,
                    ),
                    child: SizedBox(
                      width: context.responsiveItemSize(250),
                      child: Text(
                        'Créer un compte',
                        textAlign: TextAlign.center,
                        style: context.bodyLarge.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => context.go(AppRoutes.login),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color.fromARGB(255, 234, 232, 232),
                      disabledForegroundColor: Colors.white,
                    ),
                    child: SizedBox(
                      width: context.responsiveItemSize(250),
                      child: Text(
                        'Se connecter',
                        textAlign: TextAlign.center,
                        style: context.bodyLarge.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              BlocBuilder<HomeStoreBloc, HomeStoreState>(
                builder: (context, state) {
                  if (state is StoreBrandsLoaded &&
                      state.storeBrands.isNotEmpty) {
                    return SizedBox(
                        height: 80,
                        child: StoreSection(
                            stores: state.storeBrands, sectionHeight: 80));
                  }
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Loading stores...',
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Draw the blue gradient background
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color.fromARGB(255, 64, 71, 74), //
          Color.fromARGB(255, 10, 40, 84), // Medium blue
          Color(0xFF5E5CE6), // Blue-purple
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);

    // Create the white blob shape
    final blobPath = Path();

    // Start from bottom left
    blobPath.moveTo(0, height);

    // Create the curved edge that goes from bottom left to middle right
    blobPath.quadraticBezierTo(
      width * 0.2, height * 0.7, // Control point
      width * 0.8, height * 0.5, // End point
    );

    // Continue the curve to the bottom right
    blobPath.quadraticBezierTo(
      width * 1.1, height * 0.4, // Control point (outside screen)
      width, height * 0.7, // End point
    );

    // Complete the shape
    blobPath.lineTo(width, height);
    blobPath.close();

    // Create a gradient for the light blue/gray blob with pink tints
    final blobPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromARGB(
              255, 38, 39, 40), // Very light blue with slight pink tint
          Color(0xFFEDF0F7), // Light blue-gray
          Color.fromARGB(
              255, 153, 153, 180), // Light blue-gray with slight pink tint
        ],
        stops: [0.2, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, height * 0.4, width, height * 0.6));

    // Draw the white blob
    canvas.drawPath(blobPath, blobPaint);

    // Add subtle pink highlight on top left
    final highlightPath = Path();
    highlightPath.moveTo(0, 0);
    highlightPath.lineTo(width * 0.5, 0);
    highlightPath.lineTo(0, height * 0.3);
    highlightPath.close();

    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFF5E1E9)
              .withOpacity(0.3), // Light pink with transparency
          const Color(0xFFF5E1E9).withOpacity(0.0), // Fading out
        ],
      ).createShader(Rect.fromLTWH(0, 0, width * 0.5, height * 0.3));

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
