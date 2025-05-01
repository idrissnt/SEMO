import 'package:semo/features/earn/routes/earn_tab_registration.dart';
import 'package:semo/features/home/routes/home_tab_registration.dart';
import 'package:semo/features/message/routes/message_tab_registration.dart';
import 'package:semo/features/mission/routes/mission_tab_registration.dart';
import 'package:semo/features/semo_ai/routes/semo_ai_tab_registration.dart';

/// Registers all tabs from all features
/// This should be called during app initialization
void registerAllTabs() {
  // Register tabs in the order they should appear
  registerHomeTab();
  registerMissionTab();
  registerEarnTab();
  registerMessageTab();
  registerSemoAiTab();
}
