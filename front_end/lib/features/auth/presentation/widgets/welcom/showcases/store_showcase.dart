// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/presentation/widgets/welcom/components/auth_buttons.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: context.headline1,
              children: [
                TextSpan(
                  text: cardTitleOne,
                  style: TextStyle(
                    color: Colors.black,
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
          SizedBox(
            height: 200,
            child: StoreSection(
                allStoresLogo: allStoresLogo,
                storeTitle: storeTitle,
                sectionHeight: 80),
          ),
          // Authentication buttons
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
    // Calculate a safe image size based on the container height
    double containerHeight = 100;
    double imageSize = 60;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(storeTitle,
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.normal)),
        Container(
          decoration: BoxDecoration(
            // color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          height: containerHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: context.xs),
            itemCount: allStoresLogo.length,
            itemBuilder: (context, index) {
              final storeLogo = allStoresLogo[index];
              return Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child:
                      StoreImageButton(storeLogo: storeLogo, size: imageSize),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class StoreImageButton extends StatelessWidget {
  final String storeLogo;
  final double size;
  static final AppLogger _logger = AppLogger();

  const StoreImageButton({
    Key? key,
    required this.storeLogo,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: storeLogo.isNotEmpty
          ? _buildStoreImage(context, size)
          : _buildFallbackIcon(context, size),
    );
  }

  Widget _buildStoreImage(BuildContext context, double size) {
    //
    logger.info('Store image: $storeLogo');

    return Image.network(
      storeLogo,
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
