// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/theme_services/app_colors.dart';
import 'package:semo/core/presentation/theme/theme_services/app_dimensions.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/presentation/widgets/welcome/components/auth_buttons.dart';
import 'package:semo/features/auth/presentation/widgets/welcome/components/store/store_image_builder.dart';
import 'package:semo/features/auth/presentation/widgets/welcome/styles/company_and_store_theme.dart';

final AppLogger logger = AppLogger();

class StoreShowcase extends StatelessWidget {
  final List<String> allStoresLogo;
  final String cardTitleOne;
  final String cardTitleTwo;
  final String storeTitle;

  const StoreShowcase(
      {Key? key,
      required this.allStoresLogo,
      required this.cardTitleOne,
      required this.cardTitleTwo,
      required this.storeTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: AppDimensionsHeight.xl,
            horizontal: AppDimensionsWidth.xSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Card Store Title Section
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                cardTitleText(cardTitleOne, AppColors.textPrimaryColor),
                cardTitleText(cardTitleTwo, WelcomeDimensions.secondTitleColor),
              ],
            ),
            // Store Section
            SizedBox(
              height: WelcomeDimensions.storeSectionHeight,
              child: StoreSection(
                  titleSize: WelcomeDimensions.storeSectionTitleSize,
                  allStoresLogo: allStoresLogo,
                  storeTitle: storeTitle,
                  storeContainerHeight: WelcomeDimensions.storeContainerHeight,
                  storeImageSize: WelcomeDimensions.storeImageSize),
            ),
            // Authentication buttons Section
            const AuthButtons(),
          ],
        ),
      ),
    );
  }
}

class StoreSection extends StatelessWidget {
  final List<String> allStoresLogo;
  final double titleSize;
  final double storeContainerHeight;
  final double storeImageSize;
  final String storeTitle;

  const StoreSection(
      {Key? key,
      required this.titleSize,
      required this.allStoresLogo,
      required this.storeContainerHeight,
      required this.storeImageSize,
      required this.storeTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Store Title
        Text(storeTitle,
            style: TextStyle(
                fontSize: titleSize, color: AppColors.textPrimaryColor)),

        // Store Container
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          ),
          height: storeContainerHeight,

          // Store Logo List
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            padding:
                EdgeInsets.symmetric(horizontal: AppDimensionsWidth.xSmall),
            itemCount: allStoresLogo.length,
            itemBuilder: (context, index) {
              final storeLogo = allStoresLogo[index];

              // Store Image
              return Center(
                child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: AppDimensionsWidth.xSmall),
                  child: StoreImage(storeLogo: storeLogo, size: storeImageSize),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
