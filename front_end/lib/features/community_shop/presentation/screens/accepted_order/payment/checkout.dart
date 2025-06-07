import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/payment/utils/note.dart';
import 'package:semo/features/community_shop/presentation/widgets/shared/button.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/payment/utils/view_image_took.dart';
import 'package:semo/core/presentation/widgets/buttons/back_button.dart';
import 'package:semo/features/community_shop/presentation/services/order_interaction_service.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/initial_screen/utils/models.dart';

class CommunityOrderCheckoutScreen extends StatefulWidget {
  const CommunityOrderCheckoutScreen({
    Key? key,
    required this.orders,
    required this.orderItem,
  }) : super(key: key);

  final List<CommunityOrder> orders;
  final OrderItem orderItem;

  @override
  State<CommunityOrderCheckoutScreen> createState() =>
      _CommunityOrderCheckoutScreenState();
}

class _CommunityOrderCheckoutScreenState
    extends State<CommunityOrderCheckoutScreen> {
  bool _showGuidanceOverlay = true; // Track if guidance overlay should be shown
  bool isExpanded = false;

  // Store the captured image
  File? _receiptImage;

  // Method to open the camera
  Future<void> _openCamera() async {
    // Show feedback when camera button is tapped
    HapticFeedback.mediumImpact();

    try {
      // Initialize image picker
      final ImagePicker picker = ImagePicker();

      // Capture image from camera
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 80, // Reduce image size/quality to save space
      );

      // If user took a photo (didn't cancel)
      if (photo != null) {
        setState(() {
          _receiptImage = File(photo.path);
        });

        // Here we would typically upload the image to the server
        // or process it further
        _showReceiptImagePreview();
      }
    } catch (e) {
      // Show error message if camera fails
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show a preview of the captured receipt image
  void _showReceiptImagePreview() {
    if (_receiptImage == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return viewImageTake(
            image: _receiptImage!,
            context: context,
            onRetake: _openCamera,
            onConfirm: () {
              // Here you would typically save or upload the image
              // or process it further
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Photo enregistrée'),
                  backgroundColor: Colors.green,
                ),
              );
              _receiptImage = null;
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Paiement'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 20, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: buildIconButton(
                CupertinoIcons.chat_bubble_text, Colors.black, Colors.white),
            onPressed: () {
              // Handle message action
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Ticket note with camera button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ticket note (expanded to take most of the space)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: _buildTicketNote(context),
                          ),
                        ),
                        // Camera button
                        Padding(
                          padding: const EdgeInsets.only(top: 16, right: 16),
                          child: FloatingActionButton(
                            onPressed: _openCamera,
                            heroTag: 'cameraButton',
                            backgroundColor: Colors.green,
                            mini: true,
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: _buildOrdersSummary(widget.orders),
                    ),
                    const SizedBox(height: 200),
                  ],
                ),
              ),
            ],
          ),
          buildBottomActionBar(
            context,
            'Continuer',
            onPressed: () => OrderProcessingInteractionService()
                .handleDeliveryOrderInformation(
                    context, widget.orders, widget.orderItem),
          ),
          if (_showGuidanceOverlay) _buildGuidanceOverlay(),
        ],
      ),
    );
  }

  Widget _buildTicketNote(BuildContext context) {
    return Note(
      title: 'Le ticket de caisse',
      description:
          'Recupérez le ticket de caisse, prenez le en photo, envoyer le nous et gardez le pour environ 2 semaines au cas où il faudra retourner les articles.',
      iconBackgroundColor: const Color.fromARGB(255, 240, 198, 11),
      icon: const Icon(Icons.document_scanner_sharp, color: Colors.white),
      onCameraTap: _openCamera,
    );
  }

  Widget _buildOrdersSummary(List<CommunityOrder> orders) {
    // Mock recent orders
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${orders[index].totalItems} articles • ${(orders[index].totalPrice).toStringAsFixed(2)}€',
                      ),
                      Text(
                        orders[index].customerName,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ...orders[index]
                          .productImageUrls
                          .take(3)
                          .map((productImageUrl) => Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(productImageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ))
                          .toList(),
                      if (orders[index].productImageUrls.length > 3)
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.black,
                            shape: const CircleBorder(),
                            minimumSize: const Size(40, 40),
                          ),
                          child: Text(
                            '+${orders[index].productImageUrls.length - 3}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Paiement effectué',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGuidanceOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Shopping list icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.credit_card,
                    size: 36,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Veuillez utiliser votre carte SEMO pour effectuer le paiement.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Got it button
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showGuidanceOverlay = false;
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Compris'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
