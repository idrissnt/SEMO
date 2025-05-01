import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/features/home/presentation/bloc/user_address/user_address_bloc.dart';
import 'package:semo/features/home/presentation/bloc/user_address/user_address_state.dart';
import 'package:semo/features/home/presentation/constant/home_constants.dart';
import 'package:semo/features/home/presentation/widgets/app_bar/utils/action_icon_button.dart';

/// Widget that displays the user's current location with an icon
class LocationSection extends StatelessWidget {
  const LocationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeUserAddressBloc, HomeUserAddressState>(
      builder: (context, state) {
        // Default address text from screenshot
        String addressText = HomeConstants.defaultLocationText;

        // Update with actual address if available
        if (state is HomeUserAddressLoaded) {
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
              onPressed: () {
                // Handle location icon tap
              },
            ),
            // Use Material's InkWell with better tap area
            Material(
              color: AppColors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                onTap: () {
                  // Handle address tap
                },
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: AppDimensionsHeight.small),
                  child: Row(
                    children: [
                      // Address text
                      SizedBox(
                        width: HomeConstants
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
                        onPressed: () {
                          // Handle down arrow tap
                        },
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
