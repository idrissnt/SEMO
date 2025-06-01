import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Status of an order item in the shopping process
enum OrderItemStatus {
  inProgress,
  customerReviewing,
  found,
}

/// Model representing an item in a community order
class OrderItem {
  final String id;
  final String name;
  final String imageUrl;
  final int quantity;
  final String unit;
  final double valueUnit;
  final double price;
  final String aisle;
  final String position;
  OrderItemStatus status;
  String? customerNote;
  String? shopperNote;

  OrderItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.unit,
    required this.valueUnit,
    required this.price,
    required this.position,
    required this.aisle,
    this.status = OrderItemStatus.inProgress,
    this.customerNote,
    this.shopperNote,
  });

  // Create sample items for testing
  static List<OrderItem> getSampleItems() {
    return [
      OrderItem(
        id: '1',
        name: 'Pommes Golden',
        imageUrl:
            'https://images.unsplash.com/photo-1603833665858-e61d17a86224?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        quantity: 6,
        unit: 'kg',
        valueUnit: 1,
        price: 4.50,
        position: 'Étage 1',
        aisle: 'Rayon fruits et légumes',
        status: OrderItemStatus.found,
      ),
      OrderItem(
        id: '2',
        name: 'Bananes',
        imageUrl:
            'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        quantity: 1,
        unit: 'kg',
        valueUnit: 1,
        price: 2.20,
        position: 'Étage 1',
        aisle: 'Rayon lait et produits laitiers',
        status: OrderItemStatus.found,
      ),
      OrderItem(
        id: '3',
        name: 'Tomates',
        imageUrl:
            'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        quantity: 4,
        unit: 'l',
        valueUnit: 1,
        price: 3.80,
        position: 'Étage 1',
        aisle: 'Rayon fruits et légumes',
        status: OrderItemStatus.found,
        shopperNote:
            'Je ne trouve pas cette variété, voulez-vous des tomates cerises? lkjbsdfg kubdsg iubvz gdiubgsajdcbvgz ',
      ),
      OrderItem(
        id: '4',
        name: 'Filets de poulet',
        imageUrl:
            'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        quantity: 1,
        unit: 'g',
        valueUnit: 100,
        price: 8.90,
        position: 'Étage 1',
        aisle: 'Rayon viandes',
        status: OrderItemStatus.found,
      ),
      OrderItem(
        id: '5',
        name: 'Jus d\'orange',
        imageUrl:
            'https://images.unsplash.com/photo-1576186726115-4d51596775d1?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        quantity: 2,
        unit: 'bouteille',
        valueUnit: 1,
        price: 3.50,
        position: 'Étage 1',
        aisle: 'Rayon jus et boissons',
        status: OrderItemStatus.found,
      ),
    ];
  }
}

/// Widget for displaying an order item in the shopping list
class OrderItemCard extends StatelessWidget {
  final OrderItem item;
  final VoidCallback onViewDetails;
  final String storeName;

  const OrderItemCard({
    Key? key,
    required this.item,
    required this.storeName,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getGradientColorString(),
                _getGradientColorString(),
                _getGradientColorString(),
                Colors.white,
                Colors.white,
                Colors.white,
              ],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
            borderRadius: BorderRadius.circular(20), // Slightly larger radius
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: onViewDetails,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 2, right: 8, bottom: 2, top: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Item image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl,
                      width: 150.w,
                      height: 180.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Item details
                  Container(
                    width: 185.w,
                    height: 160.h,
                    margin: const EdgeInsets.only(
                        top: 8, bottom: 8, left: 0, right: 0),
                    padding: const EdgeInsets.only(
                        left: 8, right: 4, bottom: 8, top: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildInfoRow(
                          Icons.shopping_basket,
                          '${item.name} ojibzdgbkuj ikubgsd ioug ',
                          Colors.green,
                          textMaxLine: 2,
                        ),
                        const SizedBox(height: 6),
                        _buildInfoRow(
                          Icons.euro,
                          '${item.price.toStringAsFixed(2)}€ (${item.valueUnit} ${item.unit})',
                          Colors.red,
                          textMaxLine: 1,
                        ),
                        const SizedBox(height: 6),
                        _buildInfoRow(
                          Icons.location_on,
                          '${item.position} * ${item.aisle}',
                          Colors.blue,
                          textMaxLine: 2,
                        ),
                        if (item.status == OrderItemStatus.customerReviewing &&
                            item.shopperNote != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: Text(
                              'Note: ${item.shopperNote}',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Color.fromARGB(255, 65, 14, 14),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Action buttons
                ],
              ),
            ),
          ),
        ),
        // if (item.status != OrderItemStatus.customerReviewing)
        Positioned(
          right: 46.5.w,
          top: -6.h,
          child: IconButton(
            onPressed: onViewDetails,
            icon: _buildActionButtons('Voir details'),
          ),
        ),
        if (item.status == OrderItemStatus.customerReviewing)
          Positioned(
            left: 104.w,
            bottom: -6.h,
            child: IconButton(
              onPressed: onViewDetails,
              icon: _buildActionButtons('Remplacer', color: Colors.red),
            ),
          ),
        Positioned(
          right: 8,
          bottom: 8,
          child: Container(
            width: 55,
            padding:
                const EdgeInsets.only(right: 8, left: 16, top: 4, bottom: 4),
            decoration: const BoxDecoration(
              // color: Color(0xFFFFDE21),
              color: Colors.green,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(0),
                bottomRight: Radius.circular(12),
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(0),
              ),
            ),
            child: Text(
              'x ${item.quantity}', // This would be dynamic based on cart quantity
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        if (item.status == OrderItemStatus.found)
          Positioned(
            top: 8,
            right: 8,
            child: buildIndicatorItemStatus(Icons.check_circle, Colors.green),
          ),
        if (item.status == OrderItemStatus.customerReviewing)
          Positioned(
            top: 8,
            right: 8,
            child: buildIndicatorItemStatus(
                Icons.hourglass_top_rounded, Colors.orange),
          ),
      ],
    );
  }

  Widget buildIndicatorItemStatus(IconData icon, Color color) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Icon(icon, size: 24, color: color),
      ),
    );
  }

  /// Builds an information row with an icon and text
  Widget _buildInfoRow(IconData icon, String text, Color iconColor,
      {int textMaxLine = 2}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: iconColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            maxLines: textMaxLine,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(String text, {Color color = Colors.blue}) {
    return Container(
      // width: 55,
      padding: const EdgeInsets.only(right: 16, left: 16, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

  Color _getGradientColorString() {
    if (storeName.toLowerCase().contains('lec')) {
      return Colors.blue.withValues(alpha: 0.4);
    } else if (storeName.toLowerCase().contains('car')) {
      return const Color.fromARGB(255, 249, 47, 47).withValues(alpha: 0.4);
    } else {
      return const Color.fromARGB(255, 255, 196, 0).withValues(alpha: 0.4);
    }
  }
}
