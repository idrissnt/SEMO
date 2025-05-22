import 'package:flutter/cupertino.dart';
import 'package:semo/core/presentation/navigation/bottom_navigation/tab_registration/tab_info.dart';
import 'package:semo/core/presentation/navigation/bottom_navigation/tab_registration/tab_registry.dart';
import 'package:semo/features/message/presentation/constants/constant.dart';
import 'package:semo/features/message/routes/const.dart';

/// Registers the message tab in the tab registry
void registerMessageTab() {
  TabRegistry.registerTab(
    const TabInfo(
      route: MessageRoutesConstants.message,
      label: MessageConstants.message,
      icon: CupertinoIcons.chat_bubble_text,
      activeIcon: CupertinoIcons.chat_bubble_text_fill,
    ),
  );
}
