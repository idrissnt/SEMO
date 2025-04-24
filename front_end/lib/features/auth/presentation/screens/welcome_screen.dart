// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/presentation/widgets/shared/background.dart';
import 'package:semo/features/auth/presentation/widgets/welcome/state_handler/company_asset.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';
import 'package:semo/features/auth/presentation/widgets/welcome/state_handler/pagination_indicator.dart';
import 'package:semo/features/auth/presentation/widgets/welcome/state_handler/store_card.dart';
import 'package:semo/features/auth/presentation/widgets/welcome/state_handler/task_card.dart';

final AppLogger logger = AppLogger();

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
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
              padding: EdgeInsets.symmetric(horizontal: context.lWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Company asset
                  buildCompanyAsset(context),
                  SizedBox(height: context.smallHeight),

                  // Horizontally scrollable widget section
                  SizedBox(
                    height: context.getResponsiveHeightValue(450),
                    child: PageView(
                      controller: _pageController,
                      children: [
                        buildStoreCard(context),
                        buildTaskCard(context)
                      ],
                    ),
                  ),
                  SizedBox(height: context.smallHeight),

                  // Pagination indicators
                  buildPaginationIndicators(context, _pageController),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
