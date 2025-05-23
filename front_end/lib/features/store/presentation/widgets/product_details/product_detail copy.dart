import 'package:flutter/material.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
import 'package:semo/features/store/routes/route_config/store_routes_const.dart';

void showProductDetailBottomSheet(
    BuildContext context, CategoryProduct product, String storeId) {
  showDialog(
    context: context,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    barrierDismissible: true,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: DraggableScrollableSheet(
        initialChildSize: 0.99,
        maxChildSize: 0.99,
        minChildSize: 0.5,
        shouldCloseOnMinExtent: true,
        builder: (context, scrollController) {
          return ProductDetailScreen(
            product: product,
            storeId: storeId,
            scrollController: scrollController,
            onClose: () {
              Navigator.of(context).pop();
            },
          );
        },
      ),
    ),
  );
}

/// Screen that displays detailed information about a product
class ProductDetailScreen extends StatefulWidget {
  /// The product to display
  final CategoryProduct product;

  /// The store ID
  final String storeId;

  /// Callback when close button is pressed
  final VoidCallback onClose;

  /// ScrollController for the draggable sheet
  final ScrollController scrollController;

  /// Creates a new product detail screen
  const ProductDetailScreen({
    Key? key,
    required this.product,
    required this.storeId,
    required this.onClose,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    // Make sure we have a full-screen modal with white background
    return Material(
      color: Colors.grey, // White background that extends to the top
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          // Only round the bottom corners to match the design
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: Column(
          children: [
            // Top navigation bar with close and share buttons
            _buildTopBar(context),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                controller: widget.scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product image
                    _buildProductImage(),

                    // Product details
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product name and description
                          _buildProductInfo(),

                          const SizedBox(height: 16),

                          // Price information
                          _buildPriceInfo(),

                          const SizedBox(height: 16),

                          // Product details (size, vegetarian, etc.)
                          _buildProductDetails(),

                          // const SizedBox(height: 16),

                          // // Store info
                          // _buildStoreInfo(),

                          // const SizedBox(height: 24),

                          // // Quantity selector
                          // _buildQuantitySelector(),

                          // const SizedBox(height: 24),

                          // // Add note section
                          // _buildAddNoteSection(),

                          // // Add to cart button
                          // const SizedBox(height: 16),
                          // _buildAddToCartButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    // Get the status bar height to ensure proper alignment
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Padding(
      // Add padding that accounts for the status bar height
      padding: EdgeInsets.only(
        top: statusBarHeight, // Match status bar height
        left: 8.0,
        right: 8.0,
        bottom: 12.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          IconButton(
            icon: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.close, size: 20),
              ),
            ),
            onPressed: widget.onClose,
          ),

          // Pagination indicators
          Row(
            children: List.generate(
              4,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == 0 ? Colors.black : Colors.grey.shade300,
                ),
              ),
            ),
          ),

          // Share button
          IconButton(
            icon: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.share_outlined, size: 20),
              ),
            ),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Center(
      child: Hero(
        tag: StoreRoutesConst.getStoreHeroTag(widget.product.id),
        child: Image.network(
          widget.product.imageUrl,
          height: 300,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (widget.product.description != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              widget.product.description!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceInfo() {
    return Row(
      children: [
        Text(
          '€${widget.product.price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '(€${widget.product.pricePerUnit.toStringAsFixed(2)}/${widget.product.unit})',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Text(
                '12 for €${(widget.product.price * 12).toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.info_outline, color: Colors.white, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.productUnit,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.eco_outlined, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              'Vegetarian',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStoreInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              'https://logo.clearbit.com/carrefour.fr',
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Carrefour',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '0.49 € Delivery Fee • 10 min',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              if (quantity > 1) {
                setState(() {
                  quantity--;
                });
              }
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                quantity.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                quantity++;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddNoteSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.note_alt_outlined, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add note or edit replacement',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
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
          const Spacer(),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Add to cart functionality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added ${widget.product.name} to cart'),
                duration: const Duration(seconds: 2),
              ),
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Add to cart',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
