import 'package:flutter/material.dart';

/// A stateful widget to handle expandable sections with a title and content
class ExpandableSection extends StatefulWidget {
  final String title;
  final String content;

  const ExpandableSection({
    Key? key, 
    required this.title, 
    required this.content
  }) : super(key: key);

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The expandable button
        InkWell(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 205, 204, 204),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey[700],
                ),
              ],
            ),
          ),
        ),

        // The expandable content
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 8),
            child: Text(
              widget.content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
      ],
    );
  }
}
