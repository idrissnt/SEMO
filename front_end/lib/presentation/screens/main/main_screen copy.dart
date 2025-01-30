// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, no_leading_underscores_for_local_identifiers, sized_box_for_whitespace

import 'package:flutter/material.dart';
import '../mission/mission_screen.dart';
import '../earn/earn_screen.dart';
import '../message/message_screen.dart';
import '../semo_ai/semo_ai_screen.dart';
import '../../widgets/app_bars/custom_home_app_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
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
  final List<StoreModel> bigStores = [
    StoreModel(
      name: 'Store 4',
      imageUrl: 'assets/images/big_stores/e-leclerc-logo.png',
      rating: 4.8,
      isOpen: true,
    ),
    StoreModel(
      name: 'Store 5',
      imageUrl: 'assets/images/big_stores/lidl-logo.png',
      rating: 4.8,
      isOpen: true,
    ),
    StoreModel(
      name: 'Store 2',
      imageUrl: 'assets/images/big_stores/carrefour-logo.png',
      rating: 4.2,
      isOpen: false,
    ),
    StoreModel(
      name: 'Store 6',
      imageUrl: 'assets/images/big_stores/aldi-logo.png',
      rating: 4.8,
      isOpen: true,
    ),
    StoreModel(
      name: 'Store 1',
      imageUrl: 'assets/images/big_stores/intermarche-logo.png',
      rating: 4.5,
      isOpen: true,
    ),
    StoreModel(
      name: 'Store 3',
      imageUrl: 'assets/images/big_stores/auchan-logo.png',
      rating: 4.8,
      isOpen: true,
    ),
  ];

  final List<StoreModel> smallStores = [
    StoreModel(
      name: 'Store 4',
      logoUrl: 'assets/images/small_stores/carrefour_express_logo.jpeg',
    ),
    StoreModel(
      name: 'Store 5',
      logoUrl: 'assets/images/small_stores/carrefour_city_logo.jpeg',
    ),
    StoreModel(
      name: 'Store 6',
      logoUrl: 'assets/images/small_stores/E-Leclerc-Express-logo.png',
    ),
  ];

  final Map<String, List<ProductModel>> productCategories = {
    'fruits frais': [
      ProductModel(
        name: 'Banane France',
        price: 2.52,
        imageUrl: 'assets/images/products/banane_france.jpg',
        quantity: '1.25 kg',
      ),
      ProductModel(
        name: 'raisins blancs noirs',
        price: 0.31,
        imageUrl: 'assets/images/products/raisins-blanc-noir.png',
        quantity: '1.5 kg',
      ),
    ],
    'Legumes': [
      ProductModel(
        name: 'poivron',
        price: 2.54,
        imageUrl: 'assets/images/products/poivron.jpeg',
        quantity: '175 g',
      ),
      ProductModel(
        name: 'potato',
        price: 7.58,
        imageUrl: 'assets/images/products/potatos.png',
        quantity: '600 g',
      ),
    ],
  };

  // Helper method to build section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Helper method to build big store cards
  Widget _buildBigStoreCard(StoreModel store) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF4A3B30),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundImage: AssetImage(
                store.imageUrl ?? 'assets/images/carrefour.png',
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to build small store cards
  Widget _buildSmallStoreCard(StoreModel store) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF4A3B30),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(
                store.logoUrl ?? 'assets/images/carrefour.png',
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to build product recommendation cards
  Widget _buildProductCard(ProductModel product) {
    return Container(
      width: 140,
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(
                        product.imageUrl ?? 'assets/default_image.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.add, size: 20),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '€${product.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            product.name,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            product.quantity ?? 'no quantity',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create a section divider
  Widget _buildSectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Divider(
        color: Colors.grey.shade300,
        height: 1,
        thickness: 1,
      ),
    );
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
          body: Builder(
            builder: (context) {
              return CustomScrollView(
                slivers: [
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      // Big Stores Section
                      _buildSectionTitle('Big Stores'),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            bigStores.length,
                            (index) => _buildBigStoreCard(bigStores[index]),
                          ),
                        ),
                      ),
                      _buildSectionDivider(),
                      // Small Stores Section
                      _buildSectionTitle('Small Stores'),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            smallStores.length,
                            (index) => _buildSmallStoreCard(smallStores[index]),
                          ),
                        ),
                      ),
                      _buildSectionDivider(),
                      // Fruits Frais Section
                      _buildSectionTitle('Fruits Frais'),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            productCategories['fruits frais']!.length,
                            (index) => _buildProductCard(
                                productCategories['fruits frais']![index]),
                          ),
                        ),
                      ),
                      _buildSectionDivider(),
                      // Snacks Section
                      _buildSectionTitle('Snacks'),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            productCategories['Snacks']!.length,
                            (index) => _buildProductCard(
                                productCategories['Snacks']![index]),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class StoreModel {
  final String name;
  final String? imageUrl;
  final String? logoUrl;
  final double? rating;
  final bool? isOpen;
  final Map<String, List<ProductModel>>? categories;

  StoreModel({
    required this.name,
    this.imageUrl,
    this.logoUrl,
    this.rating,
    this.isOpen,
    this.categories,
  });
}

class ProductModel {
  final String name;
  final String? imageUrl;
  final double price;
  final String? quantity;

  ProductModel({
    required this.name,
    this.imageUrl,
    required this.price,
    this.quantity,
  });
}
