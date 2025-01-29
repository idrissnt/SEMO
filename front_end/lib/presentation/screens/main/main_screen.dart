// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

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
                      builder: (BuildContext context, BoxConstraints constraints) {
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
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Container(
                          margin: EdgeInsets.all(16),
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Test Item ${index + 1}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'This is a test description for item ${index + 1} to demonstrate scrolling behavior',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: 20,
                    ),
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
