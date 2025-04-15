import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Extension method to simplify navigation
extension GoRouterExtension on BuildContext {
  void pushRoute(String location) => go(location);
  void replaceRoute(String location) => replace(location);
}
