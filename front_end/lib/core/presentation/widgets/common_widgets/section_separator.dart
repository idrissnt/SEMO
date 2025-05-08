import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';

class SectionSeparator extends StatelessWidget {
  const SectionSeparator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensionsHeight.xxSmall,
      width: double.infinity,
      color: AppColors.searchBarColor,
    );
  }
}
