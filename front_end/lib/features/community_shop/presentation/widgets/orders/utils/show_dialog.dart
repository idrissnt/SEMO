import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/features/community_shop/presentation/screens/selected_order/util/start_button.dart';
import 'package:semo/features/community_shop/presentation/services/delivery_time_service.dart';
import 'package:semo/features/community_shop/presentation/services/order_interaction_service.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';

/// Shows a dialog with options to start or book an order
Widget showOrderActionBottomSheet({
  required BuildContext context,
  required CommunityOrder order,
}) {
  return Padding(
    padding: EdgeInsets.only(
      left: 20.0,
      right: 20.0,
      top: 20.0,
      bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress indicator (if part of a flow)
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              height: 4,
              width: 60,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          // Title
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🛒 Que pouvez-vous faire ?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Delivery time info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🕒 ', style: TextStyle(fontSize: 20)),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                    children: [
                      TextSpan(
                        text:
                            'Peu importe le créneau de livraison, \nSi vous allez au magasin maintenant, vous pouvez accepter cette commande en cliquant sur ',
                      ),
                      TextSpan(
                        text: '"Commencer maintenant"',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' et faire vos courses en même temps.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Automatic message info
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('💬 ', style: TextStyle(fontSize: 20)),
              Expanded(
                child: Text(
                  'Nous enverrons ce message au client automatiquement :',
                  style: TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Customer message box
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              border: Border.all(color: const Color(0xFFD1D6E0)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('👋 ', style: TextStyle(fontSize: 20)),
                Expanded(
                  child: Text(
                    'Salut [prénom], je viens de récupérer votre commande et je suis actuellement au magasin. Merci de garder votre téléphone à portée de main pour faciliter l’échange !',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('💡 ', style: TextStyle(fontSize: 20)),
              Expanded(
                child: Text(
                  'Après ce message, vous pourrez discuter avec le client si besoin.',
                  style: TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Buttons
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Start order button
              SizedBox(
                // width: 190,
                height: 50,
                child: CommunityOrderButton(
                  textSize: AppFontSize.large,
                  textColor: AppColors.textSecondaryColor,
                  backgroundColor: AppColors.primary,
                  showIcon: false,
                  text: 'Commencer maintenant',
                  onPressed: () {
                    OrderInteractionService().handleOrderStart(
                      context,
                      [order],
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Book order button
              SizedBox(
                // width: 170,
                height: 50,
                child: CommunityOrderButton(
                  textColor: AppColors.textPrimaryColor,
                  backgroundColor: AppColors.secondary,
                  textSize: AppFontSize.large,
                  text: 'Programmer',
                  showIcon: true,
                  onPressed: () {
                    DeliveryTimeService().showDeliveryTimePicker(
                      context: context,
                      order: order,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
