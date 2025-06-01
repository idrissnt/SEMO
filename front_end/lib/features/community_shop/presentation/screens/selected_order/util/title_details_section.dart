import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/widgets/utils/address_copy.dart';

/// A reusable settings tile widget for profile settings
class TileDetailsSection extends StatefulWidget {
  final Widget icon;
  final Color iconContainerColor;
  final String title;
  final String subtitle;
  final List<Map<String, String>> content;
  final Widget? tag;

  const TileDetailsSection({
    Key? key,
    required this.icon,
    required this.iconContainerColor,
    required this.title,
    required this.subtitle,
    required this.content,
    this.tag,
  }) : super(key: key);

  @override
  State<TileDetailsSection> createState() => _TileDetailsSectionState();
}

class _TileDetailsSectionState extends State<TileDetailsSection> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Leading icon
                Container(
                  padding: const EdgeInsets.all(6),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.iconContainerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: widget.icon,
                ),
                const SizedBox(width: 16),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryColor,
                            ),
                          ),
                          const Spacer(),
                          if (widget.tag != null) widget.tag!,
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        // The expandable content
        if (isExpanded)
          Padding(
            padding:
                const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 8),
            child: Column(
              children: [
                for (var item in widget.content)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    child: Row(
                      children: [
                        Text(
                          '${item['label']} : ',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (!(item['label']
                                ?.toLowerCase()
                                .contains('adresse') ??
                            false))
                          Expanded(
                            child: Text(
                              item['value']!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        if (item['label']?.toLowerCase().contains('adresse') ??
                            false)
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item['value']!,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 20),
                                  tooltip: 'Copier l\'adresse',
                                  onPressed: () => copyAddressToClipboard(
                                      context, item['value']!),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 4),
              ],
            ),
          ),
      ],
    );
  }
}
