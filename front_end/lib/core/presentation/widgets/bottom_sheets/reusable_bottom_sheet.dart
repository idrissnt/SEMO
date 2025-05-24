import 'package:flutter/material.dart';

/// Shows a reusable bottom sheet with customizable content
///
/// Features:
/// - Snap behavior (snaps to full or dismisses)
/// - Draggable
/// - Customizable content
/// - Proper scroll behavior
void showReusableBottomSheet({
  required BuildContext context,
  required Widget Function(ScrollController scrollController) contentBuilder,
  VoidCallback? onClose,
  double initialSize = 0.98,
  double minSize = 0.01,
  double maxSize = 0.98,
  Duration snapAnimationDuration = const Duration(milliseconds: 100),
  List<double> snapSizes = const [0.01, 0.98],
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRootNavigator = true,
  bool useSafeArea = true,
}) {
  // Show the custom bottom sheet
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: useRootNavigator,
    useSafeArea: useSafeArea,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: initialSize,
      minChildSize: minSize,
      maxChildSize: maxSize,
      snapAnimationDuration: snapAnimationDuration,
      snap: true,
      snapSizes: snapSizes,
      controller: DraggableScrollableController(),
      expand: false,
      builder: (context, scrollController) => contentBuilder(scrollController),
    ),
  );
}
