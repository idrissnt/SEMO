import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';

class FirstOrderShopperMessageScreen extends StatelessWidget {
  final List<CommunityOrder> orders;
  const FirstOrderShopperMessageScreen({Key? key, required this.orders})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Shopper Message'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Card(
            elevation: 8,
            margin: const EdgeInsets.all(20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.amber.shade50,
            child: const Text('First Shopper Message'),
          ),
          const Expanded(
            child: Text(
              'Utilisez votre carte SEMO pour effectuer le paiement',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
