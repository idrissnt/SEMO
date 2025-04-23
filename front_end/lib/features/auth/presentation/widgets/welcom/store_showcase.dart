// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/router_services/route_constants.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/home/presentation/bloc/home_store/home_store_bloc.dart';
import 'package:semo/features/home/presentation/bloc/home_store/home_store_state.dart';
import 'package:semo/features/store/domain/entities/store.dart';

final AppLogger logger = AppLogger();

Widget buildStoreCard(BuildContext context) {
  return Card(
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(33)),
    child: SizedBox(
      width: context.responsiveItemSize(300),
      child: Padding(
        padding: const EdgeInsets.only(
            top: 40.0, bottom: 40.0, left: 15.0, right: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: context.headline1,
                children: const [
                  TextSpan(
                    text: 'Vos courses livrées\n en',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: ' 1 heure',
                    style: TextStyle(
                      color: Color.fromARGB(255, 243, 33, 33),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            BlocBuilder<HomeStoreBloc, HomeStoreState>(
              builder: (context, state) {
                if (state is StoreBrandsLoaded &&
                    state.storeBrands.isNotEmpty) {
                  return SizedBox(
                      height: 80,
                      child: StoreSection(
                          stores: state.storeBrands, sectionHeight: 80));
                }
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Loading stores...',
                    style: TextStyle(color: Colors.black),
                  ),
                );
              },
            ),
            buildButtons(context, AppRoutes.register, AppRoutes.login,
                'Créer un compte', 'Se connecter'),
          ],
        ),
      ),
    ),
  );
}

class StoreSection extends StatelessWidget {
  final List<StoreBrand> stores;
  final double sectionHeight;

  const StoreSection(
      {Key? key, required this.stores, required this.sectionHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) {
      return const SizedBox.shrink();
    }

    double imageSize = sectionHeight - sectionHeight * 0.2;

    return SizedBox(
      height: sectionHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: context.xs),
        itemCount: stores.length,
        itemBuilder: (context, index) {
          final store = stores[index];
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.m),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StoreImageButton(store: store, size: imageSize),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class StoreImageButton extends StatelessWidget {
  final StoreBrand store;
  final double size;
  static final AppLogger _logger = AppLogger();

  const StoreImageButton({
    Key? key,
    required this.store,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: store.imageLogo.isNotEmpty
          ? _buildStoreImage(context, size)
          : _buildFallbackIcon(context, size),
    );
  }

  Widget _buildStoreImage(BuildContext context, double size) {
    //
    logger.info('Store image: ${store.imageLogo}');

    return Image.network(
      store.imageLogo,
      fit: BoxFit.cover,
      width: size,
      height: size,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingIndicator(loadingProgress);
      },
      errorBuilder: (context, error, stackTrace) {
        _logger.error('Error loading store image: $error');
        return _buildFallbackIcon(context, size);
      },
    );
  }

  Widget _buildLoadingIndicator(ImageChunkEvent loadingProgress) {
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  }

  Widget _buildFallbackIcon(BuildContext context, double size) {
    return Icon(
      Icons.store,
      size: size,
      color: context.textSecondaryColor,
    );
  }
}

Widget buildButtons(BuildContext context, String registerRoute,
    String loginRoute, String registerText, String loginText) {
  return Column(
    children: [
      ElevatedButton(
        onPressed: () => context.go(registerRoute),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
          minimumSize: const Size(0, 50),
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
        ),
        child: SizedBox(
          width: context.responsiveItemSize(250),
          child: Text(
            registerText,
            textAlign: TextAlign.center,
            style: context.bodyLarge.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      OutlinedButton(
        onPressed: () => context.go(loginRoute),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
          minimumSize: const Size(0, 50),
          backgroundColor: const Color.fromARGB(255, 234, 232, 232),
          disabledForegroundColor: Colors.white,
        ),
        child: SizedBox(
          width: context.responsiveItemSize(250),
          child: Text(
            loginText,
            textAlign: TextAlign.center,
            style: context.bodyLarge.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        ),
      )
    ],
  );
}
