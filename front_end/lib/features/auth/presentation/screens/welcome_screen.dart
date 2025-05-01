// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/core/utils/logger.dart';

import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_event.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_state.dart';
import 'package:semo/features/auth/presentation/widgets/for_welcome/screen_sections/pagination_indicator.dart';

import 'package:semo/features/auth/presentation/widgets/shared/background.dart';
import 'package:semo/features/auth/presentation/widgets/state_handler/welcom/state_handler.dart';
import 'package:semo/features/auth/presentation/widgets/for_welcome/screen_sections/company_showcase.dart';
import 'package:semo/features/auth/presentation/widgets/for_welcome/screen_sections/store_showcase.dart';
import 'package:semo/features/auth/presentation/widgets/for_welcome/screen_sections/task_showcase_grid.dart';
import 'package:semo/features/auth/presentation/widgets/for_welcome/styles/company_and_store_theme.dart';
import 'package:semo/features/auth/presentation/constants/auth_constants.dart';

final AppLogger logger = AppLogger();

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Trigger loading of welcome assets when screen initializes
    context.read<WelcomeAssetsBloc>().add(const LoadAllAssetsEvent());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int nbOfPages = AuthConstants.welcomePageCount;
  final String loadingMessage = AuthConstants.welcomeLoadingMessage;

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
            child: BlocBuilder<WelcomeAssetsBloc, WelcomeAssetsState>(
              builder: (context, state) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppDimensionsWidth.medium),
                  child: BlocBuilder<WelcomeAssetsBloc, WelcomeAssetsState>(
                    builder: (context, state) {
                      return WelcomeStateHandler.handleWelcomeAssetsState<
                          AllAssetsLoaded>(
                        context: context,
                        state: state,
                        loadingMessage: loadingMessage,
                        useShimmerLoading: false,
                        dataSelector: (loadedState) => loadedState,
                        onSuccess: (loadedAssets) {
                          return WelcomeContent(
                            loadedAssets: loadedAssets,
                            pageController: _pageController,
                            nbOfPages: nbOfPages,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A widget that displays the content of the welcome screen
/// This includes the company asset, store card, task card, and pagination indicator
class WelcomeContent extends StatelessWidget {
  /// The loaded assets to display
  final AllAssetsLoaded loadedAssets;

  /// The page controller for the horizontally scrollable section
  final PageController pageController;

  /// The number of pages in the horizontally scrollable section
  final int nbOfPages;

  /// Creates a new [WelcomeContent] widget
  const WelcomeContent({
    Key? key,
    required this.loadedAssets,
    required this.pageController,
    required this.nbOfPages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Company asset
        buildCompanyAsset(context, loadedAssets.companyAsset),
        SizedBox(height: AppDimensionsHeight.small),

        // Horizontally scrollable widget section
        SizedBox(
          height: WelcomeDimensions.bigCardHeight,
          child: PageView(
            controller: pageController,
            children: [
              buildStoreCard(context, loadedAssets.storeAsset),
              buildTaskCard(context, loadedAssets.taskAssets)
            ],
          ),
        ),
        SizedBox(height: AppDimensionsHeight.xSmall),

        // Pagination indicator
        Center(
          child: buildPaginationIndicators(context, pageController, nbOfPages),
        ),
      ],
    );
  }
}
