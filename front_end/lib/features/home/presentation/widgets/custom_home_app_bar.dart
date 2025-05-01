// // ignore_for_file: prefer_const_constructors

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:semo/core/presentation/theme/responsive_theme.dart';
// import '../bloc/home_store/home_store_bloc.dart';
// import '../bloc/home_store/home_store_event.dart';
// import '../bloc/home_store/home_store_state.dart';
// import '../bloc/user_address/user_address_bloc.dart';
// import '../bloc/user_address/user_address_state.dart';

// class CustomHomeAppBar extends StatelessWidget {
//   final bool isCollapsed;
//   final double scrolledRatio;

//   const CustomHomeAppBar({
//     Key? key,
//     required this.isCollapsed,
//     required this.scrolledRatio,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Reduced app bar height to minimize white space
//     final appBarHeight = isCollapsed
//         ? context.getResponsiveHeightValue(kToolbarHeight)
//         : context.getResponsiveHeightValue(kToolbarHeight * 1.9);

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return Material(
//           elevation: isCollapsed ? context.cardElevationWidth : 0,
//           color: context.backgroundColor,
//           child: SafeArea(
//             bottom: false,
//             child: SizedBox(
//               height: appBarHeight,
//               width: constraints.maxWidth,
//               child: Stack(
//                 children: [
//                   // Top row with location and icons - only visible when not collapsed
//                   if (!isCollapsed)
//                     Positioned(
//                       top: context.xxsWidth,
//                       left: context.mWidth,
//                       right: context.mWidth,
//                       child: _buildTopRow(context),
//                     ),

//                   // Search bar with animated position
//                   AnimatedPositioned(
//                     duration: const Duration(milliseconds: 200),
//                     curve: Curves.easeInOut,
//                     // Adjusted search bar position for reduced app bar height
//                     top: isCollapsed
//                         ? context.sWidth
//                         : context
//                             .getResponsiveWidthValue(kToolbarHeight * 0.95),
//                     left: context.mWidth,
//                     right: context.mWidth,
//                     height: context.buttonHeightMediumWidth,
//                     child: _buildSearchBarRow(context),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTopRow(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         _buildLocationWidget(context),
//         _buildActionIcons(context),
//       ],
//     );
//   }

//   Widget _buildLocationWidget(BuildContext context) {
//     return BlocBuilder<HomeUserAddressBloc, HomeUserAddressState>(
//       buildWhen: (previous, current) =>
//           current is HomeUserAddressLoaded ||
//           current is HomeAddressCreated ||
//           current is HomeAddressUpdated,
//       builder: (context, state) {
//         // Extract address from state
//         String addressText = 'Select Address';
//         if (state is HomeUserAddressLoaded) {
//           addressText =
//               '${state.address.streetNumber} ${state.address.streetName}';
//         } else if (state is HomeAddressCreated) {
//           addressText =
//               '${state.address.streetNumber} ${state.address.streetName}';
//         } else if (state is HomeAddressUpdated) {
//           addressText =
//               '${state.address.streetNumber} ${state.address.streetName}';
//         }

//         return GestureDetector(
//           onTap: () {
//             // Navigate to address selection/update screen
//             // This could be implemented with GoRouter or Navigator
//           },
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               context.iconMedium(
//                   icon: Icons.location_on, color: context.textPrimaryColor),
//               SizedBox(width: context.xxsWidth),
//               SizedBox(
//                 width: context.getResponsiveWidthValue(100),
//                 child: Text(
//                   addressText,
//                   style: context.appBarTitle,
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                 ),
//               ),
//               context.iconMedium(
//                   icon: Icons.keyboard_arrow_down,
//                   color: context.textPrimaryColor),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildActionIcons(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         IconButton(
//           icon: context.iconMedium(
//               icon: Icons.shopping_cart_outlined,
//               color: context.textPrimaryColor),
//           onPressed: () {},
//           padding: EdgeInsets.all(context.xsWidth),
//         ),
//         IconButton(
//           icon: context.iconMedium(
//               icon: Icons.notifications_none, color: context.textPrimaryColor),
//           onPressed: () {},
//           padding: EdgeInsets.all(context.xsWidth),
//         ),
//         IconButton(
//           icon: context.iconMedium(
//               icon: Icons.person_outline, color: context.textPrimaryColor),
//           onPressed: () {},
//           padding: EdgeInsets.all(context.xsWidth),
//         ),
//       ],
//     );
//   }

//   Widget _buildSearchBarRow(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           // flex: 8,
//           child: _buildSearchBar(context),
//         ),
//         if (isCollapsed)
//           IconButton(
//             icon: context.iconMedium(
//                 icon: Icons.person, color: context.textPrimaryColor),
//             onPressed: () {},
//             padding: EdgeInsets.all(context.xsWidth),
//           ),
//       ],
//     );
//   }

//   Widget _buildSearchBar(BuildContext context) {
//     return BlocBuilder<HomeStoreBloc, HomeStoreState>(
//       buildWhen: (previous, current) =>
//           current.autocompleteSuggestionsState != previous.autocompleteSuggestionsState,
//       builder: (context, state) {
//         final suggestionsState = state.autocompleteSuggestionsState;
//         final hasSuggestions = suggestionsState is AutocompleteSuggestionsLoaded && 
//                               suggestionsState.suggestions.isNotEmpty;
        
//         return Material(
//           color: context.surfaceColor,
//           borderRadius: BorderRadius.circular(context.borderRadiusXLargeWidth),
//           child: SizedBox(
//             height: context.buttonHeightMediumWidth,
//             child: Row(
//               children: [
//                 Padding(
//                   padding: EdgeInsets.only(left: context.mWidth),
//                   child: context.iconMedium(
//                       icon: Icons.search, color: context.textSecondaryColor),
//                 ),
//                 Expanded(
//                   child: TextField(
//                     decoration: InputDecoration(
//                       hintText: 'Search products...',
//                       hintStyle: context.appBarTitle.copyWith(
//                         color: context.textSecondaryColor,
//                       ),
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.symmetric(
//                           vertical: context.sWidth,
//                           horizontal: context.xsWidth),
//                       isDense: true,
//                       // Show autocomplete suggestions if available
//                       suffixIcon: hasSuggestions
//                           ? Icon(Icons.arrow_drop_down,
//                               color: context.textSecondaryColor)
//                           : null,
//                     ),
//                     style: context.bodyMedium.copyWith(
//                       color: context.textPrimaryColor,
//                     ),
//                     onChanged: (query) {
//                       if (query.length >= 2) {
//                         // Trigger autocomplete suggestions
//                         context.read<HomeStoreBloc>().add(
//                               HomeStoreSearchQueryChangedEvent(query: query),
//                             );
//                       }
//                     },
//                     onSubmitted: (query) {
//                       if (query.isNotEmpty) {
//                         // Trigger search with submitted query
//                         context.read<HomeStoreBloc>().add(
//                               HomeStoreSearchSubmittedEvent(query: query),
//                             );
//                         // You could navigate to search results page here
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
