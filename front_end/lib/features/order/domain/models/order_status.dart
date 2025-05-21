import 'package:flutter/material.dart';

enum OrderStage {
  confirmed,
  preparing,
  delivering,
  delivered,
}

class OrderStatus {
  final String orderId;
  final OrderStage currentStage;
  final DateTime estimatedDeliveryTime;
  final String storeName;
  final String storeLogo;

  OrderStatus({
    required this.orderId,
    required this.currentStage,
    required this.estimatedDeliveryTime,
    required this.storeName,
    required this.storeLogo,
  });

  // Helper method to get the appropriate icon for each stage
  static IconData getIconForStage(OrderStage stage) {
    switch (stage) {
      case OrderStage.confirmed:
        return Icons.check_circle;
      case OrderStage.preparing:
        return Icons.store;
      case OrderStage.delivering:
        return Icons.directions_car_filled;
      case OrderStage.delivered:
        return Icons.home;
    }
  }

  // Helper method to determine if a stage is complete based on current stage
  bool isStageComplete(OrderStage stage) {
    return stage.index <= currentStage.index;
  }
}
