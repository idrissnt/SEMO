// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/home/home_bloc.dart';
import '../../blocs/home/home_event.dart';
import '../../blocs/home/home_state.dart';
import '../../widgets/store_card.dart';
import '../../widgets/product_card.dart';
import '../../widgets/address_bar.dart';
import '../../widgets/custom_search_bar.dart';
import '../mission/mission_screen.dart';
import '../earn/earn_screen.dart';
import '../message/message_screen.dart';
import '../semo_ai/semo_ai_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    _HomeTab(),
    const MissionScreen(),
    const SemoAIScreen(),
    const EarnScreen(),
    const MessageScreen(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(HomeLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0 ? null : AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _selectedIndex == 1 ? 'Missions' :
          _selectedIndex == 2 ? 'SEMO AI' :
          _selectedIndex == 3 ? 'Earn' : 'Messages',
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: () {
              // TODO: Navigate to cart when implemented
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cart coming soon!')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Missions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'SEMO AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Earn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  bool _isScrolled = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 50 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is HomeLoaded) {
          return NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              // You can add logic here if needed in the future
              return false;
            },
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(HomeLoadRequested());
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    floating: false,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    title: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isScrolled
                          ? const CustomSearchBar(key: ValueKey('search'))
                          : const AddressBar(key: ValueKey('address')),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart, color: Colors.black),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cart coming soon!')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.person, color: Colors.black),
                        onPressed: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                      ),
                    ],
                    automaticallyImplyLeading: false,
                  ),
                  SliverToBoxAdapter(
                    child: !_isScrolled ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CustomSearchBar(),
                    ) : const SizedBox.shrink(),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Nearby Stores
                        Text(
                          'Nearby Stores',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: state.nearbyStores
                                  .map((store) => StoreCard(
                                        store: store,
                                        isNearby: true,
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Popular Stores
                        Text(
                          'Popular Stores',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: state.popularStores
                                  .map((store) => StoreCard(
                                        store: store,
                                        isNearby: false,
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Seasonal Products
                        Text(
                          'Seasonal Products',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: state.seasonalProducts
                                  .map((product) => ProductCard(product: product))
                                  .toList(),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is HomeError) {
          return Center(child: Text(state.message));
        }
        return const Center(child: Text('Something went wrong'));
      },
    );
  }
}
