import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/widgets/buttons/back_button.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moyens de paiement'),
        leading: IconButton(
          icon: buildIconButton(Icons.arrow_back, Colors.black, Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(
        child: Text('Moyens de paiement'),
      ),
    );
  }
}
