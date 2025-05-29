import 'package:flutter/material.dart';

/// Widget that displays an empty state when no orders match the filters
class EmptyOrdersState extends StatelessWidget {
  final Map<String, dynamic> filterValues;

  const EmptyOrdersState({
    Key? key,
    required this.filterValues,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune commande disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            filterValues.isEmpty
                ? 'Revenez plus tard pour aider vos voisins'
                : 'Essayez de modifier vos filtres',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
