import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/utils/logger.dart';

/// Type definition for a function that creates routes
typedef RouteCreator = List<RouteBase> Function(Widget initialPage);

/// A widget that provides navigation capabilities within a bottom sheet
/// This allows for sub-routes within the bottom sheet without closing it
class BottomSheetNavigator extends StatefulWidget {
  /// The initial page to display in the navigator
  final Widget initialPage;

  /// The initial route path for the navigator
  final String initialRoute;

  /// Function that creates routes for this navigator
  final RouteCreator routeCreator;

  /// ScrollController for the bottom sheet
  final ScrollController? scrollController;

  const BottomSheetNavigator({
    Key? key,
    required this.initialPage,
    required this.initialRoute,
    required this.routeCreator,
    this.scrollController,
  }) : super(key: key);

  @override
  State<BottomSheetNavigator> createState() => BottomSheetNavigatorState();
}

class BottomSheetNavigatorState extends State<BottomSheetNavigator> {
  late final GoRouter _router;
  final _logger = AppLogger();

  @override
  void initState() {
    super.initState();
    _initializeRouter();
  }

  /// Initialize the router with the required routes
  void _initializeRouter() {
    _router = GoRouter(
      initialLocation: widget.initialRoute,
      debugLogDiagnostics: true,
      routes: _createRoutes(),
    );
  }

  /// Create the list of routes for the router
  List<RouteBase> _createRoutes() {
    return widget.routeCreator(widget.initialPage);
  }

  /// Navigate to a specific route path
  void navigateTo(String path) {
    _logger.debug('Navigating to bottom sheet route: $path');
    _router.push(path);
  }

  /// Navigate to a specific route with parameters
  void navigateToWithParams(String path, Map<String, String> params) {
    _logger.debug('Navigating to bottom sheet route with params: $path');
    _router.push(path, extra: params);
  }

  /// Go back to the previous route
  void goBack() {
    if (_router.canPop()) {
      _logger.debug('Going back in bottom sheet navigation');
      _router.pop();
    } else {
      _logger.debug('Cannot go back in bottom sheet navigation, closing sheet');
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          if (_router.canPop()) {
            _router.pop();
          } else {
            Navigator.of(context).pop(result);
          }
        }
      },
      child: Builder(
        builder: (context) {
          // Get the theme from the parent context
          final parentTheme = Theme.of(context);

          return Theme(
            // Use the parent theme data
            data: parentTheme,
            child: Router(
              routerDelegate: _router.routerDelegate,
              routeInformationParser: _router.routeInformationParser,
              routeInformationProvider: _router.routeInformationProvider,
              backButtonDispatcher: RootBackButtonDispatcher(),
            ),
          );
        },
      ),
    );
  }
}
