import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/logger.dart';
import '../../blocs/store/store_bloc.dart';
import '../../blocs/store/store_event.dart';
import '../../blocs/store/store_state.dart';
import '../../widgets/homescreen/store_section.dart';
import '../../widgets/homescreen/custom_home_app_bar.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/loading_view.dart';
// import '../../widgets/store/store_products_section.dart';
import '../mission/mission_screen.dart';
import '../earn/earn_screen.dart';
import '../message/message_screen.dart';
import '../semo_ai/semo_ai_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AppLogger _logger = AppLogger();
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _HomeTab(),
    const MissionScreen(),
    const EarnScreen(),
    const MessageScreen(),
    const SemoAIScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _logger.debug('MainScreen: Initializing');
    _loadInitialData(context);
  }

  void _loadInitialData(BuildContext context) {
    try {
      _logger.debug('MainScreen: Loading data');
      // Single event to load all stores
      context.read<StoreBloc>().add(LoadAllStoresEvent());
    } catch (e) {
      _logger.error('Error in MainScreen._loadInitialData', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _logger.debug('Navigation tab changed to index: $index');
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Mission',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on_outlined),
            activeIcon: Icon(Icons.monetization_on),
            label: 'Earn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            activeIcon: Icon(Icons.message),
            label: 'Message',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined),
            activeIcon: Icon(Icons.psychology),
            label: 'SEMO AI',
          ),
        ],
      ),
    );
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
      backgroundColor: Colors.white,
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
                      expandedHeight: kToolbarHeight * 2.45,
                      collapsedHeight: kToolbarHeight,
                      toolbarHeight: kToolbarHeight,
                      pinned: true,
                      primary: true,
                      stretch: true,
                      stretchTriggerOffset: 30.0,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(color: Colors.white),
                        collapseMode: CollapseMode.pin,
                        expandedTitleScale: 1.0,
                        titlePadding: EdgeInsets.zero,
                        title: LayoutBuilder(
                          builder: (context, constraints) {
                            final top = constraints.biggest.height;
                            final scrolledRatio = ((top - kToolbarHeight) /
                                    (kToolbarHeight * 1.45))
                                .clamp(0.0, 1.0);
                            final isCollapsed = scrolledRatio < 0.5;
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
              body: SingleChildScrollView(
                padding: const EdgeInsets.only(top: kToolbarHeight * 2),
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
                                  title: 'Big Stores',
                                  stores: state.bigStores,
                                  isLarge: true,
                                ),
                              if (state.smallStores.isNotEmpty)
                                StoreSection(
                                  title: 'Small Stores',
                                  stores: state.smallStores,
                                  isLarge: false,
                                ),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
