import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:semo/core/presentation/screens/image_viewer_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/widgets/filters/category_filters.dart';
import 'package:semo/core/presentation/widgets/utils/address_copy.dart';
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

  // Map service logos
  final List<String> mapsLogoData = [
    'https://www.apple.com/v/maps/d/images/overview/intro_icon__dfyvjc1ohbcm_large.png', // Apple Maps
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSC10aIGcrdtvbwpYkeboJsf9YXZ0K6cwbOMw&s', // Google Maps
    'https://cdn-1.webcatalog.io/catalog/waze/waze-icon-filled-256.png?v=1745800727973' // Waze
  ];

  // Map service names
  final List<String> mapServiceNames = ['Apple Maps', 'Google Maps', 'Waze'];

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
                    // Enter code
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 6),
                      child: _buildEnterCode(),
                    ),
                    // Direction card
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 6),
                      child: _buildDirectionCard(),
                    ),
                    // Maps services
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 6),
                      child: _buildMapServices(),
                    ),
                    // Order info
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 6),
                      child: _buildOrderInfo(),
                    ),
                    const SizedBox(height: 200),
                  ],
                ),
              ),
            ],
          ),
          buildBottomActionBar(
            context,
            'Je suis arrivé.e',
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
      ],
    );
  }

  Widget _buildOrdersSummary(CommunityOrder order) {
    return Row(
      children: [
        Icon(Icons.shopping_cart, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${order.totalItems} articles',
              ),
              const SizedBox(height: 4),
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
                      onPressed: () => _showProductImagesBottomSheet(order),
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
      ],
    );
  }

  Widget _buildDirectionCard() {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Itinéraire de livraison',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildAddressRow(
              icon: Icons.store,
              title: widget.orders[_selectedCategoryIndex].storeName,
              address: widget.orders[_selectedCategoryIndex].storeAddress,
              color: AppColors.primary,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 12),
              child: SizedBox(
                height: 20,
                child: VerticalDivider(
                  color: Colors.grey,
                  thickness: 1,
                  width: 20,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildAddressRow(
              icon: Icons.home,
              title: widget.orders[_selectedCategoryIndex].customerName,
              address: widget.orders[_selectedCategoryIndex].deliveryAddress,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapServices() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Commencez votre livraison avec',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                List.generate(3, (index) => _buildMapServiceButton(index)),
          ),
        ],
      ),
    );
  }

  Widget _buildMapServiceButton(int index) {
    return InkWell(
      onTap: () => _launchMapService(index),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.9),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                mapsLogoData[index],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.map, size: 40),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            mapServiceNames[index],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _launchMapService(int index) async {
    // Add haptic feedback
    HapticFeedback.mediumImpact();

    // Get the current selected order
    final order = widget.orders[_selectedCategoryIndex];
    final origin = Uri.encodeComponent(order.storeAddress);
    final destination = Uri.encodeComponent(order.deliveryAddress);

    String url;
    switch (index) {
      case 0: // Apple Maps
        url =
            'https://maps.apple.com/?saddr=$origin&daddr=$destination&dirflg=d';
        break;
      case 1: // Google Maps
        url =
            'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving';
        break;
      case 2: // Waze
        url = 'https://waze.com/ul?navigate=yes&from=$origin&to=$destination';
        break;
      default:
        url =
            'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving';
    }

    _logger.info('Launching map service: ${mapServiceNames[index]}');

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _logger.info('Could not launch ${mapServiceNames[index]}');
        // Show a snackbar or toast message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Impossible d\'ouvrir ${mapServiceNames[index]}')));
        }
      }
    } catch (e) {
      _logger.info('Error launching ${mapServiceNames[index]}: $e');
    }
  }

  Widget _buildAddressRow({
    required IconData icon,
    required String title,
    required String address,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 20),
          tooltip: 'Copier l\'adresse',
          onPressed: () => copyAddressToClipboard(context, address),
        ),
      ],
    );
  }

  Widget _buildOrderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations supplémentaires',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildOrdersSummary(widget.orders[_selectedCategoryIndex]),
        const SizedBox(height: 12),
        _buildInfoItem(
          icon: Icons.access_time,
          title: 'Temps de livraison estimé',
          value: '10 minutes',
        ),
        const SizedBox(height: 12),
        _buildInfoItem(
          icon: Icons.directions_car,
          title: 'Distance',
          value:
              '${widget.orders[_selectedCategoryIndex].distanceKm.toStringAsFixed(1)} km',
        ),
        const SizedBox(height: 12),
        _buildInfoItem(
          icon: Icons.phone,
          title: 'Téléphone',
          value: 'Non disponible', // Phone number not available in the model
        ),
        const SizedBox(height: 12),
        _buildInfoItem(
          icon: Icons.comment,
          title: 'Instructions',
          value: widget.orders[_selectedCategoryIndex].notes.isNotEmpty
              ? widget.orders[_selectedCategoryIndex].notes
              : 'Aucune instruction spécifique',
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showProductImagesBottomSheet(CommunityOrder order) {
    // Add haptic feedback for physical response
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Produits commandés : ${order.totalItems} (${order.productImageUrls.length} unités)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Grid of product images
            Expanded(
              child: GridView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: order.productImageUrls.length,
                itemBuilder: (context, index) {
                  return _buildProductImageCard(
                    order.productImageUrls[index],
                    'Ici va s\'afficher le nom du produit avec la quantité (kg, l, etc)',
                    index + 1,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImageCard(
      String imageUrl, String description, int quantity) {
    final String heroTag = 'product-image-$imageUrl-$quantity';

    return GestureDetector(
      onTap: () {
        // Add haptic feedback
        HapticFeedback.mediumImpact();

        // Navigate to full-screen image viewer
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageViewerScreen(
              imageUrl: imageUrl,
              heroTag: heroTag,
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            // Product image with Hero animation
            Hero(
              tag: heroTag,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            // Quantity badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'x $quantity',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Product description
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
