import 'package:flutter/material.dart';
import 'package:semo/features/deliver/presentation/widgets/filters/components/filter_chips.dart';
import 'package:semo/features/deliver/presentation/widgets/filters/components/filter_constants.dart';
import 'package:semo/features/deliver/presentation/widgets/filters/components/filter_dialogs.dart';

/// A widget that displays a horizontal list of filter chips for quick filtering
/// of community shopping orders.
class QuickFilters extends StatefulWidget {
  /// Callback when filters change
  final Function(Map<String, dynamic>) onFiltersChanged;

  /// Initial selected filters
  final Map<String, dynamic> initialFilters;

  /// Whether to automatically select "Tous les magasins" filter
  final bool autoSelectAllMarkets;

  const QuickFilters({
    Key? key,
    required this.onFiltersChanged,
    this.initialFilters = const {},
    this.autoSelectAllMarkets = true,
  }) : super(key: key);

  @override
  State<QuickFilters> createState() => _QuickFiltersState();
}

class _QuickFiltersState extends State<QuickFilters> {
  // Map to store filter selections with their values
  late Map<String, dynamic> _filterValues;

  @override
  void initState() {
    super.initState();
    // Initialize filter values
    _filterValues = Map<String, dynamic>.from(widget.initialFilters);

    // Auto-select all markets if enabled and not already set
    if (widget.autoSelectAllMarkets &&
        !_filterValues.containsKey(FilterConstants.kAllMarkets)) {
      _filterValues[FilterConstants.kAllMarkets] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            // All markets filter
            SimpleFilterChip(
              filterKey: FilterConstants.kAllMarkets,
              label: 'Tous les magasins',
              icon: Icons.store,
              selected: _filterValues[FilterConstants.kAllMarkets] == true,
              onSelected: (selected) {
                _updateFilter(FilterConstants.kAllMarkets, selected);
                // Deselect one market if all markets is selected
                if (selected && _filterValues.containsKey(FilterConstants.kOneMarket)) {
                  _updateFilter(FilterConstants.kOneMarket, null);
                }
              },
            ),
            const SizedBox(width: 8),
            
            // One market filter
            ExpandableFilterChip(
              filterKey: FilterConstants.kOneMarket,
              label: 'Un magasin',
              icon: Icons.storefront,
              selected: _filterValues.containsKey(FilterConstants.kOneMarket),
              filterValues: _filterValues,
              onSelected: (selected) {
                if (selected) {
                  _showStoreSelector();
                } else {
                  _updateFilter(FilterConstants.kOneMarket, null);
                }
                // Deselect all markets if one market is selected
                if (selected && _filterValues[FilterConstants.kAllMarkets] == true) {
                  _updateFilter(FilterConstants.kAllMarkets, false);
                }
              },
            ),
            const SizedBox(width: 8),
            
            // Urgent filter
            SimpleFilterChip(
              filterKey: FilterConstants.kUrgent,
              label: 'Urgent',
              icon: Icons.timer,
              selected: _filterValues[FilterConstants.kUrgent] == true,
              onSelected: (selected) => _updateFilter(FilterConstants.kUrgent, selected),
            ),
            const SizedBox(width: 8),
            
            // Scheduled filter
            ExpandableFilterChip(
              filterKey: FilterConstants.kScheduled,
              label: 'Programmé',
              icon: Icons.calendar_today,
              selected: _filterValues.containsKey(FilterConstants.kScheduled),
              filterValues: _filterValues,
              onSelected: (selected) {
                if (selected) {
                  _showDateTimePicker();
                } else {
                  _updateFilter(FilterConstants.kScheduled, null);
                }
              },
            ),
            const SizedBox(width: 8),
            
            // Distance filter
            ExpandableFilterChip(
              filterKey: FilterConstants.kDistance,
              label: 'Distance',
              icon: Icons.place,
              selected: _filterValues.containsKey(FilterConstants.kDistance),
              filterValues: _filterValues,
              onSelected: (selected) {
                if (selected) {
                  _showDistanceSelector();
                } else {
                  _updateFilter(FilterConstants.kDistance, null);
                }
              },
            ),
            const SizedBox(width: 8),
            
            // High reward filter
            SimpleFilterChip(
              filterKey: FilterConstants.kHighReward,
              label: 'Récompense élevée',
              icon: Icons.star,
              selected: _filterValues[FilterConstants.kHighReward] == true,
              onSelected: (selected) => _updateFilter(FilterConstants.kHighReward, selected),
            ),
          ],
        ),
      ),
    );
  }

  /// Update a filter and notify listeners
  void _updateFilter(String key, dynamic value) {
    setState(() {
      if (value == null) {
        _filterValues.remove(key);
      } else {
        _filterValues[key] = value;
      }
      widget.onFiltersChanged(Map<String, dynamic>.from(_filterValues));
    });
  }
  
  /// Show store selector dialog
  void _showStoreSelector() {
    showDialog(
      context: context,
      builder: (context) => StoreSelector(
        onStoreSelected: (storeData) {
          _updateFilter(FilterConstants.kOneMarket, storeData);
        },
      ),
    );
  }
  
  /// Show date/time picker dialog
  void _showDateTimePicker() {
    showDialog(
      context: context,
      builder: (context) => DateTimePicker(
        onDateSelected: (date) {
          _updateFilter(FilterConstants.kScheduled, date);
        },
      ),
    );
  }
  
  /// Show distance selector dialog
  void _showDistanceSelector() {
    double initialDistance = FilterConstants.defaultDistance;
    if (_filterValues.containsKey(FilterConstants.kDistance)) {
      initialDistance = _filterValues[FilterConstants.kDistance];
    }
    
    showDialog(
      context: context,
      builder: (context) => DistanceSelector(
        initialDistance: initialDistance,
        onDistanceSelected: (distance) {
          _updateFilter(FilterConstants.kDistance, distance);
        },
      ),
    );
  }
}
