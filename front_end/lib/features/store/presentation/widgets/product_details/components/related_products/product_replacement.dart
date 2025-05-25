import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';

class ProductReplacementSection extends StatelessWidget {
  final String? routeNameAddNote;
  final VoidCallback? onTapAddNote;

  final String? routeNameAddReplacement;
  final VoidCallback? onTapAddReplacement;

  const ProductReplacementSection({
    Key? key,
    this.routeNameAddNote,
    this.onTapAddNote,
    this.routeNameAddReplacement,
    this.onTapAddReplacement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              'Un mot pour votre shopper',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          // Section content
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: buildReplacement(
              context: context,
              title: 'Ajouter un mot',
              routeName: routeNameAddNote,
              onTap: onTapAddNote,
              icon: const Icon(Icons.edit_document),
              iconContainerColor: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: buildReplacement(
              context: context,
              title: 'Si ce n\'est pas dispo, remplacer avec :',
              subtitle: 'Un produit similaire',
              routeName: routeNameAddReplacement,
              onTap: onTapAddReplacement,
              icon: const Icon(Icons.change_circle),
              iconContainerColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildReplacement({
  required BuildContext context,
  required String title,
  String? subtitle,
  required String? routeName,
  required VoidCallback? onTap,
  required Widget icon,
  required Color iconContainerColor,
}) {
  return InkWell(
    onTap:
        onTap ?? (routeName != null ? () => context.goNamed(routeName) : null),
    child: Padding(
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
      child: Row(
        children: [
          // icon
          icon,
          const SizedBox(width: 6),
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
        ],
      ),
    ),
  );
}
