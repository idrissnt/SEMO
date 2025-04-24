import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_state.dart';
import 'package:semo/features/auth/presentation/widgets/welcome/display_struture/company_showcase.dart';
import 'package:semo/features/auth/presentation/widgets/welcome/utils/retry_loader.dart';

Widget buildCompanyAsset(BuildContext context) {
  return BlocBuilder<WelcomeAssetsBloc, WelcomeAssetsState>(
    builder: (context, state) {
      if (state is AllAssetsLoaded) {
        return CompanyShowcase(
          companyLogo: state.companyAsset.logoUrl,
          companyName: state.companyAsset.companyName,
        );
      } else if (state is AllAssetsLoading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else {
        RetryLoader.scheduleRetryLoad(context);
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    },
  );
}
