import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../presentation/screens/home/home_screen.dart';
import '../../../presentation/screens/mission/mission_screen.dart';
import '../../../presentation/screens/earn/earn_screen.dart';
import '../../../presentation/screens/message/message_screen.dart';
import '../../../presentation/screens/semo_ai/semo_ai_screen.dart';

ShellRoute getMainShellRoute() {
  return ShellRoute(
    builder: (context, state, child) {
      int initialIndex = 0;
      final location = state.uri.path;

      if (location.startsWith('/mission')) {
        initialIndex = 1;
      } else if (location.startsWith('/earn')) {
        initialIndex = 2;
      } else if (location.startsWith('/message')) {
        initialIndex = 3;
      } else if (location.startsWith('/semo-ai')) {
        initialIndex = 4;
      }

      // Create all screens once to maintain their state
      final screens = [
        const HomeScreen(),
        const MissionScreen(),
        const EarnScreen(),
        const MessageScreen(),
        const SemoAIScreen(),
      ];

      return Scaffold(
        // Use IndexedStack instead of directly using child
        body: IndexedStack(
          index: initialIndex,
          children: screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: initialIndex,
          onTap: (index) {
            switch (index) {
              case 0:
                context.go('/homeScreen');
                break;
              case 1:
                context.go('/mission');
                break;
              case 2:
                context.go('/earn');
                break;
              case 3:
                context.go('/message');
                break;
              case 4:
                context.go('/semo-ai');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.note_add_outlined),
              activeIcon: Icon(Icons.note_add),
              label: 'Publier',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_people_outlined),
              activeIcon: Icon(Icons.emoji_people),
              label: 'Accomplir',
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
    },
    routes: [
      GoRoute(
        path: '/homeScreen',
        builder: (context, state) => const SizedBox(), // Empty placeholder
      ),
      GoRoute(
        path: '/mission',
        builder: (context, state) => const SizedBox(), // Empty placeholder
      ),
      GoRoute(
        path: '/earn',
        builder: (context, state) => const SizedBox(), // Empty placeholder
      ),
      GoRoute(
        path: '/message',
        builder: (context, state) => const SizedBox(), // Empty placeholder
      ),
      GoRoute(
        path: '/semo-ai',
        builder: (context, state) => const SizedBox(), // Empty placeholder
      ),
    ],
  );
}
