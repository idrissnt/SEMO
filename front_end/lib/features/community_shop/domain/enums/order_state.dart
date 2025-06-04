enum OrderState {
  enAttente,
  programmer,
  enCours,
}

extension OrderStateExtension on OrderState {
  String get displayName {
    switch (this) {
      case OrderState.enAttente:
        return 'En attente';
      case OrderState.programmer:
        return 'Programmé';
      case OrderState.enCours:
        return 'En cours';
    }
  }
  
  String get description {
    switch (this) {
      case OrderState.enAttente:
        return 'Commande en attente de programmation';
      case OrderState.programmer:
        return 'Commande programmée pour livraison';
      case OrderState.enCours:
        return 'Livraison en cours';
    }
  }
}
