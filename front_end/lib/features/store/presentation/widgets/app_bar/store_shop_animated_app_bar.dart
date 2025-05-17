import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/store/domain/entities/store.dart';

/// An animated app bar for the store shop tab that changes based on scroll position
class StoreShopAnimatedAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  /// The store brand information
  final StoreBrand store;

  /// Callback when the back button is pressed
  final VoidCallback onBackPressed;

  /// Callback when the info button is pressed
  final VoidCallback onInfoPressed;

  /// Callback when the add people button is pressed
  final VoidCallback onAddPeoplePressed;

  /// Callback when the search button is pressed
  final VoidCallback onSearchPressed;

  /// The scroll controller to detect scroll position
  final ScrollController scrollController;

  const StoreShopAnimatedAppBar({
    Key? key,
    required this.store,
    required this.onBackPressed,
    required this.onInfoPressed,
    required this.onAddPeoplePressed,
    required this.onSearchPressed,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<StoreShopAnimatedAppBar> createState() =>
      _StoreShopAnimatedAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 2);
}

class _StoreShopAnimatedAppBarState extends State<StoreShopAnimatedAppBar> {
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final isScrolled = widget.scrollController.offset > 100;
    if (isScrolled != _isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _isScrolled ? kToolbarHeight : kToolbarHeight * 2,
      child: Stack(
        children: [
          // Banner image - only visible when not scrolled
          if (!_isScrolled)
            Positioned.fill(
              child: Image.network(
                widget.store.imageBanner,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  );
                },
              ),
            ),

          // App bar content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: widget.onBackPressed,
                  ),

                  // Search bar - only when scrolled
                  if (_isScrolled)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: widget.onSearchPressed,
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Search products',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Right side buttons - only when not scrolled
                  if (!_isScrolled)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.info_outline,
                              color: Colors.white),
                          onPressed: widget.onInfoPressed,
                        ),
                        IconButton(
                          icon: const Icon(Icons.person_add_outlined,
                              color: Colors.white),
                          onPressed: widget.onAddPeoplePressed,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
