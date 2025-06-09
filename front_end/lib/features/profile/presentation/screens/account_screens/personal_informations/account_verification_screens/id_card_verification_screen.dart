import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:semo/features/profile/presentation/screens/account_screens/utils/button.dart';

class IdCardVerificationScreen extends StatefulWidget {
  const IdCardVerificationScreen({Key? key}) : super(key: key);

  @override
  State<IdCardVerificationScreen> createState() =>
      _IdCardVerificationScreenState();
}

class _IdCardVerificationScreenState extends State<IdCardVerificationScreen> {
  File? _frontImage;
  File? _backImage;
  bool _isSubmitting = false;

  Future<void> _pickImage(bool isFront) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          if (isFront) {
            _frontImage = File(image.path);
          } else {
            _backImage = File(image.path);
          }
        });
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de la sélection de l\'image: $e')),
        );
      }
    }
  }

  Future<void> _submitVerification() async {
    if (_frontImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Veuillez télécharger le recto de votre pièce d\'identité')),
      );
      return;
    }

    if (_backImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Veuillez télécharger le verso de votre pièce d\'identité')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call to upload and verify ID card
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pièce d\'identité soumise avec succès')),
      );
      context.pop(true); // Return true to indicate successful verification
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pièce d\'identité'),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vérifiez votre identité',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Téléchargez une photo du recto et du verso de votre pièce d\'identité (Carte nationale d\'identité, passeport, titre de séjour)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Front of ID card
                  const Text(
                    'Recto de la pièce d\'identité',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildImageUploader(
                    image: _frontImage,
                    onTap: () => _pickImage(true),
                    hint: 'Télécharger le recto',
                  ),
                  const SizedBox(height: 24),

                  // Back of ID card
                  const Text(
                    'Verso de la pièce d\'identité',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildImageUploader(
                    image: _backImage,
                    onTap: () => _pickImage(false),
                    hint: 'Télécharger le verso',
                  ),

                  const SizedBox(height: 32),

                  // Submit button
                  Center(
                    child: createVerificationButton(
                      context: context,
                      onPressed: () => _submitVerification(),
                      text: 'Soumettre',
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Guidelines
                  _buildGuidelines(),
                ],
              ),
            ),
    );
  }

  Widget _buildImageUploader({
    required File? image,
    required VoidCallback onTap,
    required String hint,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  image,
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_photo_alternate,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hint,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildGuidelines() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conseils pour la photo:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text('• Assurez-vous que toutes les informations sont lisibles'),
          Text('• Évitez les reflets et les ombres'),
          Text('• Prenez la photo dans un endroit bien éclairé'),
          Text(
              '• Assurez-vous que la pièce d\'identité est entièrement visible'),
        ],
      ),
    );
  }
}
