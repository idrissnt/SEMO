import 'package:flutter/material.dart';
import 'package:semo/core/config/app_config.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';

/// A widget that displays a toggle switch for enabling/disabling offline mode
class OfflineModeToggle extends StatefulWidget {
  const OfflineModeToggle({Key? key}) : super(key: key);

  @override
  State<OfflineModeToggle> createState() => _OfflineModeToggleState();
}

class _OfflineModeToggleState extends State<OfflineModeToggle> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Mode hors-ligne',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: AppConfig.useOfflineMode,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                AppConfig.useOfflineMode = value;
              });
              
              // Show a snackbar to indicate the mode change
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value
                        ? 'Mode hors-ligne activé. Redémarrez l\'app pour appliquer.'
                        : 'Mode en ligne activé. Redémarrez l\'app pour appliquer.',
                  ),
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'OK',
                    onPressed: () {},
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
