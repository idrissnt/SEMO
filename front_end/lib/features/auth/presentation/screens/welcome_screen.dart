// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:semo/features/auth/presentation/widgets/shared/background.dart';
import 'package:semo/features/auth/presentation/widgets/welcom/showcases/store_showcase.dart';
import 'package:semo/features/auth/presentation/widgets/welcom/task_card.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';

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
                        buildStoreCard(context),
                        buildTaskCard(context)
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Pagination indicators
                  Center(
                    child: Container(
                      padding: const EdgeInsets.only(
                          top: 8, bottom: 8, left: 12, right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: 2,
                        effect: const ExpandingDotsEffect(
                          activeDotColor: Colors.blue,
                          dotColor: Colors.grey,
                          dotHeight: 12,
                          dotWidth: 12,
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
}
