import 'package:flutter/material.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
import 'package:vibration/vibration.dart';

// Import utility files
import 'utils/product_image.dart';
import 'utils/product_details.dart';
import 'utils/quantity_selector.dart';
import 'utils/add_note_section.dart';
import 'utils/related_products.dart';
import 'utils/expandable_sections.dart';
import 'utils/add_to_cart_button.dart';
import 'utils/header_components.dart';

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

  // Current product being displayed
  late CategoryProduct _currentProduct;

  // Stack of previously viewed products
  final List<CategoryProduct> _productStack = [];

  // Track if we've already popped to prevent double pops
  bool _hasPopped = false;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
  }

  /// Provides haptic feedback when buttons are pressed
  Future<void> vibrateButton() async {
    // Check if device supports vibration
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 20, amplitude: 80); // Short, light vibration
    }
  }

  // Navigate to a related product using stacked modal sheets
  void _navigateToRelatedProduct(CategoryProduct product) {
    // Add current product to stack before navigating
    setState(() {
      _productStack.add(_currentProduct);
      _currentProduct = product;
    });

    // Show a new bottom sheet for the related product
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => ProductDetailBottomSheet(product: product),
    );
  }

  // Handle drag notification to dismiss sheet when dragged below threshold
  bool _handleDragNotification(DraggableScrollableNotification notification) {
    if (notification.extent < 0.6 && !_hasPopped) {
      _hasPopped = true;
      Navigator.pop(context);
    }
    return true;
  }

  // Handle scroll notification to reset popped flag
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      _hasPopped = false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: _handleDragNotification,
      child: DraggableScrollableSheet(
        initialChildSize: 0.9, // Take up 90% of the screen initially
        minChildSize: 0.5, // Minimum size when dragged down
        maxChildSize: 0.95, // Maximum size when dragged up
        builder: (context, scrollController) {
          return NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildDragHandle(),
                  buildHeader(
                    product: _currentProduct,
                    context: context,
                    isNestedProduct: _productStack.isNotEmpty,
                  ),

                  // Main content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildProductImage(_currentProduct),

                          // Product details section
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildProductDetails(_currentProduct),
                                const SizedBox(height: 16),
                                buildQuantitySelector(
                                  quantity: quantity,
                                  onQuantityChanged: (newQuantity) {
                                    setState(() {
                                      quantity = newQuantity;
                                    });
                                  },
                                  vibrateButton: vibrateButton,
                                ),
                                const SizedBox(height: 16),
                                buildAddNoteSection(),
                                const Divider(height: 32),
                                FutureBuilder<List<CategoryProduct>>(
                                  future: Future.value(getMockRelatedProducts(
                                      _currentProduct,
                                      _productStack.isNotEmpty)),
                                  builder: (context, snapshot) {
                                    final relatedProducts = snapshot.data ?? [];
                                    return buildRelatedProductsSection(
                                      relatedProducts,
                                      _navigateToRelatedProduct,
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
                                buildExpandableSections(),

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
                  buildAddToCartButton(
                    product: _currentProduct,
                    quantity: quantity,
                    vibrateButton: vibrateButton,
                    context: context,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
