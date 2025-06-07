import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/profile/presentation/screens/account_screens/utils/button.dart';

class NameVerificationScreen extends StatefulWidget {
  const NameVerificationScreen({Key? key}) : super(key: key);

  @override
  State<NameVerificationScreen> createState() => _NameVerificationScreenState();
}

class _NameVerificationScreenState extends State<NameVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _submitName() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, you would send this data to your backend
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;

    // Log the data (in a real app, you would send this to your backend)
    debugPrint('Name verification: $firstName $lastName');

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nom enregistré avec succès')),
      );
      context.pop(true); // Return true to indicate successful verification
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nom complet'),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Entrez votre nom complet',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Votre nom sera utilisé pour vérifier votre identité',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'Prénom',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: createVerificationButton(
                        context: context,
                        onPressed: _submitName,
                        text: 'Enregistrer',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
