import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection_container.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/bloc/home_store/home_store_bloc.dart';
import '../presentation/bloc/user_address/user_address_bloc.dart';
import '../../mission/mission_screen.dart';
import '../../earn/earn_screen.dart';
import '../../message/message_screen.dart';
import '../../semo_ai/semo_ai_screen.dart';
import '../../../core/presentation/navigation/routes_constants/route_constants.dart';

ShellRoute getHomeRoute() {
  return ShellRoute(
    builder: (context, state, child) {
      // Wrap the shell with MultiBlocProvider to provide all necessary BLoCs
      return MultiBlocProvider(
        providers: [
          BlocProvider<HomeStoreBloc>(
            create: (context) {
              final bloc = sl<HomeStoreBloc>();
              // Don't trigger events here - HomeScreen will do that in initState
              return bloc;
            },
          ),
          BlocProvider<HomeUserAddressBloc>(
            create: (context) => sl<HomeUserAddressBloc>(),
          ),
        ],
        child: _buildShell(context, state, child),
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

// Extracted shell building logic to a separate method
Widget _buildShell(BuildContext context, GoRouterState state, Widget child) {
  int initialIndex = 0;
  final location = state.uri.path;

  if (location.startsWith(AppRoutes.mission)) {
    initialIndex = 1;
  } else if (location.startsWith(AppRoutes.earn)) {
    initialIndex = 2;
  } else if (location.startsWith(AppRoutes.message)) {
    initialIndex = 3;
  } else if (location.startsWith(AppRoutes.semoAi)) {
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
            context.go(AppRoutes.home);
            break;
          case 1:
            context.go(AppRoutes.mission);
            break;
          case 2:
            context.go(AppRoutes.earn);
            break;
          case 3:
            context.go(AppRoutes.message);
            break;
          case 4:
            context.go(AppRoutes.semoAi);
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
}
