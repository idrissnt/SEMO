enum OrderState {
  scheduled,
  inProgress,
}

extension OrderStateExtension on OrderState {
  String get displayName {
    switch (this) {
      case OrderState.scheduled:
        return 'Programmé';
      case OrderState.inProgress:
        return 'En cours';
    }
  }

  String get description {
    switch (this) {
      case OrderState.scheduled:
        return 'Commande programmée pour livraison';
      case OrderState.inProgress:
        return 'Livraison en cours';
    }
  }
}
