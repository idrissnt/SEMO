import 'package:flutter/material.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';

/// Shows a product detail modal that covers most of the screen
/// Can be dismissed by scrolling down or tapping outside
/// Hides the bottom navigation of the previous screen
void showProductDetailBottomSheet(
    BuildContext context, CategoryProduct product, String storeId) {
  // Using a custom bottom sheet implementation for interactive drag-to-dismiss
  showInteractiveDismissibleBottomSheet(
    context: context,
    builder: (context, controller, onDismiss) {
      return ProductDetailScreen(
        product: product,
        storeId: storeId,
        scrollController: controller,
        onClose: onDismiss,
      );
    },
  );
}

/// Shows a bottom sheet that can be interactively dismissed by dragging down
void showInteractiveDismissibleBottomSheet({
  required BuildContext context,
  required Widget Function(BuildContext, ScrollController, VoidCallback) builder,
}) {
  // Create scroll controller and calculate screen dimensions
  final scrollController = ScrollController();
  final screenHeight = MediaQuery.of(context).size.height;
  final dismissThreshold = screenHeight * 0.5; // Half screen height threshold
  
  // Track if content is at the top (for drag-to-dismiss functionality)
  bool isAtTop = true;
  scrollController.addListener(() => isAtTop = scrollController.offset <= 0);

  // Show the custom bottom sheet
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true, // Allow dismiss by tapping outside
    enableDrag: false,   // We'll handle drag manually
    useRootNavigator: true, // Ensure it appears above navigation bars
    builder: (context) {
      return _DismissibleBottomSheetContent(
        screenHeight: screenHeight,
        dismissThreshold: dismissThreshold,
        scrollController: scrollController,
        isAtTopGetter: () => isAtTop,
        builder: builder,
      );
    },
  );
}

/// Internal widget to handle the dismissible bottom sheet content and gestures
class _DismissibleBottomSheetContent extends StatefulWidget {
  final double screenHeight;
  final double dismissThreshold;
  final ScrollController scrollController;
  final bool Function() isAtTopGetter;
  final Widget Function(BuildContext, ScrollController, VoidCallback) builder;

  const _DismissibleBottomSheetContent({
    required this.screenHeight,
    required this.dismissThreshold,
    required this.scrollController,
    required this.isAtTopGetter,
    required this.builder,
  });

  @override
  State<_DismissibleBottomSheetContent> createState() => _DismissibleBottomSheetContentState();
}

class _DismissibleBottomSheetContentState extends State<_DismissibleBottomSheetContent> {
  bool isDragging = false;
  double dragDistance = 0.0;

  // Dismiss the sheet
  void dismissSheet() => Navigator.of(context).pop();

  // Reset drag state
  void resetDrag() {
    setState(() {
      isDragging = false;
      dragDistance = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      // Animate the position change with a smooth curve
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.only(top: dragDistance),
      child: GestureDetector(
        // Start dragging only if we're at the top of the content
        onVerticalDragStart: (details) {
          if (widget.isAtTopGetter()) {
            setState(() => isDragging = true);
          }
        },
        
        // Update drag distance as user drags
        onVerticalDragUpdate: (details) {
          if (!isDragging) return;
          
          setState(() {
            // Allow downward dragging with resistance for upward movement
            if (details.delta.dy > 0) {
              dragDistance += details.delta.dy;
            } else {
              dragDistance += details.delta.dy / 3; // More resistance
              dragDistance = dragDistance.clamp(0.0, double.infinity);
            }
          });
        },
        
        // Handle drag end - either dismiss or spring back
        onVerticalDragEnd: (details) {
          if (!isDragging) return;
          
          final velocity = details.velocity.pixelsPerSecond.dy;
          if (dragDistance > widget.dismissThreshold || velocity > 700) {
            dismissSheet();
          } else {
            resetDrag();
          }
        },
        
        onVerticalDragCancel: resetDrag,
        
        // Prevent taps from passing through
        onTap: () {},
        
        child: Container(
          height: widget.screenHeight * 0.95,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle with visual feedback
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: isDragging ? Colors.grey[400] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Content area
              Expanded(
                child: widget.builder(context, widget.scrollController, dismissSheet),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top navigation bar with close and share buttons
        _buildTopBar(context),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            // This physics setting is important for allowing overscroll at the top
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
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

                      // Product details (size, vegetarian, etc.)
                      _buildProductDetails(),

                      // Extra space at bottom for better scrolling
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
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
    );
  }

  Widget _buildProductImage() {
    return Center(
      child: Image.network(
        widget.product.imageUrl,
        height: 300,
        fit: BoxFit.cover,
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
}
