import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_state.dart';
import 'package:semo/features/auth/presentation/widgets/welcome/components/store/store_content_builder.dart';
import 'package:semo/features/auth/presentation/widgets/welcome/display_struture/store_showcase.dart';
import 'package:semo/features/auth/presentation/widgets/welcome/utils/retry_loader.dart';

final AppLogger logger = AppLogger();

Widget buildStoreCard(BuildContext context) {
  return Card(
    color: context.secondaryColor,
    elevation: 4,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.borderRadiusXXLargeWidth)),
    child: SizedBox(
      child: BlocBuilder<WelcomeAssetsBloc, WelcomeAssetsState>(
        builder: (context, state) {
          if (state is AllAssetsLoaded) {
            // Successfully loaded with store assets
            final data = StoreContentBuilder.build(context, state.storeAsset);
            return StoreShowcase(
              allStoresLogo: data['allStoresLogo'],
              cardTitleOne: data['cardTitleOne'],
              cardTitleTwo: data['cardTitleTwo'],
              storeTitle: data['storeTitle'],
            );
          } else if (state is AllAssetsLoading) {
            // Loading state
            logger.info('Store assets loading...');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: context.primaryColor),
                  SizedBox(height: context.largeHeight),
                  Text('Loading assets...',
                      style: TextStyle(color: context.textPrimaryColor)),
                ],
              ),
            );
          } else {
            // Error or other states
            logger.info('Unknown state: ${state.runtimeType}');
            RetryLoader.scheduleRetryLoad(context);

            // Create a placeholder grid
            return const StoreShowcase(
              allStoresLogo: [],
              cardTitleOne: '',
              cardTitleTwo: '',
              storeTitle: '',
            );
          }
        },
      ),
    ),
  );
}
