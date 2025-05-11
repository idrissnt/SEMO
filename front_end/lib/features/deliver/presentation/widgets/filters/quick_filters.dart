import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';

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
  
  // Constants for filter keys
  static const String kAllMarkets = 'all_markets';
  static const String kOneMarket = 'one_market';
  static const String kUrgent = 'urgent';
  static const String kScheduled = 'scheduled';
  static const String kDistance = 'distance';
  static const String kHighReward = 'high_reward';

  @override
  void initState() {
    super.initState();
    // Initialize filter values
    _filterValues = Map<String, dynamic>.from(widget.initialFilters);
    
    // Auto-select all markets if enabled and not already set
    if (widget.autoSelectAllMarkets && !_filterValues.containsKey(kAllMarkets)) {
      _filterValues[kAllMarkets] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _buildSimpleFilterChip(
              kAllMarkets,
              'Tous les magasins',
              Icons.store,
              _filterValues[kAllMarkets] == true,
              onSelected: (selected) {
                _updateFilter(kAllMarkets, selected);
                // Deselect one market if all markets is selected
                if (selected && _filterValues.containsKey(kOneMarket)) {
                  _updateFilter(kOneMarket, null);
                }
              },
            ),
            const SizedBox(width: 8),
            _buildExpandableFilterChip(
              kOneMarket,
              'Un magasin',
              Icons.storefront,
              _filterValues.containsKey(kOneMarket),
              onSelected: (selected) {
                if (selected) {
                  _showStoreSelector(context);
                } else {
                  _updateFilter(kOneMarket, null);
                }
                // Deselect all markets if one market is selected
                if (selected && _filterValues[kAllMarkets] == true) {
                  _updateFilter(kAllMarkets, false);
                }
              },
            ),
            const SizedBox(width: 8),
            _buildSimpleFilterChip(
              kUrgent,
              'Urgent',
              Icons.timer,
              _filterValues[kUrgent] == true,
              onSelected: (selected) => _updateFilter(kUrgent, selected),
            ),
            const SizedBox(width: 8),
            _buildExpandableFilterChip(
              kScheduled,
              'Programmé',
              Icons.calendar_today,
              _filterValues.containsKey(kScheduled),
              onSelected: (selected) {
                if (selected) {
                  _showDateTimePicker(context);
                } else {
                  _updateFilter(kScheduled, null);
                }
              },
            ),
            const SizedBox(width: 8),
            _buildExpandableFilterChip(
              kDistance,
              'Distance',
              Icons.place,
              _filterValues.containsKey(kDistance),
              onSelected: (selected) {
                if (selected) {
                  _showDistanceSelector(context);
                } else {
                  _updateFilter(kDistance, null);
                }
              },
            ),
            const SizedBox(width: 8),
            _buildSimpleFilterChip(
              kHighReward,
              'Récompense élevée',
              Icons.star,
              _filterValues[kHighReward] == true,
              onSelected: (selected) => _updateFilter(kHighReward, selected),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a simple filter chip that can be toggled on/off
  Widget _buildSimpleFilterChip(String key, String label, IconData icon, bool selected, {required Function(bool) onSelected}) {
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
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.primary),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
  
  /// Build a filter chip that expands to show more options
  Widget _buildExpandableFilterChip(String key, String label, IconData icon, bool selected, {required Function(bool) onSelected}) {
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
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.primary),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
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
  void _showStoreSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir un magasin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStoreOption('Carrefour', 'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/for-cart/carrefoures-log-for-cart.jpeg'),
            _buildStoreOption('Lidl', 'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/logo/Lidl-logo-home.png'),
            _buildStoreOption('E.Leclerc', 'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/for-cart/E-Leclerc-logo-for-cart.png'),
          ],
        ),
      ),
    );
  }
  
  /// Build a store option for the selector
  Widget _buildStoreOption(String name, String logoUrl) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          logoUrl,
          width: 24,
          height: 24,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(name),
      onTap: () {
        Navigator.of(context).pop();
        _updateFilter(kOneMarket, name);
      },
    );
  }
  
  /// Show date/time picker dialog
  void _showDateTimePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir une date'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.today),
              title: const Text("Aujourd'hui"),
              onTap: () {
                Navigator.of(context).pop();
                _updateFilter(kScheduled, "Aujourd'hui");
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Demain'),
              onTap: () {
                Navigator.of(context).pop();
                _updateFilter(kScheduled, 'Demain');
              },
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Cette semaine'),
              onTap: () {
                Navigator.of(context).pop();
                _updateFilter(kScheduled, 'Cette semaine');
              },
            ),
          ],
        ),
      ),
    );
  }
  
  /// Show distance selector dialog
  void _showDistanceSelector(BuildContext context) {
    double distance = _filterValues[kDistance] ?? 1.0;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Distance maximale'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${distance.toStringAsFixed(1)} km', 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Slider(
                value: distance,
                min: 0.5,
                max: 5.0,
                divisions: 9,
                label: '${distance.toStringAsFixed(1)} km',
                onChanged: (value) {
                  setDialogState(() {
                    distance = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateFilter(kDistance, distance);
              },
              child: const Text('Confirmer'),
            ),
          ],
        ),
      ),
    );
  }
}
