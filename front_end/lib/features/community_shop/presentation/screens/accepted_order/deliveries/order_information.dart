import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/widgets/filters/category_filters.dart';
import 'package:semo/core/presentation/widgets/utils/address_copy.dart';

class DeliveryOrderInformationScreen extends StatefulWidget {
  const DeliveryOrderInformationScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryOrderInformationScreen> createState() =>
      _DeliveryOrderInformationScreenState();
}

class _DeliveryOrderInformationScreenState
    extends State<DeliveryOrderInformationScreen> {
  int _selectedCategoryIndex = 0;
  final ScrollController _filtersScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2 voisons à livrer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          TopFilters(
            filters: const ['Voison 1', 'Voison 2'],
            selectedIndex: _selectedCategoryIndex,
            scrollController: _filtersScrollController,
            onFilterTap: (index) {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
          ),
          Expanded(
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Adresse',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  tooltip: 'Copier l\'adresse',
                  onPressed: () => copyAddressToClipboard(context, 'adresse'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
