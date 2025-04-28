import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget that dismisses the keyboard when tapped or when the app is rebuilt
/// This helps ensure the keyboard is properly dismissed during navigation and hot reloads
class KeyboardDismisser extends StatefulWidget {
  final Widget child;
  
  const KeyboardDismisser({
    Key? key,
    required this.child,
  }) : super(key: key);
  
  @override
  State<KeyboardDismisser> createState() => _KeyboardDismisserState();
}

class _KeyboardDismisserState extends State<KeyboardDismisser> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Dismiss keyboard on initial build
    _dismissKeyboard();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Dismiss keyboard when app is resumed
    if (state == AppLifecycleState.resumed) {
      _dismissKeyboard();
    }
  }
  
  // Force keyboard to close using system channel
  void _dismissKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    FocusManager.instance.primaryFocus?.unfocus();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismissKeyboard,
      // This ensures taps outside of text fields will dismiss the keyboard
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
