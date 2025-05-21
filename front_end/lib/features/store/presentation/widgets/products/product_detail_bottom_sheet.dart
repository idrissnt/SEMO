import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
import 'package:vibration/vibration.dart';

/// Shows a product detail bottom sheet
void showProductDetailBottomSheet(
    BuildContext context, CategoryProduct product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true, // Enable dragging to dismiss
    isDismissible: true, // Allow dismissing by tapping outside
    builder: (context) => ProductDetailBottomSheet(product: product),
  );
}

/// Bottom sheet that displays detailed information about a product
class ProductDetailBottomSheet extends StatefulWidget {
  /// The product to display
  final CategoryProduct product;

  /// Creates a new product detail bottom sheet
  const ProductDetailBottomSheet({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailBottomSheet> createState() =>
      _ProductDetailBottomSheetState();
}

class _ProductDetailBottomSheetState extends State<ProductDetailBottomSheet> {
  int quantity = 1;

  /// Provides haptic feedback when buttons are pressed
  void _vibrateButton() async {
    // Check if device supports vibration
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 20, amplitude: 80); // Short, light vibration
    }
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildRelatedProductItem() {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Product image
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                'https://via.placeholder.com/100',
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 24),
                ),
              ),
            ),
          ),

          // Add button
          Container(
            width: double.infinity,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: const Icon(Icons.add, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Icon(Icons.add),
        ],
      ),
    );
  }

  // Track if we've already popped to prevent double pops
  bool _hasPopped = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        // If the user drags the sheet below a certain threshold, dismiss it
        // but only if we haven't already popped
        if (notification.extent < 0.6 && !_hasPopped) {
          _hasPopped = true;
          Navigator.pop(context);
        }
        return true;
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.9, // Start at 90% of screen height
        minChildSize: 0.5, // Allow collapsing to 50% before dismissing
        maxChildSize: 0.95, // Allow expanding to 95% of screen
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),

                // Header with product name and close button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name.length > 25
                              ? '${widget.product.name.substring(0, 25)}...'
                              : widget.product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Main content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product image
                        Hero(
                          tag: 'product_image_${widget.product.id}',
                          child: Image.network(
                            widget.product.imageUrl,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              height: 200,
                              width: double.infinity,
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Product details
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product name
                              Text(
                                widget.product.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Price information
                              Row(
                                children: [
                                  Text(
                                    '\$${widget.product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(\$${widget.product.pricePerUnit.toStringAsFixed(2)}/${widget.product.unit})',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                widget.product.productUnit,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),

                              // Quantity selector
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 24),
                                child: Row(
                                  children: [
                                    _buildQuantityButton(
                                      icon: Icons.remove,
                                      onTap: () {
                                        if (quantity > 1) {
                                          setState(() {
                                            quantity--;
                                          });
                                          _vibrateButton();
                                        }
                                      },
                                    ),
                                    Container(
                                      width: 50,
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$quantity',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    _buildQuantityButton(
                                      icon: Icons.add,
                                      onTap: () {
                                        setState(() {
                                          quantity++;
                                        });
                                        _vibrateButton();
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // Add note section
                              InkWell(
                                onTap: () {
                                  // Add note functionality would go here
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    children: [
                                      Icon(Icons.refresh,
                                          color: Colors.grey[600]),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Add note or edit replacement',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Best match',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right),
                                    ],
                                  ),
                                ),
                              ),

                              const Divider(height: 32),

                              // Frequently bought together section
                              const Text(
                                'Frequently bought together',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Horizontal list of related products
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 3, // Mock data
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: _buildRelatedProductItem(),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Details expandable section
                              _buildExpandableSection(
                                title: 'Details',
                                onTap: () {
                                  // Expand details section
                                },
                              ),

                              const SizedBox(height: 16),

                              // Ingredients expandable section
                              _buildExpandableSection(
                                title: 'Ingredients',
                                onTap: () {
                                  // Expand ingredients section
                                },
                              ),

                              const SizedBox(height: 16),

                              // Disclaimer text
                              Text(
                                'The information shown here may not be current, complete, or accurate. Always check the item\'s packaging for product information and warnings.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),

                              // Extra space at the bottom for the fixed add to cart button
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Fixed add to cart button at the bottom
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Add to cart functionality would go here
                      _vibrateButton();
                      Navigator.pop(
                          context); // Return to previous screen after adding to cart
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Add $quantity to cart • \$${(widget.product.price * quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
