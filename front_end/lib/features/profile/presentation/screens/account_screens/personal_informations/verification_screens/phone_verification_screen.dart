import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/profile/presentation/screens/account_screens/utils/button.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({Key? key}) : super(key: key);

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  bool _isSubmitting = false;
  bool _codeSent = false;
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  @override
  void dispose() {
    _phoneController.dispose();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _sendVerificationCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call to send verification code
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSubmitting = false;
      _codeSent = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code de vérification envoyé par SMS')),
      );
    }
  }

  Future<void> _verifyCode() async {
    // Check if all code fields are filled
    String code = _codeControllers.map((controller) => controller.text).join();

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer le code complet')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call to verify code
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Numéro de téléphone vérifié avec succès')),
      );
      context.pop(true); // Return true to indicate successful verification
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Vérification téléphone'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child:
                  !_codeSent ? _buildPhoneForm() : _buildVerificationCodeForm(),
            ),
    );
  }

  Widget _buildPhoneForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vérifiez votre numéro de téléphone',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nous vous enverrons un code de vérification par SMS',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Numéro de téléphone',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
              hintText: '+33 6 12 34 56 78',
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre numéro de téléphone';
              }
              if (value.length < 8) {
                return 'Veuillez entrer un numéro de téléphone valide';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          Center(
            child: createVerificationButton(
              context: context,
              onPressed: _sendVerificationCode,
              text: 'Envoyer le code',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCodeForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Entrez le code de vérification',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Nous avons envoyé un code au ${_phoneController.text}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            6,
            (index) => SizedBox(
              width: 45,
              height: 55,
              child: TextField(
                controller: _codeControllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                decoration: const InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    _focusNodes[index + 1].requestFocus();
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: createVerificationButton(
            context: context,
            onPressed: _verifyCode,
            text: 'Vérifier',
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _sendVerificationCode,
            child: const Text('Renvoyer le code'),
          ),
        ),
      ],
    );
  }
}
