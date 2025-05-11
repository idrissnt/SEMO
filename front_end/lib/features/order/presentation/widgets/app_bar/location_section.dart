import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/features/order/presentation/bloc/user_address/user_address_bloc.dart';
import 'package:semo/features/order/presentation/bloc/user_address/user_address_state.dart';
import 'package:semo/features/order/presentation/constant/constants.dart';
import 'package:semo/features/order/presentation/widgets/app_bar/utils/action_icon_button.dart';

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

        return Row(
          // Set mainAxisSize to min to prevent unbounded width error
          mainAxisSize: MainAxisSize.min,
          children: [
            // Location icon
            ActionIconButton(
              icon: Icons.location_on_outlined,
              color: AppColors.primary,
              size: AppIconSize.large,
              onPressed: onLocationTap,
            ),
            // Use Material's InkWell with better tap area
            Material(
              color: AppColors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                onTap: onLocationTap,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: AppDimensionsHeight.small),
                  child: Row(
                    children: [
                      // Address text
                      SizedBox(
                        width: OrderConstants
                            .addressSizedBoxWidth, // Fixed width for long addresses
                        child: Text(
                          addressText,
                          style: TextStyle(
                            fontSize: AppFontSize.medium,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      // Down arrow icon
                      ActionIconButton(
                        icon: Icons.keyboard_arrow_down,
                        color: AppColors.iconColorFirstColor,
                        size: AppIconSize.large,
                        onPressed: onLocationTap,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
