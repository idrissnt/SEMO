// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/presentation/widgets/welcome/components/auth_buttons.dart';
import 'package:semo/features/auth/presentation/widgets/welcome/components/store/store_image_builder.dart';

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
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: context.xxLargeHeight, horizontal: context.sWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Card Store Title Section
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: context.headline1,
              children: [
                TextSpan(
                  text: cardTitleOne,
                  style: TextStyle(
                    color: context.textPrimaryColor,
                  ),
                ),
                TextSpan(
                  text: ' $cardTitleTwo',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Store Section
          SizedBox(
            height: context.getResponsiveHeightValue(150),
            child: StoreSection(
                allStoresLogo: allStoresLogo,
                storeTitle: storeTitle,
                sectionHeight: context.getResponsiveHeightValue(150)),
          ),
          // Authentication buttons Section
          const AuthButtons(),
        ],
      ),
    );
  }
}

class StoreSection extends StatelessWidget {
  final List<String> allStoresLogo;
  final double sectionHeight;
  final String storeTitle;

  const StoreSection(
      {Key? key,
      required this.allStoresLogo,
      required this.sectionHeight,
      required this.storeTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double containerHeight = context.getResponsiveHeightValue(80);
    double imageSize = context.getResponsiveHeightValue(45);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Store Title
        Text(storeTitle, style: context.appBarTitle),

        // Store Container
        Container(
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(context.borderRadiusMediumWidth),
          ),
          height: containerHeight,

          // Store List
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: context.xsWidth),
            itemCount: allStoresLogo.length,
            itemBuilder: (context, index) {
              final storeLogo = allStoresLogo[index];

              // Store Image
              return Center(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: context.sWidth),
                  child: StoreImage(storeLogo: storeLogo, size: imageSize),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
