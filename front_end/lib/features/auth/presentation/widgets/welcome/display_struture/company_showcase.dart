import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/theme_services/app_colors.dart';
import 'package:semo/core/presentation/theme/theme_services/app_dimensions.dart';
import 'package:semo/features/auth/presentation/widgets/welcome/styles/company_and_store_theme.dart';

class CompanyShowcase extends StatelessWidget {
  const CompanyShowcase({
    Key? key,
    required this.companyLogo,
    required this.companyName,
  }) : super(key: key);

  final String companyLogo;
  final String companyName;

  @override
  Widget build(BuildContext context) {
    final double logoSize = WelcomeDimensions.companyLogoSize;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Company logo
        ClipRRect(
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
          child: Image.network(
            companyLogo,
            width: logoSize,
            height: logoSize,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildLoadingIndicator(loadingProgress);
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackIcon(context, logoSize);
            },
          ),
        ),
        // Company name
        SizedBox(width: AppDimensionsWidth.xSmall),
        Text(
          companyName,
          style: TextStyle(
            fontSize: WelcomeDimensions.companyNameSize,
            color: AppColors.textSecondaryColor,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFallbackIcon(BuildContext context, double size) {
    return Icon(
      Icons.store,
      size: size,
      color: AppColors.secondaryVariant,
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
}
