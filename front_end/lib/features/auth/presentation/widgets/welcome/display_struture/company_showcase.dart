import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';

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
    final double logoSize = context.getResponsiveWidthValue(50);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Company logo
        ClipRRect(
          borderRadius: BorderRadius.circular(context.borderRadiusMediumWidth),
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
        SizedBox(width: context.mWidth),
        Text(
          companyName,
          style: context.semoWelcome.copyWith(
            color: context.secondaryColor,
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
      color: context.textSecondaryColor,
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
