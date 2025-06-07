import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/widgets/buttons/back_button.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({Key? key}) : super(key: key);

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adresses'),
        leading: IconButton(
          icon: buildIconButton(Icons.arrow_back, Colors.black, Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(
        child: Text('Adresses'),
      ),
    );
  }
}
