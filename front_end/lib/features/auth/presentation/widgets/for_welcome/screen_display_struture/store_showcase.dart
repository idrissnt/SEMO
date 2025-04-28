import 'package:flutter/material.dart';

import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/presentation/theme/theme_services/app_colors.dart';
import 'package:semo/core/presentation/theme/theme_services/app_dimensions.dart';

import 'package:semo/features/auth/presentation/widgets/for_welcome/components/store/store_image_builder.dart';
import 'package:semo/features/auth/presentation/widgets/for_welcome/components/shared/showcase_title.dart';
import 'package:semo/features/auth/presentation/widgets/for_welcome/components/store/store_content_builder.dart';

import 'package:semo/features/auth/presentation/widgets/for_welcome/screen_display_struture/utils/base_store_task_showcase.dart';
import 'package:semo/features/auth/presentation/widgets/for_welcome/styles/company_and_store_theme.dart';

import 'package:semo/features/auth/domain/entities/welcom_entity.dart';

final AppLogger logger = AppLogger();

Widget buildStoreCard(BuildContext context, StoreAsset storeAsset) {
  return Card(
    color: AppColors.secondary,
    elevation: 4,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.xxl)),
    child: Builder(builder: (context) {
      final data = StoreContentBuilder.build(context, storeAsset);
      return StoreShowcase(
        allStoresLogo: data['allStoresLogo'],
        cardTitleOne: data['cardTitleOne'],
        cardTitleTwo: data['cardTitleTwo'],
        storeTitle: data['storeTitle'],
      );
    }),
  );
}

class StoreShowcase extends StatelessWidget {
  final List<String> allStoresLogo;
  final String cardTitleOne;
  final String cardTitleTwo;
  final String storeTitle;

  const StoreShowcase({
    Key? key,
    required this.allStoresLogo,
    required this.cardTitleOne,
    required this.cardTitleTwo,
    required this.storeTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseShowcase(
      padding: EdgeInsets.symmetric(
        vertical: AppDimensionsHeight.xl,
        horizontal: AppDimensionsWidth.xSmall,
      ),
      // Title section
      titleSection: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          showcaseTitle(cardTitleOne, AppColors.textPrimaryColor),
          showcaseTitle(cardTitleTwo, WelcomeDimensions.secondTitleColor),
        ],
      ),
      // Content section
      contentSection: SizedBox(
        height: WelcomeDimensions.storeSectionHeight,
        child: StoreSection(
          titleSize: WelcomeDimensions.storeSectionTitleSize,
          allStoresLogo: allStoresLogo,
          storeTitle: storeTitle,
          storeContainerHeight: WelcomeDimensions.storeContainerHeight,
          storeImageSize: WelcomeDimensions.storeImageSize,
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
