import 'package:flutter/material.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/payment/utils/note_content.dart';

class Note extends StatefulWidget {
  final String title;
  final String description;
  final Color iconBackgroundColor;
  final Widget icon;
  final VoidCallback? onCameraTap;

  const Note({
    Key? key,
    required this.title,
    required this.description,
    required this.iconBackgroundColor,
    required this.icon,
    this.onCameraTap,
  }) : super(key: key);

  @override
  State<Note> createState() => _NoteState();
}

class _NoteState extends State<Note> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: note(
              context,
              isExpanded,
              widget.title,
              widget.description,
              widget.icon,
              widget.iconBackgroundColor,
            ),
          ),
          // Expanded content
          if (isExpanded)
            Padding(
              padding:
                  const EdgeInsets.only(top: 8, left: 48, right: 8, bottom: 0),
              child: Text(
                widget.description,
              ),
            ),
        ],
      ),
    );
  }
}
