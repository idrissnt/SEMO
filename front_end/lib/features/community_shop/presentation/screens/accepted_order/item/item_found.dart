import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/init_screen/utils/models.dart';
import 'package:semo/features/community_shop/presentation/screens/widgets/icon_button.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/features/community_shop/routes/constants/route_constants.dart';

class CommunityOrderItemDetailsFoundScreen extends StatefulWidget {
  final OrderItem orderItem;
  final CommunityOrder order;

  const CommunityOrderItemDetailsFoundScreen({
    Key? key,
    required this.orderItem,
    required this.order,
  }) : super(key: key);

  @override
  State<CommunityOrderItemDetailsFoundScreen> createState() =>
      _CommunityOrderItemDetailsFoundScreenState();
}

class _CommunityOrderItemDetailsFoundScreenState
    extends State<CommunityOrderItemDetailsFoundScreen> {
  // Text controller for the quantity input
  final TextEditingController _quantityController = TextEditingController();

  // Focus node to manage keyboard focus
  final FocusNode _quantityFocusNode = FocusNode();

  // Whether the confirm button should be enabled
  bool get _canConfirm =>
      _quantityController.text.isNotEmpty &&
      int.tryParse(_quantityController.text) != null &&
      int.parse(_quantityController.text) > 0;

  @override
  void initState() {
    super.initState();
    // Listen for changes in the text field to update the UI
    _quantityController.addListener(() {
      setState(() {
        // This empty setState forces a rebuild when the text changes
      });
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _quantityFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: buildIconButton(
                CupertinoIcons.chat_bubble_text, Colors.black, Colors.white),
            onPressed: () {
              // Handle share action
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              widget.orderItem.name,
              style: TextStyle(
                fontSize: AppFontSize.large,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Product image
                Hero(
                  tag: 'product-image-${widget.orderItem.id}_item_details',
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    height: 50,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(widget.orderItem.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Product details with proper text styling
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Product name with quantity in bold
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${widget.orderItem.quantity}',
                              style: TextStyle(
                                fontSize: AppFontSize.medium,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryColor,
                              ),
                            ),
                            const TextSpan(
                              text: ' x ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black87,
                              ),
                            ),
                            TextSpan(
                              text: widget.orderItem.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Quantity and price
                      Row(
                        children: [
                          Text(
                            '${widget.orderItem.quantity} ${widget.orderItem.unit}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${widget.orderItem.price.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Quantity found section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quantité trouvée',
                  style: TextStyle(
                    fontSize: AppFontSize.medium,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    // Explicitly request focus when the container is tapped
                    _quantityFocusNode.requestFocus();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _quantityController,
                      focusNode: _quantityFocusNode,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      autofocus: true, // Set autofocus to true
                      decoration: InputDecoration(
                        hintText: 'Entrez la quantité trouvée',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: InputBorder.none,
                        suffixText: widget.orderItem.unit,
                        suffixStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _canConfirm
                        ? () {
                            // Navigate to order started screen with the order data
                            // Using goNamed with path parameters for shareable URLs
                            context.goNamed(
                              RouteConstants.orderStartName,
                              pathParameters: {'orderId': widget.order.id},
                              extra: widget
                                  .order, // Still passing the order object for now until BLoC is implemented
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Confirmer',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
