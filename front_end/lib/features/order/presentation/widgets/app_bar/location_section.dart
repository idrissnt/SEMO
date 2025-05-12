import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/features/order/presentation/bloc/user_address/user_address_bloc.dart';
import 'package:semo/features/order/presentation/bloc/user_address/user_address_state.dart';
import 'package:semo/features/order/presentation/constant/constants.dart';

/// Widget that displays the user's current location with an icon
class LocationSection extends StatelessWidget {
  /// Callback when the location icon or address text is tapped
  final VoidCallback onLocationTap;

  const LocationSection({Key? key, required this.onLocationTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderUserAddressBloc, OrderUserAddressState>(
      builder: (context, state) {
        // Default address text from screenshot
        String addressText = OrderConstants.defaultLocationText;

        // Update with actual address if available
        if (state is OrderUserAddressLoaded) {
          final address = state.address;
          // Format the address - assuming these fields are non-nullable
          addressText = '${address.streetNumber} ${address.streetName}';
        }

        return SizedBox(
          height: OrderConstants.searchBarHeight,
          width: OrderConstants.addressSizedBoxWidth,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              onLocationTap();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_outlined,
                    color: AppColors.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(addressText,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: AppFontSize.medium,
                          color: AppColors.textPrimaryColor,
                          fontWeight: FontWeight.bold)),
                ),
                const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.iconColorFirstColor),
              ],
            ),
          ),
        );
      },
    );
  }
}
