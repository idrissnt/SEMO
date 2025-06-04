import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';

/// Widget that displays Category filters at the top of the screen
class ProductControlTabs extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final Function(int index) onCategoryTap;
  final List<int>? itemCounts; // Add counts for each category

  const ProductControlTabs({
    Key? key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategoryTap,
    this.itemCounts, // Optional parameter for item counts
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define consistent style values
    const double buttonHeight = 36;
    const double borderRadius = 12;

    return SizedBox(
      height: buttonHeight + 8, // Height + vertical margins
      child: Row(
        children: [
          // Category filters with equal width distribution
          Expanded(
            child: Row(
              children: List.generate(
                categories.length,
                (index) {
                  final category = categories[index];
                  final isSelected = index == selectedIndex;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onCategoryTap(index),
                      child: Container(
                        height: buttonHeight,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? AppColors.primary : Colors.grey[200],
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              category,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (itemCounts != null &&
                                index < itemCounts!.length)
                              Container(
                                margin: const EdgeInsets.only(left: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.3)
                                      : AppColors.primary
                                          .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${itemCounts![index]}',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
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
