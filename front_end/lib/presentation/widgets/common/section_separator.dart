import 'package:flutter/material.dart';
import '../../../core/extensions/theme_extension.dart';

class SectionSeparator extends StatelessWidget {
  const SectionSeparator({
    Key? key,
    this.height,
    this.color,
  }) : super(key: key);

  final double? height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? context.xxs,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color ?? context.lineColor,
        border: Border.symmetric(
          horizontal: BorderSide(
            color: context.lineColor,
            width: context.xxs,
          ),
        ),
      ),
    );
  }
}
