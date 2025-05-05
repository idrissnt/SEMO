import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_constant.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/core/presentation/widgets/buttons/button_factory.dart';

import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:semo/features/home/presentation/full_screen_bottom_sheet/bottom_sheet_navigator.dart';
import 'package:semo/features/home/routes/bottom_sheet/bottom_sheet_routes_constants.dart';

/// A bottom sheet that prompts the user to verify their email address
/// This is designed to be shown as a modal bottom sheet after registration
class VerifyEmailBottomSheet extends StatefulWidget {
  final ScrollController? scrollController;

  const VerifyEmailBottomSheet({Key? key, this.scrollController})
      : super(key: key);

  @override
  State<VerifyEmailBottomSheet> createState() => _VerifyEmailBottomSheetState();
}

class _VerifyEmailBottomSheetState extends State<VerifyEmailBottomSheet> {
  // Key for the bottom sheet navigator
  final _navigatorKey = GlobalKey<BottomSheetNavigatorState>();

  // Get user email from the AuthBloc state
  String _getUserEmail() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.email;
    }
    return '';
  }

  // Navigate to the address screen
  void _navigateToAddressScreen() {
    _navigatorKey.currentState?.navigateTo(BottomSheetRoutesConstants.address);
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetNavigator(
      key: _navigatorKey,
      initialPage: _buildVerificationPage(),
    );
  }

  // The main verification page
  Widget _buildVerificationPage() {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Vérification d'email",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                    decoration: TextDecoration.none,
                  ),
                ),
                _buildSkipButton(),
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
                controller: widget.scrollController,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email verification content
                    _buildVerificationContent(),

                    const SizedBox(height: 40),
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

  Widget _buildVerificationContent() {
    final userEmail = _getUserEmail();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        // Explanation text

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimaryColor,
                ),
                children: [
                  const TextSpan(
                      text:
                          'Nous voulons nous rassurer que votre compte est sécurisé, un code a 6 chiffres a été envoyé à '),
                  TextSpan(
                    text: userEmail,
                    style: const TextStyle(
                        color: AppColors.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Entrez le code',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimaryColor,
                    decoration: TextDecoration.none),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: false,
                animationType: AnimationType.none,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.underline,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 30,
                  fieldWidth: 40,
                  activeFillColor: Colors.transparent,
                  inactiveFillColor: Colors.transparent,
                  selectedFillColor: Colors.transparent,
                  activeColor: Colors.black,
                  inactiveColor: Colors.grey.shade300,
                  selectedColor: Colors.black,
                ),
                cursorColor: Colors.black,
                backgroundColor: Colors.transparent,
                enableActiveFill: false,
                onChanged: (value) {},
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Instructions
        const Text(
          'Vous ne voyez pas le code dans votre boite mail? veuillez vérifier vos spam.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryColor,
            decoration: TextDecoration.none,
          ),
        ),

        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildResendButton(),
          ],
        ),

        const SizedBox(height: 24),
        ButtonFactory.createAnimatedButton(
          context: context,
          onPressed: _navigateToAddressScreen,
          text: 'Valider',
          backgroundColor: AppColors.primary,
          textColor: AppColors.secondary,
          splashColor: AppColors.primary,
          highlightColor: AppColors.primary,
          boxShadowColor: AppColors.primary,
          minWidth: AppButtonDimensions.minWidth,
          minHeight: AppButtonDimensions.minHeight,
          verticalPadding: AppDimensionsWidth.xSmall,
          horizontalPadding: AppDimensionsHeight.small,
          borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
          animationDuration:
              Duration(milliseconds: AppConstant.buttonAnimationDurationMs),
          enableHapticFeedback: true,
          textStyle: TextStyle(
            fontSize: AppFontSize.large,
            fontWeight: FontWeight.w800,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  TextButton _buildResendButton() {
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
      icon: Icon(
        Icons.refresh,
        color: AppColors.primary,
        size: AppIconSize.medium,
      ),
      label: Text('Recevoir un nouveau code',
          style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: AppFontSize.small)),
    );
  }

  TextButton _buildSkipButton() {
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
      onPressed: _navigateToAddressScreen,
      icon: Icon(
        Icons.arrow_forward,
        color: AppColors.iconColorFirstColor,
        size: AppIconSize.medium,
      ),
      label: Text('Passer',
          style: TextStyle(
              color: AppColors.textPrimaryColor,
              fontWeight: FontWeight.w600,
              fontSize: AppFontSize.small)),
    );
  }
}
