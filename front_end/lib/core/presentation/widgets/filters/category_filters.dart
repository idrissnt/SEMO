import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';

/// Widget that displays Category filters at the top of the screen
class TopFilters extends StatelessWidget {
  /// The list of filters to display
  final List<String> filters;

  /// The currently selected filter index
  final int selectedIndex;

  /// Callback when a filter is tapped
  final Function(int index) onFilterTap;

  /// Scroll controller for the filters
  final ScrollController scrollController;

  /// Creates a new Category filters widget
  const TopFilters({
    Key? key,
    required this.filters,
    required this.selectedIndex,
    required this.onFilterTap,
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
          // Category filters
          Expanded(
            child: SizedBox(
              height: buttonHeight,
              child: ListView.builder(
                shrinkWrap: true,
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 8, right: 8),
                itemCount: filters.length,
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final isSelected = index == selectedIndex;

                  return GestureDetector(
                    onTap: () => onFilterTap(index),
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
                            filter,
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
