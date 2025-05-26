import 'package:flutter/material.dart';
import 'package:semo/features/community_shop/presentation/widgets/filters/components/filter_constants.dart';

/// Dialog components for filter selections

/// Show store selector dialog
class StoreSelector extends StatelessWidget {
  final Function(Map<String, String>) onStoreSelected;

  const StoreSelector({
    Key? key,
    required this.onStoreSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choisir un magasin'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: FilterConstants.stores
            .map((store) =>
                _buildStoreOption(context, store['name']!, store['logoUrl']!))
            .toList(),
      ),
    );
  }

  /// Build a store option for the selector
  Widget _buildStoreOption(BuildContext context, String name, String logoUrl) {
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
        onStoreSelected({'name': name, 'logoUrl': logoUrl});
      },
    );
  }
}

/// Show date/time picker dialog
class DateTimePicker extends StatelessWidget {
  final Function(String) onDateSelected;

  const DateTimePicker({
    Key? key,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choisir une date'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var option in FilterConstants.scheduleOptions)
            ListTile(
              leading: Icon(_getIconData(option['icon'])),
              title: Text(option['label']),
              onTap: () {
                Navigator.of(context).pop();
                onDateSelected(option['label']);
              },
            ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'today':
        return Icons.today;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'date_range':
        return Icons.date_range;
      default:
        return Icons.calendar_today;
    }
  }
}

/// Show distance selector dialog
class DistanceSelector extends StatefulWidget {
  final Function(double) onDistanceSelected;
  final double initialDistance;

  const DistanceSelector({
    Key? key,
    required this.onDistanceSelected,
    this.initialDistance = FilterConstants.defaultDistance,
  }) : super(key: key);

  @override
  State<DistanceSelector> createState() => _DistanceSelectorState();
}

class _DistanceSelectorState extends State<DistanceSelector> {
  late double _distance;

  @override
  void initState() {
    super.initState();
    _distance = widget.initialDistance;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Distance maximale'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_distance.toStringAsFixed(1)} km',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Slider(
            value: _distance,
            min: FilterConstants.minDistance,
            max: FilterConstants.maxDistance,
            divisions: FilterConstants.distanceDivisions,
            label: '${_distance.toStringAsFixed(1)} km',
            onChanged: (value) {
              setState(() {
                _distance = value;
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
            widget.onDistanceSelected(_distance);
          },
          child: const Text('Confirmer'),
        ),
      ],
    );
  }
}
