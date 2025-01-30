// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, no_leading_underscores_for_local_identifiers, sized_box_for_whitespace, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/store_model.dart';
import '../../blocs/home/home_event.dart';
import '../../blocs/product/product_event.dart';
import '../../blocs/product/product_state.dart';
import '../../blocs/store/store_event.dart';
import '../../widgets/homescreen/product_card.dart';
import '../../widgets/homescreen/store_cards.dart';
import '../mission/mission_screen.dart';
import '../earn/earn_screen.dart';
import '../message/message_screen.dart';
import '../semo_ai/semo_ai_screen.dart';
import '../../blocs/home/home_bloc.dart';
import '../../blocs/home/home_state.dart';
import '../../blocs/store/store_bloc.dart';
import '../../blocs/product/product_bloc.dart';
import '../../widgets/app_bars/custom_home_app_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
    // Fetch stores and products when the screen initializes
    try {
      context.read<StoreBloc>().add(LoadAllStores());
      context.read<ProductBloc>().add(LoadProducts());
    } catch (e) {
      print('Error initializing MainScreen: $e');
      // Optionally show a snackbar or handle the error
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
  @override
  void initState() {
    super.initState();
    // Trigger home data loading
    context.read<HomeBloc>().add(LoadHomeData());
    context.read<ProductBloc>().add(LoadProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          return false;
        },
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
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
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        final top = constraints.biggest.height;
                        final scrolledRatio =
                            ((top - kToolbarHeight) / (kToolbarHeight * 1.45))
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
          body: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return Center(child: CircularProgressIndicator());
              }

              if (state is HomeLoaded) {
                return BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, productState) {
                    if (productState is ProductsLoaded) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                                height: 100), // Add space after the search bar
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Big Stores",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            Container(
                              height: 160,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                itemCount: state.bigStores.length,
                                itemBuilder: (context, index) {
                                  return BigStoreCard(
                                    store: StoreModel.fromEntity(
                                        state.bigStores[index]),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Small Stores",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            Container(
                              height: 140,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                itemCount: state.smallStores.length,
                                itemBuilder: (context, index) {
                                  return SmallStoreCard(
                                    store: StoreModel.fromEntity(
                                        state.smallStores[index]),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 16),
                            ...productState.productCategories.entries
                                .map((entry) {
                              final categoryName =
                                  entry.key.replaceAll('_', ' ');
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      categoryName.toUpperCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  Container(
                                    height: 220,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      itemCount: entry.value.length,
                                      itemBuilder: (context, index) {
                                        return ProductCard(
                                          product: entry.value[index]
                                              as ProductModel,
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                );
              }

              if (state is HomeError) {
                return Center(
                  child: Text('Error loading home data: ${state.message}'),
                );
              }

              return Center(child: Text('Unexpected state'));
            },
          ),
        ),
      ),
    );
  }
}
