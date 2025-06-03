import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/widgets/filters/category_filters.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/utils/button.dart';
import 'package:semo/features/community_shop/presentation/screens/widgets/icon_button.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/community_shop/presentation/widgets/delivery/direction_card_widget.dart';
import 'package:semo/features/community_shop/presentation/widgets/delivery/map_services_widget.dart';
import 'package:semo/features/community_shop/presentation/widgets/delivery/order_info_widget.dart';
import 'package:semo/features/community_shop/presentation/widgets/delivery/pin_code_widget.dart';

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
  final TextEditingController _pinCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _logger.info(
        '${widget.orders.length} voison${widget.orders.length > 1 ? 's' : ''} à livrer');
  }

  @override
  void dispose() {
    _filtersScrollController.dispose();
    _pinCodeController.dispose();
    super.dispose();
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
                    // PIN code entry
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 6),
                      child: PinCodeWidget(
                        controller: _pinCodeController,
                        onCompleted: (value) {
                          // Handle PIN code completion
                          _logger.info('PIN code completed: $value');
                        },
                      ),
                    ),

                    // Direction card with addresses
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 6),
                      child: DirectionCardWidget(
                        order: widget.orders[_selectedCategoryIndex],
                      ),
                    ),

                    // Map services navigation buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 6),
                      child: MapServicesWidget(
                        order: widget.orders[_selectedCategoryIndex],
                      ),
                    ),

                    // Order information and product images
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 6),
                      child: OrderInfoWidget(
                        order: widget.orders[_selectedCategoryIndex],
                      ),
                    ),

                    // Extra space at the bottom to account for the bottom action bar
                    const SizedBox(height: 200),
                  ],
                ),
              ),
            ],
          ),

          // Bottom action button
          buildBottomActionBar(
            context,
            'Je suis arrivé•e',
            onPressed: () {
              // Handle arrival action
              _logger.info('User arrived at delivery location');
            },
          )
        ],
      ),
    );
  }
}
