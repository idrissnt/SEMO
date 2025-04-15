import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';

import '../../../../core/utils/logger.dart';
import '../../../store/bloc/store_bloc.dart';
import '../../../store/bloc/store_event.dart';
import '../../../store/bloc/store_state.dart';

import '../widgets/store_section.dart';
import '../widgets/custom_home_app_bar.dart';
import '../../../../core/presentation/widgets/common_widgets/error_view.dart';
import '../../../../core/presentation/widgets/common_widgets/loading_view.dart';
import '../widgets/task_suggestions_section.dart';
import '../widgets/earn_tasks_section.dart';
import '../widgets/weekly_recipes_section.dart';
import '../../../../core/presentation/widgets/common_widgets/section_separator.dart';
// import '../../widgets/homescreen/store_product_category_section.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  final Widget? child;

  const HomeScreen({
    Key? key,
    this.initialIndex = 0,
    this.child,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppLogger _logger = AppLogger();

  @override
  void initState() {
    super.initState();
    _logger.debug('HomeScreen: Initializing');
    _loadInitialData(context);
  }

  void _loadInitialData(BuildContext context) {
    try {
      _logger.debug('HomeScreen: Loading data');

      // Single event to load all stores
      context.read<StoreBloc>().add(LoadAllStoresEvent());
      //
    } catch (e) {
      _logger.error('Error in HomeScreen._loadInitialData', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const _HomeTab();
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab({Key? key}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() {
    final storeBloc = context.read<StoreBloc>();
    storeBloc.add(LoadAllStoresEvent());
    // Return a completed future to satisfy RefreshIndicator
    return Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: MultiBlocListener(
        listeners: [
          BlocListener<StoreBloc, StoreState>(
            listener: (context, state) {
              if (state is StoreError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
        ],
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // Handle scroll notifications if needed
              return false;
            },
            child: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                      context,
                    ),
                    sliver: SliverAppBar(
                      // Reduced expanded height to match app bar height
                      expandedHeight: kToolbarHeight * 2.0,
                      collapsedHeight: kToolbarHeight,
                      toolbarHeight: kToolbarHeight,
                      pinned: true,
                      primary: true, // This ensures the status bar is respected
                      stretch: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,

                      // Ensure status bar is visible with proper styling
                      systemOverlayStyle: SystemUiOverlayStyle
                          .dark, // Use .light for dark backgrounds
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(color: context.backgroundColor),
                        collapseMode: CollapseMode.pin,
                        expandedTitleScale: 1.0,
                        titlePadding: EdgeInsets.zero,
                        title: LayoutBuilder(
                          builder: (context, constraints) {
                            final top = constraints.biggest.height;

                            // Adjust the threshold to make collapsing happen earlier
                            // Adjusted ratio calculation for reduced app bar height

                            final scrolledRatio = ((top -
                                        context.getResponsiveHeightValue(
                                            kToolbarHeight)) /
                                    (context.getResponsiveHeightValue(
                                        kToolbarHeight)))
                                .clamp(0.0, 1.0);
                            // Consider collapsed when scrolledRatio is less than 1
                            final isCollapsed = scrolledRatio < 1;

                            return CustomHomeAppBar(
                              isCollapsed: isCollapsed,
                              scrolledRatio: scrolledRatio,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: Builder(builder: (context) {
                // Use the app's responsive system for padding
                final topPadding =
                    context.getResponsiveHeightValue(kToolbarHeight * 1.6);

                return SingleChildScrollView(
                  padding: EdgeInsets.only(top: topPadding),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlocBuilder<StoreBloc, StoreState>(
                        buildWhen: (previous, current) =>
                            current is AllStoresLoaded ||
                            current is StoreLoading ||
                            current is StoreError,
                        builder: (context, state) {
                          if (state is StoreLoading) {
                            return const LoadingView();
                          } else if (state is StoreError) {
                            return ErrorView(message: state.message);
                          } else if (state is AllStoresLoaded) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (state.bigStores.isNotEmpty)
                                  StoreSection(
                                    title: 'Fais tes courses chez :',
                                    stores: state.bigStores,
                                    isLarge: true,
                                  ),
                                const SectionSeparator(),
                                // Add Task Suggestions Section
                                TaskSuggestionsSection(
                                  title: 'Besoin d\'un coup de main ?',
                                  taskSuggestions: getSampleTaskSuggestions(),
                                ),
                                const SectionSeparator(),
                                // Add Earn Tasks Section
                                EarnTasksSection(
                                  // title: 'Dispo et motivé ? Y\'a du boulot !',
                                  // title: 'Dispo = Money. Simple, non ?',
                                  // title: 'Dispo et motivé ? Fais du fric !',
                                  title: 'Accomplir une tache !',
                                  earnTasks: getSampleEarnTasks(),
                                ),
                                const SectionSeparator(),
                                // Add Earn when going to store Section
                                EarnTasksSection(
                                  title: 'Tu vas au magasin ? Fais du fric ! ',
                                  earnTasks: getSampleEarnTasks(),
                                ),
                                const SectionSeparator(),
                                // Add Weekly Recipes Section
                                WeeklyRecipesSection(
                                  title: 'Recettes de la semaine',
                                  recipes: getSampleRecipes(),
                                ),
                                const SectionSeparator(),

                                // Add Product Category Section for Lidl - with dedicated widget
                                // if (state.bigStores.isNotEmpty)
                                //   StoreProductCategorySection(
                                //     storeName: 'Lidl',
                                //     initialStores: state.bigStores,
                                //     maxSections: 3,
                                //   ),
                                const SectionSeparator(),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      // Featured Products Section
                      // const StoreProductsSection(
                      //   storeName: 'Carrefour', // Primary store name
                      // ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
