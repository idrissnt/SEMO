import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/widgets/icons/icon_with_container.dart';
import 'package:semo/features/order/domain/models/order_status.dart';

class OrderTrackingCard extends StatefulWidget {
  final OrderStatus orderStatus;
  final VoidCallback onExpandDetails;

  const OrderTrackingCard({
    Key? key,
    required this.orderStatus,
    required this.onExpandDetails,
  }) : super(key: key);

  @override
  State<OrderTrackingCard> createState() => _OrderTrackingCardState();
}

class _OrderTrackingCardState extends State<OrderTrackingCard> {
  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final startTime =
        timeFormat.format(widget.orderStatus.estimatedDeliveryTime);
    final endTime = timeFormat.format(widget.orderStatus.estimatedDeliveryTime
        .add(const Duration(minutes: 15)));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green,
            Colors.red,
            AppColors.primary,
            Colors.yellow.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.thirdColor,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Commande en cours',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: 'Arrivée aujourd\'hui entre ',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: '$startTime - $endTime',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: buildIcon(
                    radius: 24,
                    icon: Icons.more_horiz,
                    iconColor: Colors.black,
                    backgroundColor: Colors.grey.shade300,
                    onPressed: widget.onExpandDetails,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
              child: _buildProgressTracker(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTracker() {
    const stages = OrderStage.values;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(stages.length * 2 - 1, (index) {
        // Even indices are stage icons, odd indices are connectors
        if (index % 2 == 0) {
          final stageIndex = index ~/ 2;
          final stage = stages[stageIndex];
          final isComplete = widget.orderStatus.isStageComplete(stage);
          final isCurrentStage = stage == widget.orderStatus.currentStage;

          return _buildStageIcon(
            stage: stage,
            isComplete: isComplete,
            isCurrentStage: isCurrentStage,
          );
        } else {
          // This is a connector between icons
          final prevStageIndex = index ~/ 2;
          final isPrevStageComplete =
              widget.orderStatus.isStageComplete(stages[prevStageIndex]);

          return Expanded(
            child: Container(
              height: 3.5,
              color: isPrevStageComplete ? Colors.black : Colors.grey.shade300,
            ),
          );
        }
      }),
    );
  }

  Widget _buildStageIcon({
    required OrderStage stage,
    required bool isComplete,
    required bool isCurrentStage,
  }) {
    final icon = OrderStatus.getIconForStage(stage);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isComplete ? Colors.black : Colors.grey.shade300,
        boxShadow: isCurrentStage
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Icon(
        icon,
        color: isComplete ? Colors.white : Colors.black,
        size: 24,
      ),
    );
  }
}
