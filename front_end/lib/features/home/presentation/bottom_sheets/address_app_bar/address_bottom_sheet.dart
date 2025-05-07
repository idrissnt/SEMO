import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/core/presentation/theme/app_icons.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/home/presentation/bottom_sheets/shared/bottom_sheet_navigator.dart';
import 'package:semo/features/home/presentation/constant/home_constants.dart';
import 'package:semo/features/home/routes/bottom_sheet/app_bar_address/routes_constants.dart';
import 'package:semo/features/home/routes/bottom_sheet/app_bar_address/router_config.dart';

/// A bottom sheet that allows users to view and edit their address
class AddressBottomSheet extends StatefulWidget {
  final ScrollController? scrollController;

  const AddressBottomSheet({Key? key, this.scrollController}) : super(key: key);

  @override
  State<AddressBottomSheet> createState() => _AddressBottomSheetState();
}

class _AddressBottomSheetState extends State<AddressBottomSheet> {
  // Key for the bottom sheet navigator
  final _navigatorKey = GlobalKey<BottomSheetNavigatorState>();
  final _logger = AppLogger();

  /// Closes the entire bottom sheet
  ///
  /// This uses the standard Navigator API since the bottom sheet itself
  /// is presented using showModalBottomSheet, which is outside the
  /// GoRouter navigation context
  void _closeBottomSheet() {
    _logger.debug('Closing address bottom sheet');
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetNavigator(
      key: _navigatorKey,
      initialPage: _buildAddressViewPage(),
      initialRoute: AppBarAddressRoutesConstants.root,
      routeCreator: AppBarAddressRouterConfig.createRoutes,
      scrollController: widget.scrollController,
    );
  }

  // The main address view page
  Widget _buildAddressViewPage() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          _buildDragHandle(),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Empty space on the left to balance the close button
                const SizedBox(width: 48),
                // Centered title with Expanded to take available space
                const Expanded(
                  child: Center(
                    child: Text(
                      "Votre adresse",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                // Close button at the end
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _closeBottomSheet,
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Scrollbar(
              thickness: 6,
              radius: const Radius.circular(10),
              thumbVisibility: true,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    _buildUseCurrentLocationButton(),
                    const SizedBox(height: 32),
                    _buildAllAddress(context),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Color(0xFFEEEEEE),
                    ),
                    // const SizedBox(height: 16),
                    _buildAddress(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 5,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: HomeConstants.searchBarHeight,
      decoration: BoxDecoration(
        color: AppColors.searchBarColor,
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
      ),
      padding: EdgeInsets.symmetric(horizontal: AppDimensionsWidth.medium),
      // Animate width changes
      width: HomeConstants.searchBarWidth,
      // No margin to avoid overflow
      child: Row(
        children: [
          // Animated icon
          AnimatedContainer(
            duration: HomeConstants.animationDuration,
            curve: Curves.easeInOut,
            padding: EdgeInsets.zero,
            child:
                const Icon(Icons.search, color: AppColors.iconColorFirstColor),
          ),
          SizedBox(width: AppDimensionsWidth.xSmall),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher une adresse',
                hintStyle: const TextStyle(color: AppColors.searchBarHintColor),
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: AppDimensionsHeight.xSmall),
              ),
              style: TextStyle(fontSize: AppFontSize.medium),
              onChanged: (query) {
                if (query.length >= HomeConstants.queryLength) {
                  // Handle search query
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  TextButton _buildUseCurrentLocationButton() {
    return TextButton.icon(
      style: TextButton.styleFrom(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: AppDimensionsWidth.small,
            vertical: AppDimensionsHeight.xxSmall),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: const Size(0, 0),
      ),
      onPressed: () {},
      icon: AppIcons.locationLookFor(
          size: AppIconSize.xl, color: AppColors.primary),
      label: Text('Utiliser ma localisation actuelle',
          style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: AppFontSize.medium)),
    );
  }

  Widget _buildAllAddress(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Leading icon
          Container(
            padding: const EdgeInsets.all(6),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: AppIcons.location(size: 24, color: Colors.white),
          ),
          const SizedBox(width: 16),
          // Title and subtitle
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adresse actuelle',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryColor,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddress(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ]),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Use Expanded to make the text take available space and prevent overflow
          const Expanded(
            child: Text(
              // default value
              '123 Rue de la joie Nancy 54000, France',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimaryColor,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          // Add a small gap between text and icon
          const SizedBox(width: 4),
          Container(
            margin: const EdgeInsets.all(6),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 213, 213, 213),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              iconSize: 40,
              padding: EdgeInsets.zero,
              icon: AppIcons.pencil(
                  size: AppIconSize.xxl, color: AppColors.iconColorFirstColor),
              onPressed: () {
                _logger.debug('Navigating to edit address screen');
                _navigatorKey.currentState
                    ?.navigateTo(AppBarAddressRoutesConstants.edit);
              },
            ),
          ),
        ],
      ),
    );
  }
}

void showAddressBottomSheet(BuildContext context) {
  final logger = AppLogger();
  logger.debug('Showing address bottom sheet');

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
    isDismissible: true,
    useSafeArea: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.98,
      minChildSize: 0.5,
      maxChildSize: 0.98,
      expand: false,
      builder: (context, scrollController) =>
          AddressBottomSheet(scrollController: scrollController),
    ),
  );
}
