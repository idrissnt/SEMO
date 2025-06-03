import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinCodeWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onCompleted;

  const PinCodeWidget({
    Key? key,
    required this.controller,
    required this.onCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Code de livraison',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Demandez le code à 4 chiffres pour confirmer',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: PinCodeTextField(
              appContext: context,
              length: 4,
              obscureText: false,
              animationType: AnimationType.none,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.underline,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 30,
                fieldWidth: 60,
                activeFillColor: Colors.transparent,
                inactiveFillColor: Colors.transparent,
                selectedFillColor: Colors.transparent,
                activeColor: Colors.black,
                inactiveColor: Colors.grey.shade300,
                selectedColor: Colors.black,
              ),
              cursorColor: Colors.black,
              backgroundColor: Colors.transparent,
              enableActiveFill: true,
              onCompleted: onCompleted,
              controller: controller,
              onChanged: (value) {},
              beforeTextPaste: (text) {
                return true;
              },
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }
}
