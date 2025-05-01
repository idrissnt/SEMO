// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// import '../../../../core/presentation/theme/responsive_theme.dart';
// import '../../../../core/utils/logger.dart';

// class TaskSuggestionsSection extends StatelessWidget {
//   final String title;
//   final List<TaskSuggestion> taskSuggestions;

//   final AppLogger _logger = AppLogger();

//   TaskSuggestionsSection({
//     Key? key,
//     required this.title,
//     required this.taskSuggestions,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     if (taskSuggestions.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     // Calculate responsive dimensions
//     final double sectionHeight = context.responsiveItemSizeWidth(160);
//     final double buttonSize = context.responsiveItemSizeWidth(40);
//     final double iconSize = context.responsiveItemSizeWidth(20);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsets.only(
//               left: context.lWidth, right: context.lWidth, top: context.sWidth),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 title,
//                 style: context.sectionTitle,
//               ),
//               TextButton(
//                 onPressed: () {
//                   _logger.debug('Show more tasks button pressed', {
//                     'route': '/mission',
//                     'component': 'TaskSuggestionsSection',
//                     'action': 'navigation'
//                   });
//                   context.go('/mission');
//                 },
//                 style: TextButton.styleFrom(
//                   padding: EdgeInsets.zero,
//                   minimumSize: Size(buttonSize, buttonSize),
//                   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                 ),
//                 child: Container(
//                   width: buttonSize,
//                   height: buttonSize,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     shape: BoxShape.circle,
//                   ),
//                   child: Center(
//                     child: Icon(
//                       Icons.arrow_forward,
//                       size: iconSize,
//                       color: context.textPrimaryColor,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         SizedBox(
//           height: sectionHeight,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             padding: EdgeInsets.symmetric(horizontal: context.mWidth),
//             itemCount: taskSuggestions.length,
//             itemBuilder: (context, index) {
//               final task = taskSuggestions[index];
//               return TaskSuggestionCard(
//                 task: task,
//                 onTap: () {
//                   _logger.info('Tapped task: ${task.title}');
//                   context.go('/mission');
//                 },
//               );
//             },
//           ),
//         ),
//         SizedBox(height: context.lWidth),
//       ],
//     );
//   }
// }

// class TaskSuggestionCard extends StatelessWidget {
//   final TaskSuggestion task;
//   final VoidCallback onTap;

//   const TaskSuggestionCard({
//     Key? key,
//     required this.task,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Calculate responsive dimensions
//     final double cardWidth = context.responsiveItemSizeWidth(150);
//     final double iconSize = context.responsiveItemSizeWidth(20);
//     final double smallIconSize = context.responsiveItemSizeWidth(14);

//     return Container(
//       width: cardWidth,
//       margin: EdgeInsets.symmetric(
//           horizontal: context.xsWidth, vertical: context.sWidth),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(context.borderRadiusMediumWidth),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius:
//                   BorderRadius.circular(context.borderRadiusMediumWidth),
//               boxShadow: [
//                 BoxShadow(
//                   color: context.secondaryColor,
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             padding: EdgeInsets.all(context.mWidth),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       padding: EdgeInsets.all(context.sWidth),
//                       decoration: BoxDecoration(
//                         color: task.iconBackgroundColor,
//                         borderRadius: BorderRadius.circular(
//                             context.borderRadiusSmallWidth),
//                       ),
//                       child: Icon(
//                         task.icon,
//                         color: task.iconBackgroundColor,
//                         size: iconSize,
//                       ),
//                     ),
//                     const Spacer(),
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                           horizontal: context.sWidth,
//                           vertical: context.xxsWidth),
//                       decoration: BoxDecoration(
//                         color: context.primaryColor,
//                         borderRadius: BorderRadius.circular(
//                             context.borderRadiusMediumWidth),
//                       ),
//                       child: Text(
//                         task.reward,
//                         style: context.badgeText,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: context.mWidth),
//                 Text(
//                   task.title,
//                   style: context.listItemTitle,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: context.xxsWidth),
//                 Text(
//                   task.description,
//                   style: context.listItemSubtitle,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const Spacer(),
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.access_time,
//                       size: smallIconSize,
//                       color: Colors.grey,
//                     ),
//                     SizedBox(width: context.xxsWidth),
//                     Text(
//                       task.timeEstimate,
//                       style: context.caption,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class TaskSuggestion {
//   final String id;
//   final String title;
//   final String description;
//   final String reward;
//   final String timeEstimate;
//   final IconData icon;
//   final Color iconBackgroundColor;

//   TaskSuggestion({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.reward,
//     required this.timeEstimate,
//     required this.icon,
//     required this.iconBackgroundColor,
//   });
// }

// // Sample data for task suggestions
// List<TaskSuggestion> getSampleTaskSuggestions() {
//   return [
//     TaskSuggestion(
//       id: '1',
//       title: 'Faire les courses',
//       description: 'Acheter des produits alimentaires',
//       reward: '15€',
//       timeEstimate: '1h',
//       icon: FontAwesomeIcons.cartShopping,
//       iconBackgroundColor: Colors.blue,
//     ),
//     TaskSuggestion(
//       id: '2',
//       title: 'Livraison de colis',
//       description: 'Récupérer et livrer un colis',
//       reward: '10€',
//       timeEstimate: '45min',
//       icon: FontAwesomeIcons.box,
//       iconBackgroundColor: Colors.orange,
//     ),
//     TaskSuggestion(
//       id: '3',
//       title: 'Montage de meuble',
//       description: 'Assembler un meuble IKEA',
//       reward: '25€',
//       timeEstimate: '2h',
//       icon: FontAwesomeIcons.screwdriverWrench,
//       iconBackgroundColor: Colors.green,
//     ),
//     TaskSuggestion(
//       id: '4',
//       title: 'Ménage à domicile',
//       description: 'Nettoyer un appartement',
//       reward: '30€',
//       timeEstimate: '3h',
//       icon: FontAwesomeIcons.broom,
//       iconBackgroundColor: Colors.purple,
//     ),
//     TaskSuggestion(
//       id: '5',
//       title: 'Promener un chien',
//       description: 'Sortir un chien pendant 1h',
//       reward: '12€',
//       timeEstimate: '1h',
//       icon: FontAwesomeIcons.dog,
//       iconBackgroundColor: Colors.brown,
//     ),
//   ];
// }
