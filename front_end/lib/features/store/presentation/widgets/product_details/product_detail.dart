import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';

/// Shows a product detail modal that covers most of the screen
/// Can be dismissed by scrolling down or tapping outside
/// Hides the bottom navigation of the previous screen
void showProductDetailBottomSheet(
    BuildContext context, CategoryProduct product, String storeId) {
  // Using a custom bottom sheet implementation for interactive drag-to-dismiss
  showInteractiveDismissibleBottomSheet(
    context: context,
    builder: (context, controller, onDismiss, physics) {
      return ProductDetailScreen(
        product: product,
        storeId: storeId,
        scrollController: controller,
        onClose: onDismiss,
        customPhysics: physics,
      );
    },
  );
}

/// Builder function type for bottom sheet content
typedef BottomSheetContentBuilder = Widget Function(
  BuildContext context,
  ScrollController controller,
  VoidCallback onDismiss,
  ScrollPhysics physics,
);

/// Custom scroll physics that allows dragging the parent container when overscrolling at the top
class DismissibleScrollPhysics extends BouncingScrollPhysics {
  final VoidCallback onDragDown;
  final bool Function() isAtTopGetter;
  final double dragStartThreshold;
  
  const DismissibleScrollPhysics({
    required this.onDragDown,
    required this.isAtTopGetter,
    this.dragStartThreshold = 20.0,
    ScrollPhysics? parent,
  }) : super(parent: parent);
  
  @override
  DismissibleScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return DismissibleScrollPhysics(
      onDragDown: onDragDown,
      isAtTopGetter: isAtTopGetter,
      dragStartThreshold: dragStartThreshold,
      parent: buildParent(ancestor),
    );
  }
  
  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // If we're at the top and the user is dragging down
    if (isAtTopGetter() && position.pixels <= 0 && offset > 0) {
      // If the drag exceeds our threshold, trigger the parent drag
      if (offset > dragStartThreshold) {
        onDragDown();
        // Return a smaller value to reduce the bounce effect in the ScrollView
        return offset * 0.3;
      }
    }
    
    return super.applyPhysicsToUserOffset(position, offset);
  }
  
  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Don't apply boundary conditions when we're handling the drag in the parent
    if (isAtTopGetter() && position.pixels <= 0 && value < 0) {
      return 0.0;
    }
    
    return super.applyBoundaryConditions(position, value);
  }
}

/// Shows a bottom sheet that can be interactively dismissed by dragging down
void showInteractiveDismissibleBottomSheet({
  required BuildContext context,
  required BottomSheetContentBuilder builder,
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
  final BottomSheetContentBuilder builder;

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

class _DismissibleBottomSheetContentState extends State<_DismissibleBottomSheetContent> with SingleTickerProviderStateMixin {
  bool isDragging = false;
  double dragDistance = 0.0;
  late AnimationController _springBackController;
  late Animation<double> _springBackAnimation;

  @override
  void initState() {
    super.initState();
    _springBackController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _springBackAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _springBackController, curve: Curves.easeOutBack)
    );
    
    _springBackAnimation.addListener(() {
      setState(() {
        // Ensure we never set a negative value
        dragDistance = _springBackAnimation.value.clamp(0.0, double.infinity);
      });
    });
  }
  
  @override
  void dispose() {
    _springBackController.dispose();
    super.dispose();
  }

  // Dismiss the sheet
  void dismissSheet() => Navigator.of(context).pop();

  // Reset drag state with spring animation
  void resetDrag() {
    // Ensure we're not starting with a negative value
    _springBackAnimation = Tween<double>(
      begin: dragDistance.clamp(0.0, double.infinity),
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _springBackController,
      curve: Curves.easeOutBack,
    ));
    
    _springBackController.reset();
    _springBackController.forward();
    
    setState(() {
      isDragging = false;
    });
  }
  
  // Start dragging from scroll physics
  void startDragFromScroll() {
    if (!isDragging) {
      setState(() {
        isDragging = true;
        // Start with a small initial drag to provide immediate feedback
        dragDistance = 10.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create custom scroll physics for the content
    final dismissiblePhysics = DismissibleScrollPhysics(
      onDragDown: startDragFromScroll,
      isAtTopGetter: widget.isAtTopGetter,
    );
    
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
              // Only apply resistance if we're not already at 0
              if (dragDistance > 0) {
                dragDistance += details.delta.dy / 3; // More resistance
                // Ensure we never go below 0 to avoid negative margin error
                dragDistance = dragDistance.clamp(0.0, double.infinity);
              }
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

              // Content area with custom physics
              Expanded(
                child: widget.builder(
                  context, 
                  widget.scrollController, 
                  dismissSheet,
                  dismissiblePhysics,
                ),
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
  
  /// Custom scroll physics for the content
  final ScrollPhysics? customPhysics;

  /// Creates a new product detail screen
  const ProductDetailScreen({
    Key? key,
    required this.product,
    required this.storeId,
    required this.onClose,
    required this.scrollController,
    this.customPhysics,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // Use custom physics if provided, otherwise use default
    final scrollPhysics = widget.customPhysics ?? 
        const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
    
    return Column(
      children: [
        // Top navigation bar with close and share buttons
        _buildTopBar(context),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            // Use the custom physics that enables drag-to-dismiss from content area
            physics: scrollPhysics,
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
