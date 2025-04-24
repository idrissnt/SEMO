// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_event.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_state.dart';
import 'package:semo/features/auth/presentation/widgets/shared/background.dart';
import 'package:semo/features/auth/presentation/widgets/welcom/store_card.dart';
import 'package:semo/features/auth/presentation/widgets/welcom/task_card.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';

final AppLogger logger = AppLogger();

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
                  buildCompanyAsset(context),
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

Widget buildCompanyAsset(BuildContext context) {
  return BlocBuilder<WelcomeAssetsBloc, WelcomeAssetsState>(
    builder: (context, state) {
      if (state is AllAssetsLoaded) {
        logger.info('Company logo: ${state.companyAsset.logoUrl}');
        logger.info('Company name: ${state.companyAsset.companyName}');
        return CompanyShowcase(
          companyLogo: state.companyAsset.logoUrl,
          companyName: state.companyAsset.companyName,
        );
      } else if (state is AllAssetsLoading) {
        logger.info('Company asset loading...');
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else {
        logger.info('Company asset not loaded');
        _scheduleRetryLoad(context);
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    },
  );
}

class CompanyShowcase extends StatelessWidget {
  const CompanyShowcase({
    Key? key,
    required this.companyLogo,
    required this.companyName,
  }) : super(key: key);

  final String companyLogo;
  final String companyName;

  @override
  Widget build(BuildContext context) {
    logger.info('Company logo: $companyLogo');
    logger.info('Company name: $companyName');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            companyLogo,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildLoadingIndicator(loadingProgress);
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackIcon(context, 60);
            },
          ),
        ),
        const SizedBox(width: 16),
        Text(
          companyName,
          style: context.semoWelcome,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFallbackIcon(BuildContext context, double size) {
    return Icon(
      Icons.store,
      size: size,
      color: context.textSecondaryColor,
    );
  }

  Widget _buildLoadingIndicator(ImageChunkEvent loadingProgress) {
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  }
}

void _scheduleRetryLoad(BuildContext context) {
  Future.delayed(const Duration(seconds: 3), () {
    if (context.mounted) {
      context.read<WelcomeAssetsBloc>().add(const LoadAllAssetsEvent());
    }
  });
}
