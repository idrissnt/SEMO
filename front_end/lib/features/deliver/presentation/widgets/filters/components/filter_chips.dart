import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/deliver/presentation/widgets/filters/components/filter_constants.dart';

/// Custom filter chips for the quick filters component

/// Build a simple filter chip that can be toggled on/off
class SimpleFilterChip extends StatelessWidget {
  final String filterKey;
  final String label;
  final IconData icon;
  final bool selected;
  final Function(bool) onSelected;

  const SimpleFilterChip({
    Key? key,
    required this.filterKey,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: selected ? Colors.white : AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.primary),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}

/// Build a filter chip that expands to show more options
class ExpandableFilterChip extends StatelessWidget {
  final String filterKey;
  final String label;
  final IconData icon;
  final bool selected;
  final Function(bool) onSelected;
  final Map<String, dynamic>? filterValues;

  const ExpandableFilterChip({
    Key? key,
    required this.filterKey,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
    this.filterValues,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For store selection, show the store logo if selected
    Widget leadingWidget;
    String displayLabel = label;
    
    if (filterKey == FilterConstants.kOneMarket && 
        selected && 
        filterValues != null && 
        filterValues!.containsKey(FilterConstants.kOneMarket)) {
      var storeData = filterValues![FilterConstants.kOneMarket];
      if (storeData is Map<String, dynamic> && 
          storeData.containsKey('name') && 
          storeData.containsKey('logoUrl')) {
        displayLabel = storeData['name'];
        leadingWidget = ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            storeData['logoUrl'],
            width: 16,
            height: 16,
            fit: BoxFit.cover,
          ),
        );
      } else {
        leadingWidget = Icon(
          icon,
          size: 16,
          color: selected ? Colors.white : AppColors.primary,
        );
      }
    } else {
      leadingWidget = Icon(
        icon,
        size: 16,
        color: selected ? Colors.white : AppColors.primary,
      );
    }
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leadingWidget,
          const SizedBox(width: 4),
          Text(
            displayLabel,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 2),
          Icon(
            Icons.arrow_drop_down,
            size: 16,
            color: selected ? Colors.white : AppColors.primary,
          ),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.primary),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}
