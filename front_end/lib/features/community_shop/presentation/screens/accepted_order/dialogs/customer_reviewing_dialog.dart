import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/widgets/buttons/button_factory.dart';

/// Response enum for customer reviewing dialog
enum CustomerReviewResponse {
  itemsExchanged,
  refundRequested,
  waitingForResponse,
  continueToPayment
}

/// Shows a dialog when there are items in the customer reviewing tab
/// and the user tries to continue from an empty in-progress tab
Future<CustomerReviewResponse?> showCustomerReviewingDialog({
  required BuildContext context,
  required String customerName,
  required int itemsCount,
}) {
  return showDialog<CustomerReviewResponse>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 64,
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Article${itemsCount > 1 ? 's' : ''} en attente de validation',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Message
              Text(
                'Il y a $itemsCount article${itemsCount > 1 ? 's' : ''} dans la section "Le client examine" qui ${itemsCount > 1 ? 'sont' : 'est'} en attente de validation.',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Question
              const Text(
                'Le client vous a répondu ?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Yes/No options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Oui button
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ButtonFactory.createPrimaryButton(
                        context: context,
                        onPressed: () {
                          _showYesOptions(context, customerName, itemsCount);
                        },
                        text: 'Oui',
                      ),
                    ),
                  ),

                  // Non button
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ButtonFactory.createSecondaryButton(
                        context: context,
                        onPressed: () {
                          _showNoOptions(context, customerName);
                        },
                        text: 'Non',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Cancel button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Show options when the customer has responded (Yes)
void _showYesOptions(
    BuildContext context, String customerName, int itemsCount) {
  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Que souhaitez-vous faire ?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Option 1: Items exchanged
            _buildOptionWithButton(
              context: context,
              text:
                  'Continuer, L${itemsCount > 1 ? 'es' : "'"} article${itemsCount > 1 ? 's' : ''} indisponible${itemsCount > 1 ? 's' : ''} ${itemsCount > 1 ? 'ont été' : 'a été'} remplacé${itemsCount > 1 ? 's' : ''}',
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .pop(CustomerReviewResponse.itemsExchanged);
              },
            ),
            const SizedBox(height: 16),

            // Option 2: Refund requested
            _buildOptionWithButton(
              context: context,
              text: 'Continuer, $customerName veut un remboursement',
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .pop(CustomerReviewResponse.refundRequested);
              },
            ),
            const SizedBox(height: 24),

            // Cancel button
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Show options when the customer has not responded (No)
void _showNoOptions(BuildContext context, String customerName) {
  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Que souhaitez-vous faire ?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Option 1: Wait for response
            _buildOptionWithButton(
              context: context,
              text: 'Attendre la réponse de $customerName',
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .pop(CustomerReviewResponse.waitingForResponse);
              },
            ),
            const SizedBox(height: 16),

            // Option 2: Continue to payment
            _buildOptionWithButton(
              context: context,
              text: 'Continuer au paiement, $customerName sera remboursé(e)',
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .pop(CustomerReviewResponse.continueToPayment);
              },
            ),
            const SizedBox(height: 24),

            // Cancel button
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Helper to build an option with an action button
Widget _buildOptionWithButton({
  required BuildContext context,
  required String text,
  required VoidCallback onPressed,
}) {
  return Row(
    children: [
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      const SizedBox(width: 16),
      ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Choisir'),
      ),
    ],
  );
}
