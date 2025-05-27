import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';

/// A section widget for grouping related settings
class SettingsSection extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final Widget? tag;
  final List<Widget> children;

  const SettingsSection({
    Key? key,
    required this.title,
    this.titleColor,
    this.tag,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor ?? AppColors.primary,
                ),
              ),
              const Spacer(),
              if (tag != null) tag!,
            ],
          ),
        ),
        // Section content
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: _buildSectionItems(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSectionItems() {
    final List<Widget> sectionItems = [];

    for (int i = 0; i < children.length; i++) {
      sectionItems.add(children[i]);

      // Add divider between items, but not after the last item
      if (i < children.length - 1) {
        sectionItems.add(const Divider(
          height: 1,
          thickness: 1,
          indent: 16,
          endIndent: 16,
          color: Color(0xFFEEEEEE),
        ));
      }
    }

    return sectionItems;
  }
}
