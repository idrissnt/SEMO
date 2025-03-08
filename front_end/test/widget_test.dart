import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MyApp builds correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.byType(MyApp), findsOneWidget);
  });
  WidgetsFlutterBinding.ensureInitialized();
  // runApp(const MyApp());
}

/// Root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom App Bar Demo',
      home: const MyHomePage(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // backgroundColor: Colors.white,
        cardColor: Colors.grey[200],
      ),
    );
  }
}

/// Main page displaying a NestedScrollView with a dynamic app bar.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Manages overlap between the header and inner scrollable content.
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                expandedHeight: kToolbarHeight * 2.0,
                collapsedHeight: kToolbarHeight,
                toolbarHeight: kToolbarHeight,
                pinned: true,
                primary: true,
                stretch: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                // Ensures proper status bar styling.
                systemOverlayStyle: SystemUiOverlayStyle.dark,
                flexibleSpace: FlexibleSpaceBar(
                  // background: Container(color: Theme.of(context).backgroundColor),
                  collapseMode: CollapseMode.pin,
                  expandedTitleScale: 1.0,
                  titlePadding: EdgeInsets.zero,
                  // Dynamically builds the custom app bar based on scroll constraints.
                  title: LayoutBuilder(
                    builder: (context, constraints) {
                      final top = constraints.biggest.height;
                      final scrolledRatio =
                          ((top - kToolbarHeight) / (kToolbarHeight * 1.0))
                              .clamp(0.0, 1.0);
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
        // Example scrollable content.
        body: Builder(
          builder: (context) {
            return SafeArea(
              top: false,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: 30,
                itemBuilder: (context, index) {
                  return ListTile(title: Text('Item #$index'));
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A custom app bar widget that adapts its layout based on the scroll position.
class CustomHomeAppBar extends StatelessWidget {
  final bool isCollapsed;
  final double scrolledRatio;

  const CustomHomeAppBar({
    Key? key,
    required this.isCollapsed,
    required this.scrolledRatio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Compute a scale factor based on screen height for responsiveness.
    final screenHeight = MediaQuery.of(context).size.height;
    final scaleFactor =
        screenHeight / 812.0; // Reference height (e.g., iPhone X)
    final baseToolbarHeight = kToolbarHeight * scaleFactor;
    final expandedToolbarHeight = baseToolbarHeight * 1.9;
    final appBarHeight =
        isCollapsed ? baseToolbarHeight : expandedToolbarHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Material(
          elevation: isCollapsed ? 4.0 : 0.0,
          // color: Theme.of(context).backgroundColor,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: appBarHeight,
              width: constraints.maxWidth,
              child: Stack(
                children: [
                  // Top row with location and action icons, visible only when expanded.
                  if (!isCollapsed)
                    const Positioned(
                      top: 8.0,
                      left: 16.0,
                      right: 16.0,
                      child: _TopRow(),
                    ),
                  // Animated search bar, always visible.
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    // When collapsed, pin the search bar near the top.
                    top: isCollapsed
                        ? 8.0
                        : expandedToolbarHeight - baseToolbarHeight - 8.0,
                    left: 16.0,
                    right: 16.0,
                    height: baseToolbarHeight,
                    child: _SearchBarRow(isCollapsed: isCollapsed),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Top row widget that includes location info and action icons.
class _TopRow extends StatelessWidget {
  const _TopRow();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _LocationWidget(),
        _ActionIcons(),
      ],
    );
  }
}

/// Widget displaying the location icon, text, and dropdown arrow.
class _LocationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on, color: Theme.of(context).primaryColor),
        const SizedBox(width: 4.0),
        const SizedBox(
          width: 100,
          child: Text(
            '1226 UniverS of',
            // style: Theme.of(context).textTheme.headline6,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        Icon(Icons.keyboard_arrow_down, color: Theme.of(context).primaryColor),
      ],
    );
  }
}

/// Row of action icons: shopping cart, notifications, and person outline.
class _ActionIcons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.shopping_cart_outlined,
              color: Theme.of(context).primaryColor),
          onPressed: () {},
          padding: const EdgeInsets.all(8.0),
        ),
        IconButton(
          icon: Icon(Icons.notifications_none,
              color: Theme.of(context).primaryColor),
          onPressed: () {},
          padding: const EdgeInsets.all(8.0),
        ),
        IconButton(
          icon:
              Icon(Icons.person_outline, color: Theme.of(context).primaryColor),
          onPressed: () {},
          padding: const EdgeInsets.all(8.0),
        ),
      ],
    );
  }
}

/// A row that contains the search bar and, when collapsed, the person outline icon.
class _SearchBarRow extends StatelessWidget {
  final bool isCollapsed;
  const _SearchBarRow({required this.isCollapsed});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Search bar takes up most of the horizontal space.
        Expanded(child: _SearchBar()),
        // When collapsed, show the person outline icon.
        if (isCollapsed)
          IconButton(
            icon: Icon(Icons.person_outline,
                color: Theme.of(context).primaryColor),
            onPressed: () {},
            padding: const EdgeInsets.all(8.0),
          ),
      ],
    );
  }
}

/// The search bar widget with an icon and a text field.
class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12.0),
      child: const SizedBox(
        height: kToolbarHeight,
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Icon(Icons.search),
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  // hintStyle: Theme.of(context).textTheme.subtitle1,
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  isDense: true,
                ),
                // style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
