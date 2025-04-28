import 'dart:async';
import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/theme_services/app_dimensions.dart';

/// A popup notification that slides in from the top of the screen
/// and automatically dismisses after a specified duration
class PopupNotification extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Duration duration;
  final VoidCallback? onDismiss;

  const PopupNotification({
    Key? key,
    required this.message,
    this.icon = Icons.info_outline,
    this.backgroundColor = Colors.red,
    this.textColor = Colors.white,
    this.duration = const Duration(seconds: 4),
    this.onDismiss,
  }) : super(key: key);

  /// Shows a popup notification at the top of the screen
  static Future<void> show({
    required BuildContext context,
    required String message,
    IconData icon = Icons.error_outline,
    Color backgroundColor = Colors.red,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 30),
    VoidCallback? onDismiss,
  }) async {
    // Remove any existing notifications
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Create a completer to handle early dismissal
    final completer = Completer<void>();

    // Store the overlay entry in a variable that can be accessed by the close button
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _TopPositionedPopup(
        notification: PopupNotification(
          message: message,
          icon: icon,
          backgroundColor: backgroundColor,
          textColor: textColor,
          duration: duration,
          onDismiss: () {
            // When dismissed, remove the overlay entry and complete
            if (!completer.isCompleted) {
              overlayEntry.remove();
              completer.complete();
              if (onDismiss != null) {
                onDismiss();
              }
            }
          },
        ),
      ),
    );

    final overlay = Overlay.of(context);
    overlay.insert(overlayEntry);

    // Set up auto-dismiss after duration
    Future.delayed(duration).then((_) {
      if (!completer.isCompleted) {
        overlayEntry.remove();
        completer.complete();
        if (onDismiss != null) {
          onDismiss();
        }
      }
    });

    // Wait for completion (either by timeout or manual dismissal)
    return completer.future;
  }

  @override
  State<PopupNotification> createState() => _PopupNotificationState();
}

/// A wrapper widget that positions the popup at the top of the screen
class _TopPositionedPopup extends StatelessWidget {
  final PopupNotification notification;

  const _TopPositionedPopup({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: notification,
    );
  }
}

class _PopupNotificationState extends State<PopupNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    // Start dismiss animation after duration - animation time
    Future.delayed(widget.duration - const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(
              horizontal: AppDimensionsWidth.medium,
              vertical: AppDimensionsHeight.small,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensionsWidth.medium,
              vertical: AppDimensionsHeight.small,
            ),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  color: widget.textColor,
                  size: AppIconSize.large,
                ),
                SizedBox(width: AppDimensionsWidth.small),
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: AppFontSize.medium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: widget.textColor,
                    size: AppIconSize.medium,
                  ),
                  onPressed: () {
                    // Reverse animation and then call onDismiss to remove the overlay
                    _controller.reverse().then((_) {
                      if (widget.onDismiss != null) {
                        widget.onDismiss!();
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
