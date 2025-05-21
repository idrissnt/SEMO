import 'package:flutter/material.dart';
import 'package:semo/core/presentation/navigation/bottom_navigation/tab_registration/tab_info.dart';
import 'package:semo/core/presentation/navigation/bottom_navigation/tab_registration/tab_registry.dart';
import 'package:semo/features/semo_ai/semo_ai_screen.dart';
import 'const.dart';

/// Registers the SEMO AI tab in the tab registry
void registerHistoriesTab() {
  TabRegistry.registerTab(
    const TabInfo(
      route: HistoriesRoutes.histories,
      label: 'Histories',
      icon: Icons.psychology_outlined,
      activeIcon: Icons.psychology,
      screen: SemoAIScreen(),
    ),
  );
}
