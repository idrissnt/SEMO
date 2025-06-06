// import 'package:flutter/material.dart';
// import 'package:semo/features/community_shop/domain/enums/order_state.dart';

// /// A widget that displays a badge indicating the current state of an order
// class OrderStateBadge extends StatelessWidget {
//   final OrderState state;

//   const OrderStateBadge({
//     Key? key,
//     required this.state,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Define colors and text based on state
//     Color backgroundColor;
//     Color textColor;
//     IconData icon;
//     String text = state.displayName;

//     switch (state) {
//       case OrderState.scheduled:
//         backgroundColor = Colors.blue.shade100;
//         textColor = Colors.blue.shade800;
//         icon = Icons.event;
//         break;
//       case OrderState.inProgress:
//         backgroundColor = Colors.green.shade100;
//         textColor = Colors.green.shade800;
//         icon = Icons.check;
//         break;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 16, color: textColor),
//           const SizedBox(width: 4),
//           Text(
//             text,
//             style: TextStyle(
//               color: textColor,
//               fontWeight: FontWeight.bold,
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
