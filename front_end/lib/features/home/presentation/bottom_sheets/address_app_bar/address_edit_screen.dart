import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_constant.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/core/presentation/widgets/buttons/button_factory.dart';
import 'package:semo/features/home/routes/bottom_sheet/app_bar_address/routes_constants.dart';

/// A screen for editing user address information
/// This is designed to be used as a nested route within the address bottom sheet
class AddressEditScreen extends StatefulWidget {
  const AddressEditScreen({Key? key}) : super(key: key);

  @override
  State<AddressEditScreen> createState() => _AddressEditScreenState();
}

class _AddressEditScreenState extends State<AddressEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _streetNumberController = TextEditingController(text: '123');
  final _streetNameController = TextEditingController(text: 'Rue de la joie');
  final _cityController = TextEditingController(text: 'Nancy');
  final _zipCodeController = TextEditingController(text: '54000');
  final _countryController = TextEditingController(text: 'France');

  @override
  void dispose() {
    _streetNumberController.dispose();
    _streetNameController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),

          // Title with back button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () =>
                      context.go(AppBarAddressRoutesConstants.root),
                ),
                const Text(
                  "Modifier votre adresse",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),

          // Form content
          Expanded(
            child: Scrollbar(
              thickness: 6,
              radius: const Radius.circular(10),
              thumbVisibility: true,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Veuillez mettre à jour votre adresse",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimaryColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Street number + name

                      TextFormField(
                        controller: _streetNumberController,
                        decoration: InputDecoration(
                          labelText: 'N°',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(AppBorderRadius.small),
                            ),
                          ),
                          prefixIcon: const Icon(Icons.pin),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'N° requis';
                          }
                          try {
                            int.parse(value);
                          } catch (e) {
                            return 'Nombre requis';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _streetNameController,
                        decoration: InputDecoration(
                          labelText: 'Rue',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(AppBorderRadius.small),
                            ),
                          ),
                          prefixIcon: const Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Rue requise';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // City
                      TextFormField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          labelText: 'Ville',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(AppBorderRadius.small),
                            ),
                          ),
                          prefixIcon: const Icon(Icons.location_city),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre ville';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Zip code
                      TextFormField(
                        controller: _zipCodeController,
                        decoration: InputDecoration(
                          labelText: 'Code postal',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(AppBorderRadius.small),
                            ),
                          ),
                          prefixIcon: const Icon(Icons.markunread_mailbox),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre code postal';
                          }
                          try {
                            int.parse(value);
                          } catch (e) {
                            return 'Nombre requis';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Country
                      TextFormField(
                        controller: _countryController,
                        decoration: InputDecoration(
                          labelText: 'Pays',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(AppBorderRadius.small),
                            ),
                          ),
                          prefixIcon: const Icon(Icons.flag),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre pays';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Submit button
                      Center(
                        child: ButtonFactory.createAnimatedButton(
                          context: context,
                          onPressed: () {},
                          text: 'Enregistrer',
                          backgroundColor: AppColors.primary,
                          textColor: AppColors.secondary,
                          splashColor: AppColors.primary,
                          highlightColor: AppColors.primary,
                          boxShadowColor: AppColors.primary,
                          minWidth: AppButtonDimensions.minWidth,
                          minHeight: AppButtonDimensions.minHeight,
                          verticalPadding: AppDimensionsWidth.xSmall,
                          horizontalPadding: AppDimensionsHeight.small,
                          borderRadius:
                              BorderRadius.circular(AppBorderRadius.xxl),
                          animationDuration: Duration(
                              milliseconds:
                                  AppConstant.buttonAnimationDurationMs),
                          enableHapticFeedback: true,
                          textStyle: TextStyle(
                            fontSize: AppFontSize.large,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
