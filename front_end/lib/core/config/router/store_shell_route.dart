import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../presentation/screens/store/store_aisles_screen/store_aisles_screen.dart';
import '../../../presentation/screens/store/store_aisles_screen/category_products_screen.dart';
import '../../../presentation/screens/store/store_products_screen.dart';
import '../../../presentation/screens/store/store_history_screen.dart';
import '../../../presentation/screens/store/store_people_screen.dart';
import '../../../presentation/widgets/common/gesture_navigation_wrapper.dart';

// Global keys to maintain state across navigations
final _storeProductsKey = GlobalKey();
final _storePeopleKey = GlobalKey();
final _storeAislesKey = GlobalKey();
final _storeHistoryKey = GlobalKey();
final _categoryProductsKeys = <String, GlobalKey>{};
// Navigator key for nested navigation
final _nestedNavigatorKey = GlobalKey<NavigatorState>();

// Added SwipeBackWrapper widget to enable native iOS swipe back gesture
class SwipeBackWrapper extends StatefulWidget {
  final Widget child;
  final double dragThreshold;
  const SwipeBackWrapper(
      {Key? key, required this.child, this.dragThreshold = 100})
      : super(key: key);

  @override
  _SwipeBackWrapperState createState() => _SwipeBackWrapperState();
}

class _SwipeBackWrapperState extends State<SwipeBackWrapper> {
  double _dragDistance = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (details) {
        // Start tracking only if drag begins near the left edge (within 20 pixels)
        if (details.globalPosition.dx <= 20) {
          _dragDistance = 0.0;
        }
      },
      onHorizontalDragUpdate: (details) {
        // Only accumulate drag distance if started near left edge or already tracking
        if (details.globalPosition.dx <= 20 || _dragDistance > 0) {
          _dragDistance += details.delta.dx;
        }
      },
      onHorizontalDragEnd: (details) {
        // If drag distance exceeds threshold, trigger a back navigation
        if (_dragDistance > widget.dragThreshold) {
          Navigator.maybePop(context);
        }
      },
      child: widget.child,
    );
  }
}

ShellRoute getStoreShellRoute() {
  return ShellRoute(
    builder: (context, state, child) {
      // Extract storeId from the path for navigation
      final uri = state.uri;
      final pathSegments = uri.pathSegments;
      String storeId = '';

      if (pathSegments.length >= 2 && pathSegments[0] == 'store') {
        storeId = pathSegments[1];
      }

      // Determine which tab is active
      int currentIndex = 0;
      if (pathSegments.length >= 3) {
        switch (pathSegments[2]) {
          case 'people':
            currentIndex = 2;
            break;
          case 'stores_aisles':
            currentIndex = 1;
            break;
          case 'category':
            currentIndex =
                1; // Keep the stores_aisles tab active when viewing a category
            break;
          case 'history':
            currentIndex = 3;
            break;
        }
      }

      // Define navigation items once to avoid duplication
      // ignore: prefer_const_declarations
      final navigationItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.store_outlined),
          activeIcon: Icon(Icons.store),
          label: 'Magasin',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_outlined),
          activeIcon: Icon(Icons.grid_view),
          label: 'Rayons',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_add_alt_1_outlined),
          activeIcon: Icon(Icons.person_add_alt_1_sharp),
          label: 'Ajouter',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined),
          activeIcon: Icon(Icons.history),
          label: 'Historique',
        ),
      ];

      // Navigation handler function
      void onTabTapped(int index) {
        switch (index) {
          case 0:
            context.go('/store/$storeId');
            break;
          case 1:
            context.go('/store/$storeId/stores_aisles');
            break;
          case 2:
            context.go('/store/$storeId/people');
            break;
          case 3:
            context.go('/store/$storeId/history');
            break;
        }
      }

      // Check if we're viewing a category
      bool isViewingCategory =
          pathSegments.length >= 3 && pathSegments[2] == 'category';

      return SwipeBackWrapper(
        child: Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: [
              // Store Products Screen
              KeyedSubtree(
                key: _storeProductsKey,
                child: GestureNavigationWrapper(
                  child: StoreProductsScreen(
                    storeId: storeId,
                    initialCategory: state.uri.queryParameters['category'],
                  ),
                  onBackGesture: () => context.go('/homeScreen'),
                ),
              ),
              // Store Aisles Screen with nested navigation for categories
              KeyedSubtree(
                key: _storeAislesKey,
                child: Navigator(
                  key: _nestedNavigatorKey,
                  onGenerateRoute: (settings) {
                    // Default to showing the aisles screen
                    if (!isViewingCategory) {
                      return MaterialPageRoute(
                        builder: (_) => GestureNavigationWrapper(
                          child: StoreAislesScreen(storeId: storeId),
                          onBackGesture: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              context.go('/store/$storeId');
                            }
                          },
                        ),
                      );
                    }

                    // When viewing a category, show the category screen but keep the navigator
                    return MaterialPageRoute(
                      builder: (_) => GestureNavigationWrapper(
                        child: child,
                        onBackGesture: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            context.go('/store/$storeId/stores_aisles');
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              // Store People Screen
              KeyedSubtree(
                key: _storePeopleKey,
                child: GestureNavigationWrapper(
                  child: StorePeopleScreen(storeId: storeId),
                  onBackGesture: () => context.go('/homeScreen'),
                ),
              ),
              // Store History Screen
              KeyedSubtree(
                key: _storeHistoryKey,
                child: GestureNavigationWrapper(
                  child: StoreHistoryScreen(storeId: storeId),
                  onBackGesture: () => context.go('/homeScreen'),
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: currentIndex,
            onTap: onTabTapped,
            items: navigationItems,
          ),
        ),
      );
    },
    routes: [
      GoRoute(
        path: '/store/:storeId',
        pageBuilder: (context, state) {
          return const NoTransitionPage(
            child: SizedBox(), // Empty placeholder
          );
        },
      ),
      GoRoute(
        path: '/store/:storeId/people',
        pageBuilder: (context, state) {
          return const NoTransitionPage(
            child: SizedBox(), // Empty placeholder
          );
        },
      ),
      GoRoute(
        path: '/store/:storeId/stores_aisles',
        pageBuilder: (context, state) {
          return const NoTransitionPage(
            child: SizedBox(), // Empty placeholder
          );
        },
      ),
      GoRoute(
        path: '/store/:storeId/category/:categoryName',
        name: 'category_products',
        pageBuilder: (context, state) {
          final storeId = state.pathParameters['storeId']!;
          final categoryName = state.pathParameters['categoryName']!;
          final category = state.extra as Map<String, dynamic>? ?? {};

          // Create a unique key for this category if it doesn't exist
          final categoryKey = '$storeId-$categoryName';
          if (!_categoryProductsKeys.containsKey(categoryKey)) {
            _categoryProductsKeys[categoryKey] = GlobalKey();
          }

          return NoTransitionPage(
            child: KeyedSubtree(
              key: _categoryProductsKeys[categoryKey],
              child: CategoryProductsScreen(
                storeId: storeId,
                categoryName: categoryName,
                category: category,
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: '/store/:storeId/history',
        pageBuilder: (context, state) {
          return const NoTransitionPage(
            child: SizedBox(), // Empty placeholder
          );
        },
      ),
    ],
  );
}
