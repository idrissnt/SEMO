import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_event.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_state.dart';
import 'package:semo/features/auth/presentation/widgets/welcom/components/store_content_builder.dart';
import 'package:semo/features/auth/presentation/widgets/welcom/showcases/store_showcase.dart';

final AppLogger logger = AppLogger();

Widget buildStoreCard(BuildContext context) {
  return Card(
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(33)),
    child: SizedBox(
      width: context.responsiveItemSize(300),
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
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blue),
                  SizedBox(height: 16),
                  Text('Loading assets...',
                      style: TextStyle(color: Colors.black)),
                ],
              ),
            );
          } else {
            // Error or other states
            logger.info('Unknown state: ${state.runtimeType}');
            _scheduleRetryLoad(context);

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

void _scheduleRetryLoad(BuildContext context) {
  Future.delayed(const Duration(seconds: 3), () {
    if (context.mounted) {
      context.read<WelcomeAssetsBloc>().add(const LoadAllAssetsEvent());
    }
  });
}
