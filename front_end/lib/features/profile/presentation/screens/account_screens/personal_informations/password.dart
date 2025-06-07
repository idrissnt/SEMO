import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/widgets/buttons/back_button.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({Key? key}) : super(key: key);

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe'),
        leading: IconButton(
          icon: buildIconButton(Icons.arrow_back, Colors.black, Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(
        child: Text('Password'),
      ),
    );
  }
}
