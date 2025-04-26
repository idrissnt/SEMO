import 'package:flutter/material.dart';

/// Global keys and other app-wide constants
class AppGlobals {
  /// Global key for the ScaffoldMessenger
  /// This allows showing SnackBars from anywhere in the app
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
}
