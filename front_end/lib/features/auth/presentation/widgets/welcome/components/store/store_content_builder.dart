import 'package:flutter/material.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/domain/entities/welcom_entity.dart';

/// Logger instance for the store content builder
final AppLogger logger = AppLogger();

/// Builds content when store assets are loaded
class StoreContentBuilder {
  /// Builds the store asset content for the store showcase grid
  static Map<String, dynamic> build(
      BuildContext context, StoreAsset storeAsset) {
    // Log summary of store assets for debugging
    logger.info('Processing store assets');

    // Organize assets by their purpose
    final cardTitleOne = storeAsset.cardTitleOne;
    final cardTitleTwo = storeAsset.cardTitleTwo;
    final storeTitle = storeAsset.storeTitle;
    final allStoresLogo = [
      storeAsset.storeLogoOneUrl,
      storeAsset.storeLogoTwoUrl,
      storeAsset.storeLogoThreeUrl
    ];
    logger.info('Get store assets successfully');
    return {
      'cardTitleOne': cardTitleOne,
      'cardTitleTwo': cardTitleTwo,
      'storeTitle': storeTitle,
      'allStoresLogo': allStoresLogo,
    };
  }
}
