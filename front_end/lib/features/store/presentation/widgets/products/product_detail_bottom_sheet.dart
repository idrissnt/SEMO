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

  // Current product being displayed
  late CategoryProduct _currentProduct;

  // Stack of previously viewed products
  final List<CategoryProduct> _productStack = [];

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
  }

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

  // Navigate to a related product using stacked modal sheets
  void _navigateToRelatedProduct(CategoryProduct product) {
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

  // Generate mock related products for demonstration
  List<CategoryProduct> _getMockRelatedProducts() {
    // Don't show the current product in related products
    // In a real app, this would come from an API call or repository

    // Create 3 mock products with variations of the current product
    final List<CategoryProduct> mockProducts = [];

    // Only create related products if we're not already showing a related product
    // This prevents infinite nesting of related products
    if (_productStack.isEmpty) {
      // Create variations of the current product with different IDs and slightly different names/prices
      for (int i = 1; i <= 3; i++) {
        mockProducts.add(
          CategoryProduct(
            id: '${_currentProduct.id}_related_$i',
            name: '${_currentProduct.name} Variation $i',
            imageUrl: _currentProduct.imageUrl,
            price:
                _currentProduct.price + (i * 0.5), // Slightly different price
            pricePerUnit: _currentProduct.pricePerUnit + (i * 0.1),
            unit: _currentProduct.unit,
            productUnit: _currentProduct.productUnit,
          ),
        );
      }
    }

    return mockProducts;
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
                    _buildDragHandle(),
                    _buildHeader(),

                    // Main content
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProductImage(),

                            // Product details section
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildProductDetails(),
                                  const SizedBox(height: 16),
                                  _buildQuantitySelector(),
                                  const SizedBox(height: 16),
                                  _buildAddNoteSection(),
                                  const Divider(height: 32),
                                  _buildRelatedProductsSection(),
                                  const SizedBox(height: 24),
                                  _buildExpandableSections(),

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
                    _buildAddToCartButton(),
                  ],
                ),
              ));
        },
      ),
    );
  }

  Widget _buildRelatedProductItem(CategoryProduct product) {
    return InkWell(
      onTap: () => _navigateToRelatedProduct(product),
      child: Container(
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
                  product.imageUrl,
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

  /// Handle close button press
  void _handleCloseButtonPressed() {
    // If we're in a nested sheet and have accumulated many sheets,
    // show a dialog asking if the user wants to close all or just this one
    if (_productStack.length > 1) {
      _showCloseOptionsDialog();
    } else {
      // Just close this sheet
      Navigator.pop(context);
    }
  }

  /// Show dialog with options to close current sheet or all sheets
  void _showCloseOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close options'),
        content: const Text('You have multiple product sheets open.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close current sheet
            },
            child: const Text('Close this one'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Close all sheets
              _closeAllSheets();
            },
            child: const Text('Close all'),
          ),
        ],
      ),
    );
  }

  /// Close all bottom sheets
  void _closeAllSheets() {
    Navigator.of(context).popUntil((route) {
      return route.isFirst || !(route is ModalBottomSheetRoute);
    });
  }

  /// Build the drag handle at the top of the sheet
  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      height: 4,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// Build the header with product name and close button
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _currentProduct.name.length > 25
                  ? '${_currentProduct.name.substring(0, 25)}...'
                  : _currentProduct.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Close button with additional functionality for nested sheets
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _handleCloseButtonPressed,
          ),
        ],
      ),
    );
  }

  /// Handle drag notification to dismiss sheet when dragged below threshold
  bool _handleDragNotification(DraggableScrollableNotification notification) {
    if (notification.extent < 0.6 && !_hasPopped) {
      _hasPopped = true;
      Navigator.pop(context);
    }
    return true;
  }

  /// Handle scroll notification to reset popped flag
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      _hasPopped = false;
    }
    return true;
  }

  /// Build the product image with hero animation
  Widget _buildProductImage() {
    return Hero(
      tag: 'product_image_${_currentProduct.id}',
      child: Image.network(
        _currentProduct.imageUrl,
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
    );
  }

  /// Build the product details section (name and price)
  Widget _buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product name
        Text(
          _currentProduct.name,
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
              '\$${_currentProduct.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(\$${_currentProduct.pricePerUnit.toStringAsFixed(2)}/${_currentProduct.unit})',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Text(
          _currentProduct.productUnit,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Build the quantity selector
  Widget _buildQuantitySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }

  /// Build the add note section
  Widget _buildAddNoteSection() {
    return InkWell(
      onTap: () {
        // Add note functionality would go here
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(Icons.refresh, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  /// Build the related products section
  Widget _buildRelatedProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          child: FutureBuilder<List<CategoryProduct>>(
            // In a real app, this would be a call to get related products
            // For now, we'll create mock related products based on the current product
            future: Future.value(_getMockRelatedProducts()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final relatedProducts = snapshot.data ?? [];

              if (relatedProducts.isEmpty) {
                return const Center(
                  child: Text('No related products found'),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: relatedProducts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildRelatedProductItem(relatedProducts[index]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build the expandable sections (Details and Ingredients)
  Widget _buildExpandableSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  /// Build the add to cart button
  Widget _buildAddToCartButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
          'Add $quantity to cart • \$${(_currentProduct.price * quantity).toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
