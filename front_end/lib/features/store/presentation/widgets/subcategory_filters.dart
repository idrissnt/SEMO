import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/store/domain/entities/categories/store_category.dart';

/// Widget that displays subcategory filters at the top of the screen
class SubcategoryFilters extends StatelessWidget {
  /// The list of subcategories
  final List<StoreSubcategory> subcategories;

  /// The currently selected subcategory index
  final int selectedIndex;

  /// Callback when a subcategory filter is tapped
  final Function(int index) onSubcategoryTap;

  /// Scroll controller for the filters
  final ScrollController scrollController;

  /// Creates a new subcategory filters widget
  const SubcategoryFilters({
    Key? key,
    required this.subcategories,
    required this.selectedIndex,
    required this.onSubcategoryTap,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define consistent style values
    const double buttonHeight = 36;
    const double horizontalPadding = 12;
    const double verticalPadding = 1;
    const double borderRadius = 12;
    const double rightMargin = 4;

    return SizedBox(
      height: buttonHeight + 8, // Height + vertical margins
      child: Row(
        children: [
          // Subcategory filters
          Expanded(
            child: SizedBox(
              height: buttonHeight,
              child: ListView.builder(
                shrinkWrap: true,
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 8, right: 8),
                itemCount: subcategories.length,
                itemBuilder: (context, index) {
                  final subcategory = subcategories[index];
                  final isSelected = index == selectedIndex;

                  return GestureDetector(
                    onTap: () => onSubcategoryTap(index),
                    child: Container(
                      height: buttonHeight,
                      margin: const EdgeInsets.only(right: rightMargin),
                      padding: const EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: verticalPadding,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.primary : Colors.grey[200],
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            subcategory.name,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
