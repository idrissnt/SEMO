import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/core/presentation/theme/app_icons.dart';
import 'package:semo/core/presentation/navigation/bottom_sheet_nav/bottom_sheet_navigator.dart';
import 'package:semo/features/order/presentation/constant/constants.dart';
import 'package:semo/features/order/routes/bottom_sheet/after_register/routes_constants.dart';

/// A screen for collecting user address information
/// This is designed to be used as a sub-route within the email verification bottom sheet
class UserAddressScreen extends StatefulWidget {
  const UserAddressScreen({Key? key}) : super(key: key);

  @override
  State<UserAddressScreen> createState() => _UserAddressScreenState();
}

class _UserAddressScreenState extends State<UserAddressScreen> {
  // ScrollController for the scrollbar
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Ensure the controller is properly initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        setState(() {}); // Trigger a rebuild after the controller is attached
      }
    });
  }

  @override
  void dispose() {
    // Dispose the scroll controller to prevent memory leaks
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          _buildDragHandle(),

          // Title with back button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () =>
                      context.go(RegisterVerificationSheetRoutesConstants.root),
                ),
                const Text(
                  "Votre adresse",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                    decoration: TextDecoration.none,
                  ),
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
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
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
      height: OrderConstants.searchBarHeight,
      decoration: BoxDecoration(
        color: AppColors.searchBarColor,
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
      ),
      padding: EdgeInsets.symmetric(horizontal: AppDimensionsWidth.medium),
      // Animate width changes
      width: OrderConstants.searchBarWidth,
      // No margin to avoid overflow
      child: Row(
        children: [
          // Animated icon
          AnimatedContainer(
            duration: OrderConstants.animationDuration,
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
                if (query.length >= OrderConstants.queryLength) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            // default value
            'Ajouter une adresse',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryColor,
              decoration: TextDecoration.none,
            ),
          ),
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
                // In a bottom sheet, we need to use the parent Navigator's context
                // to find the BottomSheetNavigator and use its navigation methods
                final navigator = context
                    .findAncestorStateOfType<BottomSheetNavigatorState>();
                if (navigator != null) {
                  // Use the navigator's navigateTo method to navigate within the bottom sheet
                  navigator.navigateTo(
                      RegisterVerificationSheetRoutesConstants.addressEdit);
                } else {
                  debugPrint(
                      'BottomSheetNavigator not found in the widget tree');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// create
// pencil
