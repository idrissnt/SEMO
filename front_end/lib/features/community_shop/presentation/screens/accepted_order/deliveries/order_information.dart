import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/widgets/filters/category_filters.dart';
import 'package:semo/core/presentation/widgets/icons/app_icon.dart';
import 'package:semo/core/presentation/widgets/utils/address_copy.dart';
import 'package:semo/core/presentation/widgets/utils/divider.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/shared/note.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/utils/button.dart';
import 'package:semo/features/community_shop/presentation/screens/widgets/icon_button.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';

import 'package:semo/core/utils/logger.dart';

final AppLogger _logger = AppLogger();

class DeliveryOrderInformationScreen extends StatefulWidget {
  final List<CommunityOrder> orders;
  const DeliveryOrderInformationScreen({Key? key, required this.orders})
      : super(key: key);

  @override
  State<DeliveryOrderInformationScreen> createState() =>
      _DeliveryOrderInformationScreenState();
}

class _DeliveryOrderInformationScreenState
    extends State<DeliveryOrderInformationScreen> {
  int _selectedCategoryIndex = 0;
  final ScrollController _filtersScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _logger.info(
        '${widget.orders.length} voison${widget.orders.length > 1 ? 's' : ''} à livrer');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          '${widget.orders.length} voison${widget.orders.length > 1 ? 's' : ''} à livrer',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryColor,
            decoration: TextDecoration.none,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 20, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: buildIconButton(
                CupertinoIcons.chat_bubble_text, Colors.black, Colors.white),
            onPressed: () {
              // Handle message action
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Pinned filters at the top
              SliverAppBar(
                pinned: true,
                floating: true,
                surfaceTintColor: Colors.transparent,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                elevation: 0,
                toolbarHeight: 40,
                flexibleSpace: TopFilters(
                  filters:
                      widget.orders.map((order) => order.customerName).toList(),
                  selectedIndex: _selectedCategoryIndex,
                  scrollController: _filtersScrollController,
                  onFilterTap: (index) {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Address
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8),
                      child: Expanded(
                        child: Row(
                          children: [
                            appIcon(
                              icon: const Icon(Icons.location_on,
                                  size: 24, color: Colors.white),
                              iconContainerColor: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.orders[_selectedCategoryIndex]
                                    .deliveryAddress,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textPrimaryColor,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              tooltip: 'Copier l\'adresse',
                              onPressed: () => copyAddressToClipboard(
                                  context,
                                  widget.orders[_selectedCategoryIndex]
                                      .deliveryAddress),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Delivery time
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.timer, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'environ 20 minutes',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    divider(),
                    // Enter code
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12),
                      child: _buildEnterCode(),
                    ),
                    divider(),
                    // Map
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12),
                      child: _buildMap(),
                    ),
                    divider(),
                    // Recent orders
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12),
                      child: _buildOrdersSummary(widget.orders.first),
                    ),
                    divider(),
                    // Note from customer
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12),
                      child: _buildNoteFromCustomer(context),
                    ),
                    const SizedBox(height: 200),
                  ],
                ),
              ),
            ],
          ),
          buildBottomActionBar(
            context,
            'Je suis arrivé',
            onPressed: () {},
          )
        ],
      ),
    );
  }

  Widget _buildEnterCode() {
    return Column(
      children: [
        Text(
          '${widget.orders[_selectedCategoryIndex].customerName} vous communiquera le code de vérification, entrez le ci-dessous',
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimaryColor,
              decoration: TextDecoration.none),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: PinCodeTextField(
            appContext: context,
            length: 4,
            obscureText: false,
            animationType: AnimationType.none,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.underline,
              borderRadius: BorderRadius.circular(5),
              fieldHeight: 30,
              fieldWidth: 60,
              activeFillColor: Colors.transparent,
              inactiveFillColor: Colors.transparent,
              selectedFillColor: Colors.transparent,
              activeColor: Colors.black,
              inactiveColor: Colors.grey.shade300,
              selectedColor: Colors.black,
            ),
            cursorColor: Colors.black,
            backgroundColor: Colors.transparent,
            enableActiveFill: false,
            onChanged: (value) {},
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            setState(() {});
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Valider'),
        ),
      ],
    );
  }

  Widget _buildMap() {
    return Material(
      color: Colors.transparent,
      child: ElevatedButton(
        onPressed: () {
          // Add your button action here
          // print('Map button tapped');
          // Add haptic feedback for physical response
          HapticFeedback.mediumImpact();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.background,
          foregroundColor: Colors.black54,
          elevation: 2,
          shadowColor: Colors.grey,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          children: [
            appIcon(
              icon: const Icon(Icons.map, size: 24, color: Colors.black),
              iconContainerColor: const Color.fromARGB(255, 213, 213, 213),
            ),
            const SizedBox(width: 8),
            // Use Expanded to make the text take available space and prevent overflow
            const Expanded(
              child: Text(
                'Utiliser le GPS intégré',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimaryColor,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            // Add a small gap between text and icon
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios_sharp,
                size: 24, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersSummary(CommunityOrder order) {
    // Mock recent orders
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${order.totalItems} articles',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ...order.productImageUrls
                      .take(3)
                      .map((productImageUrl) => Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(productImageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ))
                      .toList(),
                  if (order.productImageUrls.length > 3)
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                        shape: const CircleBorder(),
                        minimumSize: const Size(40, 40),
                      ),
                      child: Text(
                        '+${order.productImageUrls.length - 3}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteFromCustomer(BuildContext context) {
    return Note(
      title: 'Note',
      description:
          'Veillez déposer les articles devant la porte de l\'immeuble',
      iconBackgroundColor: const Color.fromARGB(255, 240, 198, 11),
      icon: const Icon(Icons.edit_document, color: Colors.white),
      onCameraTap: () {},
    );
  }
}
